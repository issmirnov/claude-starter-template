# detect-overengineering Skill — Design Spec

## Overview

A skill that audits an **implementation plan document** (not code) for LLM-style overengineering and proposes specific edits to slim the plan before any code is written. Sits between `writing-plans` and `executing-plans` in the superpowers workflow.

The premise: LLM-generated plans tend to over-include — defensive validation, premature abstractions, speculative configuration, multi-phase rollouts for low-impact work. Catching this in the plan is far cheaper than catching it in code review. This skill makes that audit deterministic and actionable.

## Skill Identity

- **Name:** `detect-overengineering`
- **Description:** "Use when reviewing an implementation plan document (docs/superpowers/plans/*.md or similar) for LLM-style overengineering before implementation. Runs a rubric-driven Claude pass plus a Codex adversarial pass, merges findings, and proposes specific edits to slim the plan. Triggers on 'check this plan for bloat', 'is this overengineered', 'detect overengineering', or invoked as /detect-overengineering."
- **Type:** Technique (concrete workflow with steps)
- **Prerequisites:** Codex CLI (`codex` on PATH) — same dependency as `codex-plan-review`
- **Plugin:** `plan-utilities` (alongside `codex-plan-review`)

## Pipeline

```
[1] Discover plan        → scans docs/superpowers/plans/*.md, docs/superpowers/specs/*.md,
                            docs/plans/*.md (most recent by date prefix). Falls back to
                            asking user if zero or multiple plausible matches.
                            ↓
[2] Rubric pass (Claude) → walks the plan section-by-section against the rubric
                            (skills/detect-overengineering/rubric.md). Emits structured
                            findings.
                            ↓
[3] Adversarial pass     → sends plan + rubric (as lens) to Codex (default
    (Codex)                gpt-5.4-codex high effort, read-only — matches
                            codex-plan-review). Codex returns prose; Claude
                            parses into the same finding shape.
                            ↓
[4] Merge + dedupe       → reconcile by (plan_section, evidence overlap). Cross-validated
                            findings tagged "both"; single-source findings retain their
                            source tag.
                            ↓
[5] Present report       → markdown report ordered by source (both → rubric → codex)
                            and confidence. Each finding is self-contained and actionable.
                            ↓
[6] Apply approved edits → user picks all / walk / cherry-pick. Skill applies via
                            Edit tool with exact-match old/new strings derived from
                            evidence quotes. Skipped findings logged.
```

## The Rubric

The heart of the skill. Lives in `skills/detect-overengineering/rubric.md`. Each entry has a plan-level signal (what to grep for in plan text) and a typical edit (what slimming looks like).

| # | Pattern | Plan-level signal | Typical edit | Confidence |
|---|---|---|---|---|
| 1 | Defensive validation in trusted flows | "validate inputs", "guard against null/undefined" on internal-only functions | Strike validation; trust internal callers and types | high |
| 2 | Error handling for impossible cases | try/catch around code with no realistic throw path; "fallback if X fails" when X can't fail | Remove handler; let it throw | high |
| 3 | Premature abstraction | "create a service layer / interface / adapter / factory" with one concrete consumer | Inline at the call site | high |
| 4 | Speculative configuration | env vars, feature flags, config files for values that aren't reconfigured | Hardcode the value | high |
| 5 | Backwards-compat shims for greenfield code | "keep old name as alias", "add deprecation comment", "re-export for migration" with no existing consumers | Delete the shim | high |
| 6 | Useless DRY | "extract helper" for 2-3 similar lines used in 1-2 places | Leave the duplication | high |
| 7 | Comment / docstring bloat | "add JSDoc to all exports", multi-paragraph explanatory comments for self-evident code | Remove; rely on names | high |
| 8 | Over-tested impossible paths | tests for branches the type system / framework already guarantees | Remove those test cases | context-dep |
| 9 | Speculative extensibility | "design for future X", "make Y pluggable" without a current second use case | Build for the one case you have | context-dep |
| 10 | File proliferation for tiny modules | splitting <100 LOC across types.ts/utils.ts/index.ts/constants.ts | Single file | context-dep |
| 11 | Custom error classes with no extra info | new exception types that only wrap a string message | Throw a plain Error | context-dep |
| 12 | Multi-phase rollout for low-impact change | "feature flag → 10% → 50% → 100%" for internal refactor with no user impact | Ship it directly | context-dep |
| 13 | Migration step for non-data change | migration script when no schema/data shape changes | Strike the migration step | context-dep |

**Calibration:** "high" = clear bloat, flag confidently. "context-dep" = flag with "verify against requirements" caveat — could be justified by stated goals.

The rubric is grounded in the project's CLAUDE.md guidance ("don't add features beyond what the task requires," "don't add error handling for scenarios that can't happen," "three similar lines is better than premature abstraction," etc.) — so flagging these patterns is consistent with how the user already wants to operate.

The catalogue grows. Each pattern has a corresponding entry in `examples.md` with anti-examples (what NOT to flag) to keep the rubric pass from over-firing.

## Pass A — Claude Rubric Pass

Claude reads the plan and walks the rubric section by section. For each match, emits:

```
{
  source: "rubric",
  pattern_id: 3,
  plan_section: "## 4. Service layer",
  evidence: "Define IUserRepository interface with one concrete...",
  rationale: "One consumer, one implementation. The interface adds a file and zero substitutability.",
  suggested_edit: "Strike interface (lines 47-58). Replace IUserRepository references with UserRepository directly.",
  confidence: "high"
}
```

Deterministic: same plan + same rubric → same findings. The rubric is the test surface for skill quality.

## Pass B — Codex Adversarial Pass

Sent via `codex exec` with the rubric included in context (so Codex's lens is "LLM-overengineering," not "general architecture"). Same shape command as `codex-plan-review`:

```bash
codex exec \
  -m gpt-5.4-codex \
  --config model_reasoning_effort="high" \
  --sandbox read-only \
  --skip-git-repo-check \
  --full-auto \
  2>/dev/null \
  "<prompt>"
```

Prompt template:

```
You are auditing an implementation plan for LLM-style overengineering —
features that LLM-authored plans tend to over-include but that don't
serve the actual goal. Use this rubric as a lens but feel free to flag
patterns it misses:

<RUBRIC>

PLAN:
<plan content>

For each issue, return:
- Plan section (exact heading)
- Quoted evidence
- Why it's overengineering for THIS plan's stated goals
- Specific suggested edit (which lines to cut, collapse, or rewrite)

Skip generic architectural advice. Focus only on bloat the author
should cut before writing code.
```

Claude parses Codex's prose response into the same structured finding shape with `source: "codex"`.

## Merge Logic

| Match condition | Result |
|---|---|
| Same `plan_section` AND ≥50% phrase overlap in `evidence` | Merge → tag `source: "both"`, confidence `high` |
| Same `plan_section`, different evidence | Keep separate; both retain their source tag |
| Different sections | Keep separate |

`both`-tagged findings sort first (highest signal). Single-source findings follow, sorted by confidence then plan order. No semantic dedup — phrase overlap is the bar.

## Report Format

```
# Overengineering review: docs/superpowers/plans/2026-05-06-foo-design.md

13 findings (4 high-confidence cross-validated, 7 rubric-only, 2 codex-only)

──────────────────────────────────────────────────────────────────────
## Finding 1 — Premature abstraction  [BOTH · high]

Section: ## 4. Service layer
Evidence: "Define IUserRepository interface with one concrete UserRepository..."
Why bloat: One consumer, one implementation. The interface adds a file,
           a name, and zero substitutability.

Proposed edit:
  STRIKE the interface definition (lines 47-58)
  REPLACE call sites that reference IUserRepository with UserRepository directly

──────────────────────────────────────────────────────────────────────
## Finding 2 — Speculative configuration  [RUBRIC · high]
...
```

Each finding self-contained. No cross-references. Skim-friendly.

## Edit Application UX

After the report, Claude prompts:

> "I have N proposed edits. Apply all, walk through them one-by-one, or cherry-pick by number?"

| Mode | Behavior |
|---|---|
| **All** | Apply every edit in plan order via `Edit` tool. Show final diff summary. |
| **Walk** | For each finding: show again, ask `apply / skip / modify`. `modify` lets the user dictate a different edit before applying. |
| **Cherry-pick** | User passes `apply 1,3,5-7,12`. Skill applies those, skips the rest. |

**Edit safety:** every edit is a precise `Edit` call with `old_string` + `new_string` derived from the finding's evidence quote. No string-replace-all, no regex. If `old_string` no longer matches (user edited the plan between report and apply), skill stops and re-prompts that finding. No silent partial edits.

After all edits land:

```
Applied 9 of 13 edits. Plan reduced: 412 → 287 lines (-30%).
Skipped: 4, 7, 11, 13.
Re-run /detect-overengineering to verify? (y/N)
```

## Edge Cases

- **Zero findings:** "Plan looks clean against the current rubric. Codex's adversarial pass also found nothing actionable." No edit prompt.
- **Plan has uncommitted changes when skill runs:** warn but proceed; user owns the diff.
- **Plan file >2000 lines:** rubric pass chunks by H2 section; Codex gets full plan (handles long context natively).
- **Codex unavailable / fails:** continue with rubric pass only; report flags missing adversarial pass at top.
- **No plan auto-discovered:** prompt user for path, no implicit default.

## File Structure

```
skills/detect-overengineering/
├── SKILL.md           # orchestrates the pipeline
├── rubric.md          # the 13-pattern catalogue (Section: The Rubric)
└── examples.md        # 3-5 anti-examples per pattern (what NOT to flag)
```

Splitting rubric and examples out of SKILL.md keeps the prompt body short and lets the catalogue grow without bloating the main skill file.

## Marketplace Wiring

Add to existing `plan-utilities` plugin (no new plugin):

```diff
   {
     "name": "plan-utilities",
     "description": "Tools for iterating on and reviewing implementation plans before execution",
     "source": "./",
     "strict": false,
     "skills": [
-      "./skills/codex-plan-review"
+      "./skills/codex-plan-review",
+      "./skills/detect-overengineering"
     ]
   }
```

Plugin description unchanged — both skills are "tools for iterating on plans."

## Doc Updates

`CLAUDE.md` "Current Skills" table gets a new row:

| Skill | Plugin | Path | Purpose |
|---|---|---|---|
| `detect-overengineering` | `plan-utilities` | `skills/detect-overengineering/` | Audit a plan document for LLM-style overengineering — rubric pass + Codex adversarial pass + merged findings with proposed edits |

## Out of Scope (v1)

- **Auto-applying findings without approval** — too risky; user always gates edits.
- **Per-user rubric customization** — start with canonical rubric; fork locally if needed.
- **Continuous mode** (re-run on every plan save) — explicit invocation only.
- **Severity scoring** — confidence levels (`high` / `context-dep`) cover this dimension.
- **Cross-plan analysis** — one plan at a time.

## Open Items / Future Work

- **Rubric expansion via dogfood:** when in-flight Codex chronicle reviews finish, mine their outputs as real-world signal and propose new rubric patterns. Likely candidates: rollback plans for non-destructive ops, telemetry/observability before product-market fit, retry policies for synchronous internal calls.
- **Anti-example library (`examples.md`):** to be populated alongside the first real uses of the skill — each false positive in production becomes a "don't flag this" entry.
- **Codex enhancement review:** the rubric was not externally reviewed by Codex before this spec was written (harness/Codex integration issue at design time — background bash jobs killed at exit code 144 before codex high-effort runs could complete). A follow-up review pass should validate signals and calibration.
- **Codex model default:** spec uses `gpt-5.4-codex` to match `codex-plan-review`. User has been running `gpt-5.3-codex` for ad-hoc adversarial work. If 5.3 is preferred for this skill, decide before implementation and apply the same choice to `codex-plan-review` for consistency.
