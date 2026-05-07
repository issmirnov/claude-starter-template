# detect-overengineering Skill — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a Claude Code skill `detect-overengineering` that audits an implementation plan document for LLM-style overengineering and proposes specific edits to slim it before code is written.

**Architecture:** Three markdown files in `skills/detect-overengineering/` (in this repo, tracked in git): SKILL.md (orchestration prompt), rubric.md (13-pattern catalogue), examples.md (anti-examples to prevent over-flagging). One marketplace.json edit, one CLAUDE.md edit, one dogfood pass against an existing plan. Skill orchestrates a two-pass review (Claude rubric pass + Codex adversarial pass), merges findings, presents a report, applies approved edits.

**Tech Stack:** Claude Code skill system (YAML frontmatter + markdown), `codex` CLI (prerequisite), repo's existing `plan-utilities` plugin

**Spec:** `docs/superpowers/specs/2026-05-06-detect-overengineering-design.md`

**Files (final state):**
- Create: `skills/detect-overengineering/rubric.md`
- Create: `skills/detect-overengineering/examples.md`
- Create: `skills/detect-overengineering/SKILL.md`
- Modify: `.claude-plugin/marketplace.json` (add path to `plan-utilities.skills`)
- Modify: `CLAUDE.md` (add row to "Current Skills" table)
- Touch (read-only): `docs/superpowers/plans/2026-03-14-presentation-blueprint.md` (dogfood target)

**Note on TDD:** This skill is markdown content, not executable code. The TDD pattern adapts to **draft → validate → commit**. Validation = parsing checks (`jq`, frontmatter parse, table-row count) and dogfood invocation against a real plan.

**Parallelism:** Tasks 1, 2 are independent and can run in parallel. Task 3 depends on the structure of 1 and 2 (it references them). Tasks 4, 5 depend on the skill directory existing. Task 6 (dogfood) depends on everything.

---

## Task 1: Create the rubric

**Files:**
- Create: `skills/detect-overengineering/rubric.md`

The 13-pattern catalogue. The skill loads this and walks each pattern against the plan during the rubric pass.

- [ ] **Step 1: Create the directory**

```bash
mkdir -p skills/detect-overengineering
```

- [ ] **Step 2: Write the rubric file**

Write this exact content to `skills/detect-overengineering/rubric.md`:

````markdown
# Overengineering Rubric

The 13-pattern catalogue used by the `detect-overengineering` skill. Each pattern has a plan-level signal (what to look for in the plan text) and a typical edit (what slimming looks like).

Calibration:
- **high**: clear bloat, flag confidently
- **context-dep**: flag with "verify against requirements" caveat — could be justified by stated goals

Anti-examples (what NOT to flag) live in `examples.md`. Always cross-reference before emitting a finding.

## Defensive coding (1–2)

### 1. Defensive validation in trusted flows  [high]

**Signal:** "validate inputs", "guard against null/undefined", "check that X is not empty" on functions called only from internal/trusted code.

**Edit:** Strike the validation. Trust internal callers and the type system.

### 2. Error handling for impossible cases  [high]

**Signal:** try/catch around code with no realistic throw path. "Fallback if X fails" when X cannot fail (e.g., wrapping `JSON.stringify` of a known-good object).

**Edit:** Remove the handler. Let it throw if it ever does.

## Abstraction (3, 6, 9)

### 3. Premature abstraction  [high]

**Signal:** "Define a service layer", "create an interface for X", "introduce an adapter / factory / strategy" with one concrete consumer in scope.

**Edit:** Inline the implementation at the call site.

### 6. Useless DRY  [high]

**Signal:** "Extract a helper for…" when the duplication is 2–3 similar lines used in 1–2 places.

**Edit:** Leave the duplication. Three similar lines is better than premature abstraction.

### 9. Speculative extensibility  [context-dep]

**Signal:** "Design for future X", "make Y pluggable", "keep this open for Z" without a current second use case.

**Edit:** Build for the one case you have. Add the abstraction when the second case arrives.

## Configuration & process (4, 12, 13)

### 4. Speculative configuration  [high]

**Signal:** Env vars, feature flags, config files for values that aren't reconfigured between environments or over time.

**Edit:** Hardcode the value.

### 12. Multi-phase rollout for low-impact change  [context-dep]

**Signal:** "Feature flag → 10% → 50% → 100%" or "canary → staging → prod" for a refactor with no user-visible impact.

**Edit:** Ship it directly. No rollout needed.

### 13. Migration step for non-data change  [context-dep]

**Signal:** "Add a migration script" / "data migration" listed when no schema or data shape changes.

**Edit:** Strike the migration step.

## Compatibility (5)

### 5. Backwards-compat shims for greenfield code  [high]

**Signal:** "Keep old name as alias", "add deprecation comment", "re-export for migration" — when there are no existing consumers.

**Edit:** Delete the shim. Rename directly.

## Documentation (7)

### 7. Comment / docstring bloat  [high]

**Signal:** "Add JSDoc to all exports", multi-paragraph explanatory comments for self-evident code.

**Edit:** Remove. Rely on names.

## Testing (8)

### 8. Over-tested impossible paths  [context-dep]

**Signal:** Tests for branches the type system or framework already guarantees (e.g., "test that the function returns a number" when the type is `number`).

**Edit:** Remove those test cases.

## Structure (10, 11)

### 10. File proliferation for tiny modules  [context-dep]

**Signal:** Splitting <100 lines of code across `types.ts` / `utils.ts` / `index.ts` / `constants.ts` from the start.

**Edit:** Single file until it grows.

### 11. Custom error classes with no extra info  [context-dep]

**Signal:** "Define a custom error type X" that wraps a string message without adding fields, codes, or behavior.

**Edit:** Throw a plain `Error`.
````

- [ ] **Step 3: Validate the rubric**

Run:
```bash
grep -c "^### " skills/detect-overengineering/rubric.md
```

Expected: `13` (one heading per pattern).

Run:
```bash
grep -c "\\[high\\]\\|\\[context-dep\\]" skills/detect-overengineering/rubric.md
```

Expected: `13` (each pattern has a confidence tag).

- [ ] **Step 4: Commit**

```bash
git add skills/detect-overengineering/rubric.md
git commit -m "Add overengineering rubric (13-pattern catalogue)

The catalogue used by detect-overengineering's rubric pass. Grouped
by category (defensive coding / abstraction / configuration / etc.)
and tagged with confidence (high vs context-dep).

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 2: Create the anti-examples file

**Files:**
- Create: `skills/detect-overengineering/examples.md`

Anti-examples per pattern. Prevents the rubric pass from over-flagging. v1: one ✅ FLAG example + one ❌ DON'T FLAG example per pattern (13 patterns × 2 = 26 examples).

- [ ] **Step 1: Write the examples file**

Write this exact content to `skills/detect-overengineering/examples.md`:

````markdown
# Anti-Examples for the Rubric

For each pattern in `rubric.md`: one example that **should** be flagged and one similar-looking case that **should not**. Use these to suppress findings when the plan text resembles a "don't flag" example more than a "flag" example.

This file grows. Every false positive observed in real use becomes a new "don't flag" entry.

---

## Pattern 1 — Defensive validation in trusted flows

✅ **Flag:** "Add validation to `getUserById(id: number)` to ensure `id > 0` before querying the database."
*(`id` arrives from internal callers; the type system already guarantees `number`. The DB query will simply return null for unknown ids.)*

❌ **Don't flag:** "Validate the email format on the public `/register` endpoint before creating a user."
*(Public endpoint, untrusted input — validation is required at the system boundary.)*

## Pattern 2 — Error handling for impossible cases

✅ **Flag:** "Wrap the `JSON.stringify(internalConfig)` call in try/catch in case it throws."
*(`internalConfig` is a known plain object; `JSON.stringify` won't throw. The catch will never fire.)*

❌ **Don't flag:** "Wrap user-supplied JSON parsing in try/catch and return a 400 on failure."
*(User input is untrusted; `JSON.parse` will throw on malformed input.)*

## Pattern 3 — Premature abstraction

✅ **Flag:** "Define a `UserRepository` interface and a single `PostgresUserRepository` implementation. Inject the interface into the service."
*(One consumer, one implementation, no second backend planned. The interface is a name without substance.)*

❌ **Don't flag:** "Define a `Storage` interface with `S3Storage` and `LocalStorage` implementations, selected by environment."
*(Two real implementations exist; the interface is load-bearing.)*

## Pattern 4 — Speculative configuration

✅ **Flag:** "Add `MAX_RETRY_COUNT` env var (default 3) for the email retry logic."
*(No requirement to vary by environment; 3 is the value forever. Hardcode it.)*

❌ **Don't flag:** "Add `DATABASE_URL` env var for the Postgres connection string."
*(Connection strings legitimately differ across dev/staging/prod; this is correct configuration.)*

## Pattern 5 — Backwards-compat shims for greenfield code

✅ **Flag:** "Rename `processOrder` to `executeOrder`. Keep `processOrder` as a deprecated alias that delegates to the new name."
*(No callers exist outside this PR; just rename.)*

❌ **Don't flag:** "Rename the public API method `processOrder` to `executeOrder`. Keep `processOrder` as a deprecated alias for one release cycle."
*(Public API with external callers; backwards compatibility is required.)*

## Pattern 6 — Useless DRY

✅ **Flag:** "Extract `formatTimestamp(date)` helper used in 2 places (the email template and the audit log)."
*(Two callers, three lines each. Inline is clearer.)*

❌ **Don't flag:** "Extract `validateOrderTotal(order)` helper called from 6 places across pricing, checkout, refunds, and fraud detection."
*(Six callers, non-trivial logic — the abstraction earns its keep.)*

## Pattern 7 — Comment / docstring bloat

✅ **Flag:** "Add JSDoc to every exported function in `utils.ts`, including a `@param`, `@returns`, and `@example` for each."
*(Self-evident utilities; the names already say it.)*

❌ **Don't flag:** "Add a comment to `parsePhoneNumber` explaining the E.164 normalization quirk that handles Brazilian mobile numbers with the optional ninth digit."
*(Non-obvious WHY; comment is load-bearing.)*

## Pattern 8 — Over-tested impossible paths

✅ **Flag:** "Add a test that verifies `getUserById(id: number)` returns `null` when called with `undefined`."
*(TypeScript's `number` parameter type already prevents `undefined` from being passed at compile time.)*

❌ **Don't flag:** "Add a test that verifies `getUserById` returns `null` when the id doesn't exist in the database."
*(Real branch, real behavior, not type-system-guaranteed.)*

## Pattern 9 — Speculative extensibility

✅ **Flag:** "Design the email sender to support multiple providers (SendGrid today, Mailgun and SES eventually) via a strategy pattern."
*(Only SendGrid is on the roadmap; the strategy pattern is for hypothetical future providers.)*

❌ **Don't flag:** "Design the payment processor to support both Stripe (US) and Razorpay (India) — both are required for Q2 launch."
*(Two real consumers committed in scope; pluggability is justified.)*

## Pattern 10 — File proliferation for tiny modules

✅ **Flag:** "Create `feature-x/types.ts`, `feature-x/utils.ts`, `feature-x/constants.ts`, `feature-x/index.ts` for the new feature (estimated ~80 lines total)."
*(Eighty lines doesn't need four files.)*

❌ **Don't flag:** "Split the existing 1500-line `service.ts` into `service.ts` (entry), `service-pricing.ts`, `service-fulfillment.ts`."
*(Real size justifies the split.)*

## Pattern 11 — Custom error classes with no extra info

✅ **Flag:** "Define `class UserNotFoundError extends Error {}` to throw when a user lookup fails."
*(No extra fields, no error code, no special handling — a plain Error with message would do the same job.)*

❌ **Don't flag:** "Define `class RateLimitError extends Error` with `retryAfterMs: number` and `limitType: 'user' | 'global'` fields, used by the retry middleware."
*(Carries structured data the consumer reads.)*

## Pattern 12 — Multi-phase rollout for low-impact change

✅ **Flag:** "Roll out the new internal logging format behind a feature flag: 10% week 1, 50% week 2, 100% week 3."
*(Internal logging change with no user impact and no migration risk; just ship it.)*

❌ **Don't flag:** "Roll out the new search algorithm behind a feature flag: 5% canary, monitor relevance metrics for 1 week, then 50%, then 100%."
*(User-visible behavior change with measurable quality impact; staged rollout is required.)*

## Pattern 13 — Migration step for non-data change

✅ **Flag:** "Add a migration script `migrations/2026_05_06_rename_function.sql` to rename the `processOrder` function in code."
*(Code rename, not a database change; no migration needed.)*

❌ **Don't flag:** "Add a migration script to add a `phone_number` column to the `users` table with a backfill from the legacy `contacts` table."
*(Real schema and data change; migration is correct.)*
````

- [ ] **Step 2: Validate the examples file**

Run:
```bash
grep -c "^## Pattern " skills/detect-overengineering/examples.md
```

Expected: `13` (one section per pattern).

Run:
```bash
grep -cE "^✅ \*\*Flag" skills/detect-overengineering/examples.md
```

Expected: `13`.

Run:
```bash
grep -cE "^❌ \*\*Don't flag" skills/detect-overengineering/examples.md
```

Expected: `13`.

- [ ] **Step 3: Commit**

```bash
git add skills/detect-overengineering/examples.md
git commit -m "Add anti-examples for overengineering rubric

One flag and one don't-flag example per pattern. Used by the rubric
pass to suppress findings on similar-looking-but-justified cases.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 3: Create the SKILL.md orchestration prompt

**Files:**
- Create: `skills/detect-overengineering/SKILL.md`

The main skill file. Frontmatter triggers the skill; body orchestrates the pipeline (discover → rubric pass → codex pass → merge → report → apply).

- [ ] **Step 1: Write the SKILL.md file**

Write this exact content to `skills/detect-overengineering/SKILL.md`:

````markdown
---
name: detect-overengineering
description: Use when reviewing an implementation plan document (docs/superpowers/plans/*.md or similar) for LLM-style overengineering before implementation. Runs a rubric-driven Claude pass plus a Codex adversarial pass, merges findings, and proposes specific edits to slim the plan. Triggers on 'check this plan for bloat', 'is this overengineered', 'detect overengineering', or invoked as /detect-overengineering.
---

# detect-overengineering

Audit an implementation plan document for LLM-style overengineering. Two passes (rubric-driven Claude pass + Codex adversarial pass) merge into a single report of specific edits to slim the plan before code is written.

Sits between `writing-plans` and `executing-plans` in the superpowers workflow. Cheaper to fix bloat in a plan than in merged code.

## Prerequisites

Verify `codex` is on PATH:

```bash
codex --version
```

If missing, instruct user to install Codex CLI (`npm install -g @openai/codex`) and stop.

## Process

### 1. Discover the plan

Look for plan files in this priority order; pick the most recently modified:

1. `docs/superpowers/plans/*.md`
2. `docs/superpowers/specs/*.md`
3. `docs/plans/*.md`

If zero matches, ask the user for the path.
If multiple matches in the top-priority directory have mtimes within 24h of each other, present a numbered list and ask which to review.

### 2. Pass A — Rubric pass (Claude in-session)

Read `./rubric.md` and `./examples.md`.

For each H2 section in the plan, walk every rubric pattern:
- Look for the pattern's plan-level signal in the section text
- If matched, check `examples.md` for "don't flag" look-alikes — suppress if the matched text fits a don't-flag case better than a flag case
- Otherwise emit a finding

Each finding is a structured record:

```
{
  source: "rubric",
  pattern_id: 3,
  plan_section: "## 4. Service layer",
  evidence: "Define IUserRepository...",
  rationale: "One consumer, one implementation. The interface is a name without substance.",
  suggested_edit: "Strike the interface (lines 47-58). Replace IUserRepository references with UserRepository directly.",
  confidence: "high"
}
```

### 3. Pass B — Codex adversarial pass

Run Codex with this exact command (matches `codex-plan-review` for consistency — non-spark model, high effort, read-only):

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

The prompt sent to Codex must follow this template:

```
You are auditing an implementation plan for LLM-style overengineering —
features that LLM-authored plans tend to over-include but that don't
serve the actual goal. Use this rubric as a lens but feel free to flag
patterns it misses:

<RUBRIC CONTENT FROM rubric.md>

PLAN:

<FULL PLAN CONTENT>

For each issue, return:
- Plan section (exact heading from the plan)
- Quoted evidence (a phrase from the plan, verbatim)
- Why it's overengineering for THIS plan's stated goals
- Specific suggested edit (which lines to cut, collapse, or rewrite)

Skip generic architectural advice. Focus only on bloat the author should
cut before writing code. Be direct and opinionated.
```

Parse Codex's prose response into the same finding shape with `source: "codex"`.

### 4. Merge findings

For each rubric finding F, scan codex findings for matches:
- Same `plan_section` AND ≥50% phrase overlap in `evidence` → merge into one finding tagged `source: "both"`, confidence `high`
- Same `plan_section`, different evidence → keep separate, retain individual sources
- Different sections → keep separate

Sort the final list:
1. `source: "both"` first, in plan order
2. `source: "rubric"`, sorted by confidence desc, then plan order
3. `source: "codex"`, sorted by plan order

### 5. Present the report

Render this markdown directly in the conversation:

```
# Overengineering review: <plan path>

<N> findings (<X> cross-validated, <Y> rubric-only, <Z> codex-only)

──────────────────────────────────────────────────────────────────────
## Finding 1 — <pattern name>  [<SOURCE> · <confidence>]

Section: <H2 heading from plan>
Evidence: "<quote>"
Why bloat: <rationale>

Proposed edit:
  <specific change>

──────────────────────────────────────────────────────────────────────
## Finding 2 — ...
```

If zero findings:

```
# Overengineering review: <plan path>

Plan looks clean against the current rubric. Codex's adversarial pass
also found nothing actionable.
```

### 6. Apply approved edits

After the report, prompt:

> "I have N proposed edits. Apply all, walk through one-by-one, or cherry-pick by number?"

Modes:

| Mode | Behavior |
|---|---|
| **all** | Apply every edit in plan order via `Edit` tool. Show diff summary. |
| **walk** | For each finding: re-display, ask `apply / skip / modify`. `modify` lets the user dictate a different edit before applying. |
| **cherry-pick** | User passes `apply 1,3,5-7,12`. Apply those, skip the rest. |

**Edit safety:** every `Edit` call uses an exact-match `old_string` derived from the finding's evidence quote and a precise `new_string` derived from the suggested edit. No regex, no replace_all. If `old_string` doesn't match (user edited the plan between report and apply), stop and re-prompt that finding. Never silently proceed.

After all edits land, summarize:

```
Applied <X> of <N> edits. Plan reduced: <before> → <after> lines (<delta>%).
Skipped: <list of finding numbers>.
Re-run /detect-overengineering to verify? (y/N)
```

## Edge cases

- **Zero findings:** report says so, no edit prompt.
- **Plan has uncommitted changes:** warn the user but proceed; they own the diff.
- **Plan file >2000 lines:** chunk the rubric pass by H2 section. Codex still gets the full plan (handles long context natively).
- **Codex unavailable / fails:** continue with rubric pass only. Report header notes "adversarial pass unavailable."
- **No plan auto-discovered:** prompt the user for a path. Do not pick a default.

## Key rules

- **Always read rubric.md AND examples.md** before the rubric pass — examples suppress false positives.
- **Always use exact-match edits** — never regex or replace-all.
- **Never apply edits without explicit user approval** — even in "all" mode, the user is approving the batch.
- **Present Codex output faithfully** — don't filter criticisms; merge what overlaps with rubric findings, keep the rest.
- **One plan per invocation.**
````

- [ ] **Step 2: Validate the SKILL.md frontmatter**

Run:
```bash
head -5 skills/detect-overengineering/SKILL.md
```

Expected: lines 1, 5 are `---`; line 2 starts with `name: detect-overengineering`; line 3 starts with `description: Use when`.

Run:
```bash
awk '/^---$/{c++} c==2{exit} {print}' skills/detect-overengineering/SKILL.md | wc -c
```

Expected: a number under `1024` (frontmatter must fit Claude Code's frontmatter size limit).

Run:
```bash
grep -c "^## " skills/detect-overengineering/SKILL.md
```

Expected: `4` (Prerequisites, Process, Edge cases, Key rules).

- [ ] **Step 3: Commit**

```bash
git add skills/detect-overengineering/SKILL.md
git commit -m "Add SKILL.md orchestrating the overengineering pipeline

Six-step pipeline: discover plan, rubric pass, Codex adversarial
pass, merge findings, present report, apply approved edits.
References rubric.md and examples.md.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 4: Wire the skill into marketplace.json

**Files:**
- Modify: `.claude-plugin/marketplace.json`

Add `./skills/detect-overengineering` to the `plan-utilities` plugin's `skills` array. The plugin description stays as-is (both skills are "tools for iterating on plans").

- [ ] **Step 1: Read the current marketplace.json**

Run:
```bash
cat .claude-plugin/marketplace.json
```

Confirm the `plan-utilities` plugin currently has only `./skills/codex-plan-review` in its `skills` array.

- [ ] **Step 2: Apply the edit**

Use the `Edit` tool with this exact change:

`old_string`:
```json
    {
      "name": "plan-utilities",
      "description": "Tools for iterating on and reviewing implementation plans before execution",
      "source": "./",
      "strict": false,
      "skills": [
        "./skills/codex-plan-review"
      ]
    },
```

`new_string`:
```json
    {
      "name": "plan-utilities",
      "description": "Tools for iterating on and reviewing implementation plans before execution",
      "source": "./",
      "strict": false,
      "skills": [
        "./skills/codex-plan-review",
        "./skills/detect-overengineering"
      ]
    },
```

- [ ] **Step 3: Validate the JSON**

Run:
```bash
jq . .claude-plugin/marketplace.json > /dev/null && echo "VALID JSON"
```

Expected: `VALID JSON`.

Run:
```bash
jq '.plugins[] | select(.name=="plan-utilities") | .skills' .claude-plugin/marketplace.json
```

Expected output:
```json
[
  "./skills/codex-plan-review",
  "./skills/detect-overengineering"
]
```

- [ ] **Step 4: Commit**

```bash
git add .claude-plugin/marketplace.json
git commit -m "Register detect-overengineering skill in plan-utilities plugin

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 5: Document the skill in CLAUDE.md

**Files:**
- Modify: `CLAUDE.md`

Add a row to the "Current Skills" table under the "Skills Marketplace" section.

- [ ] **Step 1: Apply the edit**

Use the `Edit` tool with this exact change:

`old_string`:
```
| Skill | Plugin | Path | Purpose |
|-------|--------|------|---------|
| `presentation-blueprint` | `presentation-tools` | `skills/presentation-blueprint/` | Build pitch/technical/update decks end-to-end (analyze → strategize → outline → style → render) |
| `codex-plan-review` | `plan-utilities` | `skills/codex-plan-review/` | Send the current plan to Codex 5.4 (high effort, read-only) for an independent architectural review |
| `git-recon` | `git-recon` | `skills/git-recon/` | 12-month git-history health check — churn, bus factor, bug hotspots, velocity, firefighting |
```

`new_string`:
```
| Skill | Plugin | Path | Purpose |
|-------|--------|------|---------|
| `presentation-blueprint` | `presentation-tools` | `skills/presentation-blueprint/` | Build pitch/technical/update decks end-to-end (analyze → strategize → outline → style → render) |
| `codex-plan-review` | `plan-utilities` | `skills/codex-plan-review/` | Send the current plan to Codex 5.4 (high effort, read-only) for an independent architectural review |
| `detect-overengineering` | `plan-utilities` | `skills/detect-overengineering/` | Audit a plan document for LLM-style overengineering — rubric pass + Codex adversarial pass + merged findings with proposed edits |
| `git-recon` | `git-recon` | `skills/git-recon/` | 12-month git-history health check — churn, bus factor, bug hotspots, velocity, firefighting |
```

- [ ] **Step 2: Validate**

Run:
```bash
grep -c "^| \`detect-overengineering\`" CLAUDE.md
```

Expected: `1` (exactly one row exists for this skill).

Run:
```bash
grep "^| \`detect-overengineering\`" CLAUDE.md
```

Expected output:
```
| `detect-overengineering` | `plan-utilities` | `skills/detect-overengineering/` | Audit a plan document for LLM-style overengineering — rubric pass + Codex adversarial pass + merged findings with proposed edits |
```

- [ ] **Step 3: Commit**

```bash
git add CLAUDE.md
git commit -m "Document detect-overengineering in Current Skills table

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 6: Dogfood — invoke the skill on a real plan

**Files:**
- Read-only: `docs/superpowers/plans/2026-03-14-presentation-blueprint.md` (the dogfood target — an existing plan in this repo)
- Read-only: `docs/superpowers/plans/2026-05-06-detect-overengineering.md` (this very plan; recursive dogfood as a stretch goal)

The skill is markdown content; the only meaningful test is to invoke it and observe behavior. This task validates the orchestration end-to-end.

- [ ] **Step 1: Verify the skill is discoverable**

Run:
```bash
ls -la skills/detect-overengineering/
```

Expected output (file order may vary):
```
SKILL.md
examples.md
rubric.md
```

Run:
```bash
jq -r '.plugins[] | select(.name=="plan-utilities") | .skills[]' .claude-plugin/marketplace.json
```

Expected:
```
./skills/codex-plan-review
./skills/detect-overengineering
```

- [ ] **Step 2: Invoke the skill on the presentation-blueprint plan**

In a Claude Code session with the marketplace plugin installed, invoke:

```
Run /detect-overengineering on docs/superpowers/plans/2026-03-14-presentation-blueprint.md
```

Or, if the skill auto-discovers, simply: `/detect-overengineering`.

Verify the skill performs all six pipeline steps in order:
1. Discovers the plan (or reports correctly if discovery is ambiguous)
2. Performs the rubric pass and emits structured findings
3. Performs the Codex adversarial pass (or notes "adversarial pass unavailable" if Codex fails)
4. Merges findings (cross-validated `[BOTH]` tags appear when both passes flag the same section)
5. Presents the markdown report in the format specified in SKILL.md
6. Prompts for apply mode (`all` / `walk` / `cherry-pick`)

- [ ] **Step 3: Spot-check report format**

Read the generated report. Verify:
- Header line: `# Overengineering review: docs/superpowers/plans/2026-03-14-presentation-blueprint.md`
- Summary line counts findings by source: `(X cross-validated, Y rubric-only, Z codex-only)`
- Each finding has: pattern name + `[SOURCE · confidence]` tag, `Section:`, `Evidence:`, `Why bloat:`, `Proposed edit:`
- No mismatched sources (e.g., a finding tagged `[BOTH]` must have evidence from both passes)

- [ ] **Step 4: Decline applying edits — this is a validation run only**

Respond `cherry-pick` followed by no numbers (or just hit cancel). The skill should exit cleanly without modifying the plan file.

Verify:
```bash
git status docs/superpowers/plans/2026-03-14-presentation-blueprint.md
```

Expected: `nothing to commit` (no modifications to the dogfood target).

- [ ] **Step 5: Record dogfood findings**

If the dogfood run surfaced rubric weaknesses (false positives, missed patterns, ambiguous signals), capture them in a follow-up note. Do NOT iterate on the rubric in this task — the spec's "Open Items" section already calls out rubric expansion via dogfood as future work. A simple file is enough:

Write to `skills/detect-overengineering/DOGFOOD-NOTES.md`:

```markdown
# Dogfood Notes — Initial Run

**Date:** YYYY-MM-DD
**Target:** docs/superpowers/plans/2026-03-14-presentation-blueprint.md

## Findings count
- Cross-validated: <X>
- Rubric-only: <Y>
- Codex-only: <Z>

## Rubric calibration observations
- <Pattern N>: <observation about precision/recall>
- <Pattern M>: <observation>

## Suggested rubric updates (for follow-up)
- <Pattern X>: tighten signal — current wording matched <unintended thing>
- <Pattern Y>: add anti-example — false-positive on <real plan section>

## New patterns observed (not in current rubric)
- <Brief description + plan-level signal + suggested edit>
```

Fill in the YYYY-MM-DD and the actual content from the dogfood run.

- [ ] **Step 6: Commit dogfood notes**

```bash
git add skills/detect-overengineering/DOGFOOD-NOTES.md
git commit -m "Add dogfood notes from initial detect-overengineering run

Initial validation run against the presentation-blueprint plan.
Captures rubric calibration observations for follow-up tuning.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Self-Review Checklist (engineer should run before marking plan complete)

After all tasks are done, verify these against the spec (`docs/superpowers/specs/2026-05-06-detect-overengineering-design.md`):

- [ ] **Spec coverage:** Every spec section maps to a task. Specifically:
  - Pipeline (6 steps) → SKILL.md step 1 (Task 3)
  - Rubric (13 patterns) → rubric.md (Task 1)
  - Pass A details → SKILL.md "Pass A — Rubric pass" section (Task 3)
  - Pass B details + exact codex command → SKILL.md "Pass B — Codex adversarial pass" section (Task 3)
  - Merge logic → SKILL.md "Merge findings" section (Task 3)
  - Report format → SKILL.md "Present the report" section (Task 3)
  - Edit application UX (all/walk/cherry-pick) → SKILL.md "Apply approved edits" section (Task 3)
  - File structure (3 files) → Tasks 1, 2, 3
  - Marketplace wiring → Task 4
  - CLAUDE.md doc update → Task 5
- [ ] **No placeholders:** No "TBD", "TODO", "fill in", or empty code blocks anywhere in the created files. (DOGFOOD-NOTES.md template placeholders are filled in by Task 6 Step 5 with real content.)
- [ ] **Type/name consistency:**
  - Pattern IDs 1-13 used consistently across rubric.md, examples.md, SKILL.md
  - Skill name `detect-overengineering` matches in: SKILL.md frontmatter, marketplace.json, CLAUDE.md row
  - File paths in SKILL.md match the actual files created (`./rubric.md`, `./examples.md`)
- [ ] **Commit history:** Six commits land in this order: rubric → examples → SKILL → marketplace → CLAUDE → dogfood.
- [ ] **Skill discoverability:** `jq` query in Task 6 Step 1 returns both skills.
- [ ] **End-to-end behavior:** Task 6 Step 2 produces a valid report against the dogfood target.
