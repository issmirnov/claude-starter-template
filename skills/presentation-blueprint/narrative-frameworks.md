# Narrative Frameworks

Reference file for Phase 2 (Strategic Blueprint). Contains three story structures with per-slide specifications and cross-cutting adaptation rules. The skill selects the matching framework based on detected presentation type, then adapts it to the source material available.

All frameworks target async-first decks: every slide must be self-explanatory without a presenter.

---

## Framework 1: Pitch Deck (Problem → Solution → Why Now)

**Default slide count:** 10
**Best for:** Investor pitches, partnership proposals, grant applications, internal venture proposals.
**Narrative arc:** Establish urgency around a problem, present a credible solution, prove momentum, make a specific ask.

### Slide 1 — Hook / Opening Statement

- **Purpose:** Capture attention in the first three seconds. Set the emotional or intellectual frame for everything that follows.
- **Required content:** A single bold claim, surprising statistic, or provocative question that encapsulates the core thesis. Optionally a short tagline or one-liner describing the venture.
- **Adaptation rule:** Always include. If the source lacks a punchy hook, synthesize one from the problem statement.

### Slide 2 — Problem

- **Purpose:** Make the audience feel the pain point so they care about the solution. Ground the problem in evidence, not opinion.
- **Required content:** Clear description of the problem. Quantified impact (cost, time lost, people affected). Who experiences this pain and how often.
- **Adaptation rule:** Always include. If data is missing, use qualitative framing (quotes, scenarios) but flag to the user that adding hard numbers would strengthen the slide.

### Slide 3 — Solution

- **Purpose:** Present what has been built and the core value proposition. Connect directly back to the problem on the previous slide.
- **Required content:** One-sentence value proposition. High-level description of the product or service. Visual or diagram if available. Clear before/after contrast.
- **Adaptation rule:** Always include. If the source describes multiple products, pick the primary one and mention others in a footnote or sub-bullet.

### Slide 4 — How It Works (expands to 2-3 slides)

- **Purpose:** Give enough concrete detail for the audience to believe the solution is real and feasible, without overwhelming them.
- **Required content:** Product walkthrough, architecture sketch, or workflow diagram. Key features mapped to user benefits. Screenshots or mockups if available.
- **Adaptation rule:** Use 2 slides if the product is simple or early-stage. Expand to 3 if the source provides rich feature detail or the mechanism is non-obvious. Never exceed 3.

### Slide 5 — Traction / Validation

- **Purpose:** Prove that this is not just an idea — there is evidence of demand or progress.
- **Required content:** Metrics (users, revenue, growth rate, retention). Logos of customers or partners. Key milestones reached with dates. Testimonials or case study highlights.
- **Adaptation rule:** Skip if pre-launch with zero traction data. If limited traction exists (waitlist, LOIs, pilot results), include the slide with what is available and label metrics clearly. If the venture is pre-revenue but has user data, focus on engagement metrics.

### Slide 6 — Market Opportunity

- **Purpose:** Show the opportunity is large enough to justify investment or commitment.
- **Required content:** TAM / SAM / SOM figures with sources, or credible market growth data. Trends that create tailwinds. Why now — what changed to make this possible or urgent.
- **Adaptation rule:** Always include unless the presentation is purely internal. If TAM/SAM/SOM data is unavailable, use a bottom-up market sizing approach from available data and note the methodology. Merge with Business Model (Slide 9) if both slides would be thin.

### Slide 7 — Business Model

- **Purpose:** Explain how the venture makes (or will make) money. Demonstrate unit economics awareness.
- **Required content:** Revenue model (subscription, transactional, marketplace, etc.). Pricing structure or tiers. Unit economics if available (CAC, LTV, margins). Path to profitability or sustainability.
- **Adaptation rule:** Always include for investor-facing decks. If unit economics data is missing, describe the revenue model qualitatively and flag the gap. Merge with Market Opportunity (Slide 8) if content is thin for both.

### Slide 8 — Competition / Differentiators

- **Purpose:** Acknowledge the competitive landscape honestly and articulate a defensible position.
- **Required content:** Competitor landscape (matrix, quadrant, or simple list). Key differentiators — what you do that others cannot easily replicate. Moats (technology, data, network effects, regulatory).
- **Adaptation rule:** Always include. If the source names no competitors, frame as category creation with adjacent alternatives. Never claim "no competition" — reframe as "different approach to the same problem."

### Slide 9 — Team

- **Purpose:** Build confidence that this team can execute. Especially important when traction is early.
- **Required content:** Key team members with relevant experience. Advisors or board members if notable. Domain expertise that maps to the problem. Gaps acknowledged with hiring plans.
- **Adaptation rule:** Always include for external audiences. For internal presentations where the team is known, skip or reduce to a single bullet. If team bios are absent from source, include the slide as a placeholder with a note to the user.

### Slide 10 — The Ask

- **Purpose:** End with a clear, specific call to action. Never leave the audience wondering what you want.
- **Required content:** Specific request (amount of funding, type of partnership, decision needed). Use of funds breakdown or next steps. Timeline. Contact information.
- **Adaptation rule:** Always include. If the ask is undefined in the source, create the slide structure and flag to the user that they must fill in the specifics.

---

## Framework 2: Technical Overview (Context → Architecture → Depth)

**Default slide count:** 8 (expandable to 15-20)
**Best for:** Engineering presentations, system design reviews, developer evangelism, technical due diligence, onboarding material.
**Narrative arc:** Establish context and motivation, zoom into architecture, go deep on key areas, zoom back out to practical next steps.

### Slide 1 — What Is This and Why Does It Exist

- **Purpose:** Anchor the audience with a crisp definition and the motivating problem. Technical audiences still need the "why" before the "how."
- **Required content:** One-paragraph system description. The problem or need it addresses. Scope boundaries — what this system is and is not responsible for.
- **Adaptation rule:** Always include. If the source jumps straight into architecture, synthesize the motivation from context clues and flag for user review.

### Slide 2 — High-Level Architecture

- **Purpose:** Provide the mental map that every subsequent slide will reference. The audience should be able to locate any component discussed later.
- **Required content:** Architecture diagram (block diagram, C4 context/container, or equivalent). Labels for all major components. Arrows showing primary data/control flow. External system boundaries clearly marked.
- **Adaptation rule:** Always include. If no diagram exists in the source, describe components and relationships textually and flag that a diagram should be added. If the source contains multiple diagrams at different zoom levels, use the highest-level one here and save detail for later slides.

### Slides 3-7 — Key Components (3-5 slides)

- **Purpose:** Deep-dive into the most important subsystems. Each slide should be self-contained enough to understand independently but reference the architecture slide for context.
- **Required content per component slide:** Component name and responsibility. Internal design (patterns, algorithms, data structures). Interfaces — inputs, outputs, APIs. Key design decisions and their rationale. Tradeoffs acknowledged.
- **Adaptation rule:** Use 3 slides for simple systems. Expand to 5 for complex systems with many distinct subsystems. Select components by importance, not exhaustiveness — cover what the audience needs to understand, not every microservice. If the source is thin on a component, merge it with a related one.

### Slide 8 — Data Flow / Interactions

- **Purpose:** Show how components work together at runtime. Move from static architecture to dynamic behavior.
- **Required content:** Sequence diagram, data flow diagram, or annotated request lifecycle. Key scenarios walked through (happy path, critical error path). Latency or timing annotations if available.
- **Adaptation rule:** Always include. If the system has a single dominant flow, one slide suffices. If there are multiple important flows (e.g., read path vs. write path), expand to 2 slides. Skip if the system is a single-component library with no meaningful internal flow.

### Slide 9 — Tech Stack and Decisions

- **Purpose:** Document technology choices and the reasoning behind them. Essential for onboarding and for evaluating technical risk.
- **Required content:** Languages, frameworks, databases, infrastructure. For each major choice: why it was selected over alternatives. Version constraints or compatibility notes if relevant.
- **Adaptation rule:** Always include. If the source lists technologies without rationale, present the stack and note that decision rationale should be added. Merge with Performance (Slide 10) if both are thin.

### Slide 10 — Performance / Scale Characteristics

- **Purpose:** Set expectations for operational behavior. Critical for technical due diligence and capacity planning.
- **Required content:** Key performance metrics (throughput, latency, resource usage). Scale limits — tested or theoretical. Bottlenecks and mitigation strategies. SLA/SLO targets if defined.
- **Adaptation rule:** Skip if the system is pre-production with no performance data. Include with projections if the source provides design targets but no measurements. Merge with Tech Stack (Slide 9) if content is thin.

### Slide 11 — Getting Started / Integration Points

- **Purpose:** Make the presentation actionable. The audience should know how to engage with the system after this slide.
- **Required content:** Quick-start steps or integration guide. API surface summary. Authentication and access requirements. Links to documentation, repos, or sandboxes.
- **Adaptation rule:** Always include for developer-facing presentations. Skip for executive technical reviews where the audience will not directly interact with the system. If integration details are missing, include as a placeholder.

### Slide 12 — Roadmap

- **Purpose:** Show where the system is heading. Helps the audience evaluate long-term viability and plan their own work accordingly.
- **Required content:** Planned features or improvements with rough timelines. Known technical debt items. Migration or deprecation plans. Open questions or areas seeking input.
- **Adaptation rule:** Always include. If no roadmap exists in the source, create the slide with a "Roadmap TBD" note and flag to the user. For stable/mature systems, reframe as "Maintenance and Evolution."

---

## Framework 3: Project Update (Status → Detail → Next)

**Default slide count:** 5
**Best for:** Sprint reviews, steering committee updates, board updates, stakeholder check-ins, monthly reports.
**Narrative arc:** Lead with the headline (are we on track?), support with evidence, surface risks early, close with forward momentum.

### Slide 1 — Executive Summary

- **Purpose:** Give the audience the answer before the explanation. A busy executive should be able to read this one slide and know the project status.
- **Required content:** Project name and reporting period. Traffic-light status (Green / Amber / Red) for overall health. One-sentence status summary per workstream or objective. Key headline: the single most important thing to know right now.
- **Adaptation rule:** Always include. This slide is mandatory even if the rest of the deck is cut. If the source does not specify a traffic-light status, infer from the data and flag the inference to the user.

### Slide 2 — Key Accomplishments This Period

- **Purpose:** Document what was delivered. Builds confidence and creates accountability.
- **Required content:** 3-7 accomplishments, each with a concrete outcome (not just activity). Mapped to goals or OKRs where possible. Dates of completion. Impact quantified where data exists.
- **Adaptation rule:** Always include. If the source lists activities without outcomes, reframe as accomplishments and flag that outcome data would strengthen the slide. If there are more than 7 items, prioritize by impact and move the rest to an appendix.

### Slide 3 — Metrics / KPIs

- **Purpose:** Provide objective evidence of progress. Let the data tell the story.
- **Required content:** 3-6 key metrics with current values. Trend direction (up/down/flat) and comparison to target or previous period. Visualizations (charts, sparklines) where possible. Brief interpretation of what the numbers mean.
- **Adaptation rule:** Skip if no quantitative data exists in the source — do not fabricate metrics. If only partial metrics are available, include what exists and note gaps. Merge with Accomplishments (Slide 2) if metrics are few and directly tied to accomplishments.

### Slide 4 — Risks and Blockers

- **Purpose:** Surface problems early. Demonstrates mature project management and gives stakeholders a chance to help.
- **Required content:** Active risks with likelihood and impact assessment. Current blockers with owner and age (how long blocked). Mitigations in progress or proposed. Escalations needed — what the audience can do to help.
- **Adaptation rule:** Always include. If there are no risks or blockers, say so explicitly (one line: "No active risks or blockers this period") — the slide's presence signals that risks were considered. If the source lists risks without mitigations, include the risks and flag that mitigation plans are needed.

### Slide 5 — Next Steps / Upcoming Milestones

- **Purpose:** Set expectations for the next period. Create forward momentum and accountability.
- **Required content:** 3-5 planned deliverables for the next period. Key milestones with target dates. Dependencies or prerequisites. Decisions needed from the audience.
- **Adaptation rule:** Always include. If next steps are vague in the source, include what exists and flag that specificity (dates, owners, deliverables) would improve the slide.

---

## General Adaptation Rules

These rules apply across all three frameworks and govern how the skill adapts a framework to the actual source material.

### Missing Data — Skip, Don't Fabricate

When source material lacks the content required for a slide, skip the slide entirely rather than generating filler. Mark skipped slides in the outline delivered to the user so they can provide the missing information if desired. Exception: slides marked "Always include" above should remain as placeholders with a clear note about what is needed.

### Thin Source — Merge Related Slides

When two adjacent slides would each have only 1-2 bullets, merge them into a single slide with a combined title (e.g., "Market Opportunity and Business Model"). Preserve the narrative order — the content from the earlier slide comes first. Never merge more than two slides into one; if three consecutive slides are thin, keep the most important as standalone and merge the other two.

### Rich Source — Expand Key Slides

When the source provides deep content for a topic, expand that slide into 2-4 slides rather than cramming. Typical expansion points:
- **Pitch Deck:** How It Works (slides 4-6), Traction (split by channel or cohort)
- **Technical Overview:** Key Components (up to 5), Data Flow (multiple scenarios)
- **Project Update:** Accomplishments (split by workstream), Metrics (dedicated slide per metric with charts)

### Cross-Framework Borrowing

When a presentation of one type needs depth from another framework, borrow slides:
- A Pitch Deck needing technical depth: insert 1-2 slides from Technical Overview (Architecture, Key Component) after the "How It Works" section.
- A Technical Overview needing business context: insert Market Opportunity or Business Model from Pitch Deck before the Roadmap.
- A Project Update needing strategic framing: prepend a Problem + Solution pair from Pitch Deck before the Executive Summary.

Borrowed slides should be adapted to match the host framework's tone and depth level.

### Slide Count Guard

After adaptation, compare the resulting slide count to the framework default:
- **Within default range:** Proceed without comment.
- **Exceeds default by up to 50%:** Proceed but note the expansion in the outline with justification.
- **Exceeds default by more than 50%:** Flag to the user. Suggest which slides to cut or merge to bring the count closer to the default. Do not silently produce an oversized deck.

### Frameworks Are Defaults, Not Rigid Templates

These frameworks provide a proven starting structure. The skill should adapt, reorder, merge, expand, or skip slides based on the source material and the user's stated goals. The goal is a clear, persuasive, self-standing narrative — not rigid adherence to a template. When deviating significantly from a framework, note the deviation and reasoning in the outline.
