# Presentation Blueprint Skill — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a Claude Code skill that acts as a Fortune 500 presentation consultant — analyzing source material, crafting strategic blueprints, and rendering polished slide decks via `document-skills:pptx`.

**Architecture:** Four markdown files in `~/.claude/skills/presentation-blueprint/`. SKILL.md is the lean workflow hub; three reference files are loaded on-demand during specific phases. No scripts — rendering is fully delegated to the pptx skill.

**Tech Stack:** Claude Code skill system (YAML frontmatter + markdown), document-skills:pptx (prerequisite)

**Spec:** `docs/superpowers/specs/2026-03-14-presentation-blueprint-design.md`

**Note on file location:** Skill files live at `~/.claude/skills/presentation-blueprint/` (user home directory, outside any git repo). They are NOT tracked by git. Only the spec/plan docs in this repo are committed.

**Parallelism:** Tasks 1-4 are independent file creations and can run in parallel.

---

## Chunk 1: Core Skill File

### Task 1: Write SKILL.md

**Files:**
- Create: `~/.claude/skills/presentation-blueprint/SKILL.md`

This is the main skill file — the workflow hub that Claude reads when the skill is triggered.

- [ ] **Step 1: Write frontmatter + identity sections**

```yaml
---
name: presentation-blueprint
description: Use when the user needs to create a presentation, pitch deck, slide deck, or visual summary about a project, codebase, website, or topic. Triggers on requests like 'build a deck', 'create a presentation', 'make slides about', or 'pitch deck for'.
---
```

Write these sections:
1. **Overview** — One-sentence description + core principle ("analyze → strategize → render")
2. **Prerequisites** — Check for `document-skills:pptx`, provide install instructions if missing, stop
3. **Presentation Types** — Detection table (pitch/technical/update/general) with trigger signals and default slide counts
4. **Pipeline Flowchart** — Small dot digraph showing the 5 phases with approval gates and loops

- [ ] **Step 2: Write the five phase descriptions**

5. **Phase 1: Source Analysis** — What to extract from each source type, error handling, reference to `source-analysis.md`
6. **Phase 2: Strategic Blueprint** — The 5 strategy elements (objective, audience, key message, ask, narrative arc), reference to `narrative-frameworks.md`
7. **Phase 3: Slide Outline** — Approval gate format, max 3 revision loops, slide count check at 25
8. **Phase 4: Style Confirmation** — Style defaults table, outputs style label + parameters
9. **Phase 5: Render & Review** — Delegate to pptx skill, reference `slide-archetypes.md`, error handling posture

- [ ] **Step 3: Write guardrails and red flags**

10. **Guardrails** — Content safety (no fabricated data, no secrets), quality gates (mandatory approvals), scope limits (25 slides, one deck per invocation)
11. **Red Flags** — Table of things the skill must never do (fabricate metrics, skip approval gates, generate fluff)

- [ ] **Step 4: Review SKILL.md for CSO compliance**

Verify:
- Description starts with "Use when..."
- Description contains NO workflow summary
- Keywords cover: presentation, pitch deck, slide deck, slides, deck, visual summary, project, codebase, website
- Name uses only letters, numbers, hyphens
- Total frontmatter under 1024 chars
- Total word count ~300 (detail lives in reference files)

---

## Chunk 2: Narrative Frameworks Reference

### Task 2: Write narrative-frameworks.md

**Files:**
- Create: `~/.claude/skills/presentation-blueprint/narrative-frameworks.md`

Heavy reference file loaded during Phase 2. Contains the three story structures and adaptation rules.

- [ ] **Step 1: Write Pitch Deck framework**

- Name: Pitch Deck (Problem → Solution → Why Now)
- 10-slide sequence with purpose and required content per slide
- Per-slide adaptation rules: when to skip (e.g., "skip Traction if pre-launch"), when to merge

- [ ] **Step 2: Write Technical Overview framework**

- Name: Technical Overview (Context → Architecture → Depth)
- 8-slide base sequence, expandable to 15-20
- Per-slide adaptation rules

- [ ] **Step 3: Write Project Update framework**

- Name: Project Update (Status → Detail → Next)
- 5-slide sequence
- Per-slide adaptation rules

- [ ] **Step 4: Write general adaptation rules section**

Cross-cutting rules:
- Missing data → skip the slide, don't generate fluff
- Thin source → merge related slides (e.g., Business Model + Market into one)
- Rich source → expand key slides (e.g., How It Works from 2 to 4 slides)
- Cross-type: when a "pitch deck" needs technical depth, borrow from Technical Overview
- Slide count guard: if adapted outline exceeds type default by >50%, flag to user

---

## Chunk 3: Slide Archetypes Reference

### Task 3: Write slide-archetypes.md

**Files:**
- Create: `~/.claude/skills/presentation-blueprint/slide-archetypes.md`

Bridges the gap between blueprint and rendering. Defines reusable slide patterns that guide HTML generation.

- [ ] **Step 1: Write archetypes 1-6**

Each archetype needs: name, when to use, layout description, content requirements, style variations per presentation type.

1. **Title** — Hero slide, big text, optional subtitle + logo
2. **Section Divider** — Marks a new section, minimal content
3. **Problem/Pain** — Statement + supporting evidence, emotional weight
4. **Solution** — Product/feature showcase, before/after or demo visual
5. **Metric/KPI** — One big number + context + trend indicator
6. **Comparison** — 2-column or vs. layout, feature matrix

- [ ] **Step 2: Write archetypes 7-12**

7. **Quote/Testimonial** — Pull quote with attribution
8. **Team/People** — Grid of headshots + roles, or key team highlights
9. **Diagram/Architecture** — System diagram, flowchart, or process visual
10. **Bullet List** — Key points, used sparingly (avoid wall-of-text)
11. **Image-Heavy** — Full-bleed or large image with minimal text overlay
12. **CTA/Ask** — Call to action, specific request, contact info

- [ ] **Step 3: Add archetype-to-framework mapping**

Which archetypes map to which framework slides:
- Pitch Deck Slide 1 (Hook) → Title archetype
- Pitch Deck Slide 2 (Problem) → Problem/Pain archetype
- Pitch Deck Slide 10 (The Ask) → CTA/Ask archetype
- (Complete mapping for all three frameworks)

---

## Chunk 4: Source Analysis Reference

### Task 4: Write source-analysis.md

**Files:**
- Create: `~/.claude/skills/presentation-blueprint/source-analysis.md`

Patterns for extracting presentation-relevant signal from different source types.

- [ ] **Step 1: Write codebase analysis patterns**

What to look for and where:
- **README.md** → Project description, features, quick start (maps to Solution, How It Works)
- **package.json / pyproject.toml** → Name, description, dependencies, version (maps to Tech Stack)
- **CLAUDE.md / AGENTS.md** → Architecture patterns, conventions (maps to Architecture slides)
- **docs/** → User-facing docs, API docs (maps to Features, How It Works)
- **git log** → Activity, contributors, velocity (maps to Traction, Team)
- **LICENSE** → Open source status (maps to Business Model context)
- **.github/** → CI/CD maturity, automation (maps to Technical Depth)

- [ ] **Step 2: Write website analysis patterns**

What to fetch and extract:
- **Landing page** → Value proposition, headline, hero copy (maps to Hook, Solution)
- **About page** → Mission, team, history (maps to Team, Why Now)
- **Pricing page** → Business model, tiers (maps to Business Model)
- **Features page** → Capabilities, differentiators (maps to Solution, Comparison)
- **Blog / changelog** → Recent momentum, launches (maps to Traction)

Note: WebFetch may fail. Always note which pages were unreachable and compensate with interview questions.

- [ ] **Step 3: Write interview question patterns**

Templates for gap-filling questions per presentation type:
- **Pitch deck gaps** → "Who is the target customer?", "What's your revenue/traction?", "What's the funding ask?"
- **Technical overview gaps** → "Who is the audience? (engineers, PMs, execs)", "What's the key architectural decision to highlight?"
- **Project update gaps** → "What period does this cover?", "What are the top 3 accomplishments?", "Any blockers?"
- **Universal gaps** → "What's the one thing you want the audience to remember?", "What action should they take after viewing?"

Rule: Ask only what couldn't be extracted. Max 3-5 questions total.

---

## Chunk 5: Testing & Validation

### Task 5: Baseline Test (RED phase)

Per the writing-skills TDD process, test the skill by running a pressure scenario WITHOUT the skill present, to establish baseline behavior.

- [ ] **Step 1: Run baseline test**

Dispatch a subagent (or run in a separate Claude Code session if subagents unavailable) with this prompt — NO skill loaded:

> "Create a 10-slide pitch deck for the claude-starter-template project at /home/vania/Projects/1.Personal/claude-starter-template. Analyze the codebase and build the deck."

Document:
- Did it analyze the codebase systematically or superficially?
- Did it define objective/audience/key message before jumping to slides?
- Did it ask the user for approval before rendering?
- Did it fabricate any metrics?
- What rationalizations did it use for skipping steps?

- [ ] **Step 2: Document baseline behavior**

Write findings to `docs/superpowers/specs/2026-03-14-presentation-blueprint-baseline.md`

### Task 6: Skill Test (GREEN phase)

- [ ] **Step 1: Run same scenario WITH skill loaded**

All 7 checks must pass for GREEN:
1. Checks for pptx prerequisite
2. Runs Phase 1 source analysis systematically
3. Asks targeted interview questions
4. Presents strategy before slide outline
5. Gets approval at Phase 3 and Phase 4
6. Delegates rendering to pptx skill
7. Never fabricates metrics

- [ ] **Step 2: Compare baseline vs. skill behavior**

Document improvements and any remaining gaps.

### Task 7: Refactor (REFACTOR phase)

- [ ] **Step 1: Close any loopholes found in testing**

Update SKILL.md with explicit counters for any rationalizations observed during baseline and skill tests.

- [ ] **Step 2: Re-test if changes were significant**

Re-run Task 6 to verify fixes don't break compliance.

- [ ] **Step 3: Verify all files are in place**

```bash
ls -la ~/.claude/skills/presentation-blueprint/
# Expected: SKILL.md, narrative-frameworks.md, slide-archetypes.md, source-analysis.md
```
