# Presentation Blueprint Skill — Design Spec

## Overview

A skill that acts as a Fortune 500 presentation consultant: analyzes source material (codebases, websites, projects), crafts a strategic presentation blueprint, and renders a polished slide deck by delegating to `document-skills:pptx`.

## Skill Identity

- **Name:** `presentation-blueprint`
- **Description:** "Use when the user needs to create a presentation, pitch deck, slide deck, or visual summary about a project, codebase, website, or topic. Triggers on requests like 'build a deck', 'create a presentation', 'make slides about', or 'pitch deck for'."
- **Type:** Technique (concrete workflow with steps)
- **Prerequisite:** `document-skills:pptx`

## Presentation Types

| Type | Trigger signals | Default slides |
|---|---|---|
| Pitch deck | "pitch", "investors", "funding", "sell" | 10-12 |
| Technical overview | "architecture", "how it works", "onboarding" | 15-20 |
| Project update | "status", "progress", "update", "report" | 5-8 |
| General | Anything else — asks user to clarify | 10-12 |

The skill auto-detects type from context. When ambiguous, asks the user.

## Pipeline (5 Phases)

### Phase 1 — Source Analysis

Auto-detect available sources and pull from all of them:

- **Codebase:** README, docs/, package.json, CLAUDE.md, git log, architecture files
- **Website:** Landing page, about, pricing, features pages via WebFetch
- **User interview:** 3-5 targeted questions to fill gaps that couldn't be extracted

**Error handling:** If a source fails (WebFetch blocked, no README, no codebase), note which source was unavailable and continue with remaining sources. If the presentation type is "General" or ambiguous, fold type clarification into the interview questions rather than running a separate step. Budget is 3-5 questions total, including any type-clarification question. At minimum, the interview phase must run — a deck can always be built from conversation alone.

Output: Internal **Source Brief** — key facts, metrics, differentiators, pain points, competitive positioning.

### Phase 2 — Strategic Blueprint

Define the presentation strategy:

- **Objective:** What should the audience do after seeing this?
- **Target audience:** Who are they, what do they care about?
- **Key message:** One sentence the audience should remember
- **The ask:** What are you requesting? (funding, approval, adoption, etc.)
- **Narrative arc:** Story structure from the appropriate framework

Output: **Presentation Strategy** — the five elements above, used as input for Phase 3.

### Phase 3 — Slide Outline (Approval Gate)

Present slide-by-slide outline for user approval:

```
Slide 1: [Title] — "Key message for this slide"
Slide 2: [Problem] — "Key message for this slide"
...
```

User must approve before rendering. If rejected, loop back to Phase 2. Max 3 revision loops — after 3 rejections, offer "start over from scratch" or "abort."

**Slide count check:** If the outline exceeds 25 slides, surface the recommendation to split into multiple decks here, before proceeding.

### Phase 4 — Style Confirmation

Recommend visual style based on presentation type:

| Type | Default style |
|---|---|
| Pitch deck | Dark, bold, high-contrast |
| Technical overview | Clean, structured with diagrams |
| Project update | Data-heavy, metric-focused |

Present recommendation. User confirms or redirects. Phase 4 outputs a style label and parameters (palette name, font preferences, layout density) that are passed to the pptx skill in Phase 5 — no intermediate document is produced.

### Phase 5 — Render & Review

Delegate to `document-skills:pptx`:
1. Generate HTML per slide following the pptx skill's html2pptx conventions (see `html2pptx.md` in the pptx skill for format details)
2. Convert to .pptx via the pptx skill's pipeline
3. Present result for final review

**No incremental updates.** Each invocation produces one complete deck. To modify, re-run the skill.

**Rendering errors** are surfaced by the pptx skill's own error handling. This skill does not retry rendering automatically — fix the issue and re-run.

## Narrative Frameworks

### Pitch Deck (Problem → Solution → Why Now)

1. Hook / Opening statement
2. Problem — pain point with data
3. Solution — what you've built
4. How it works — 2-3 slides max
5. Traction / Validation — metrics, users, revenue
6. Market opportunity — TAM/SAM/SOM or growth data
7. Business model — how you make money
8. Competition / Differentiators
9. Team — why this team wins
10. The Ask — specific request with use of funds

### Technical Overview (Context → Architecture → Depth)

1. What is this and why does it exist
2. High-level architecture
3. Key components (3-5 slides)
4. Data flow / interactions
5. Tech stack and decisions
6. Performance / scale characteristics
7. Getting started / integration points
8. Roadmap

### Project Update (Status → Detail → Next)

1. Executive summary — one slide, traffic-light status
2. Key accomplishments this period
3. Metrics / KPIs
4. Risks and blockers
5. Next steps / upcoming milestones

Frameworks are defaults. The skill adapts based on source material — if data is missing for a slide, skip it rather than generating fluff.

## File Structure

```
presentation-blueprint/
  SKILL.md                    # Main skill — workflow, phases, guardrails
  narrative-frameworks.md     # 3 story structures + adaptation rules
  slide-archetypes.md         # Common slide patterns (title, data, comparison, quote)
  source-analysis.md          # Extraction patterns for codebases, websites, interviews
```

### Rationale

- **SKILL.md** stays lean — focused on the 5-phase workflow and guardrails
- **narrative-frameworks.md** (~200 lines) — heavy reference, loaded during Phase 2
- **slide-archetypes.md** — bridges blueprint to rendering. Expected archetypes: title, section divider, problem/pain, solution, metric/KPI, comparison (2-col or vs.), quote/testimonial, team/people, diagram/architecture, bullet list, image-heavy, CTA/ask
- **source-analysis.md** — what to look for in README vs package.json vs landing page

### What we don't include

- No rendering scripts (delegated to pptx skill)
- No color palettes (pptx skill has 18 built-in)
- No HTML/CSS templates (generated dynamically per deck)

## Guardrails

### Prerequisite check
First action: verify `document-skills:pptx` is available. If not, provide install instructions and stop.

### Content safety
- Never fabricate metrics or data. If not in source material, skip the slide or ask the user.
- Never include confidential-looking content (API keys, passwords, internal URLs) found during analysis — flag to user instead.
- If source material is thin, lean on the interview phase rather than generating fluff.

### Quality gates
- Phase 3 outline approval is mandatory — never skip to rendering
- Phase 4 style confirmation is mandatory — never assume
- If user rejects outline, loop to Phase 2 (strategy), not Phase 1 (analysis)

### Scope limits
- Max 25 slides — if more needed, recommend splitting into multiple decks
- One deck per invocation

## Speaker Notes

Not generated by default. These decks are designed to be shared async and stand on their own. Speaker notes can be generated separately if needed.

## Visual Style Defaults

The skill recommends a style, user confirms. Rendering details (palettes, typography, layout) are handled by the pptx skill's design system.

| Presentation type | Recommended style |
|---|---|
| Pitch deck | Dark, bold, high-contrast (Apple keynote aesthetic) |
| Technical overview | Clean corporate with diagram emphasis |
| Project update | Data-heavy, metric-focused with traffic-light indicators |
