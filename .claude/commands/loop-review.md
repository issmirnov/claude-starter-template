---
description: Iteratively refine the current plan through senior architect review loops
---

# Loop Review Command

You are initiating an iterative plan refinement loop. A senior software architect will review the current plan through multiple rounds until it meets a quality threshold.

## Prerequisites

There MUST be a plan in the current conversation context. If no plan exists, tell the user to run `/plan` first and stop.

## Process

### Step 1: Capture the Current Plan

Identify the most recent plan from the conversation. This is the plan that was presented to the user — including phases, steps, files, testing strategy, etc.

### Step 2: Run the Review Loop

Execute up to 3 review iterations. On each iteration, use the Agent tool with the following:

**Agent role:** You are a senior software architect (principal-level) performing a rigorous review of an implementation plan. You are critical, precise, and care deeply about quality.

**Agent prompt (include the full plan text in each call):**

```
You are a senior software architect reviewing an implementation plan. Be rigorous and critical.

## The Plan to Review

[INSERT FULL PLAN HERE]

## Project Context

Read these files for project context before reviewing:
- CLAUDE.md
- .claude/memory-bank/systemPatterns.md
- .claude/memory-bank/techContext.md
- .claude/memory-bank/activeContext.md

## Review Dimensions

Evaluate the plan on ALL of these dimensions:

1. **Completeness** — Are there missing steps, unhandled edge cases, or gaps?
2. **Sequencing** — Are steps in the right dependency order? Are there parallelism opportunities being missed?
3. **Risk Assessment** — What could go wrong? Are failure modes addressed?
4. **Scope Discipline** — Is there over-engineering, unnecessary complexity, or scope creep?
5. **Pattern Alignment** — Does the plan follow the project's established patterns and conventions?
6. **Testability** — Is the testing strategy adequate? Are success criteria verifiable?

## Output Format

You MUST respond in EXACTLY this format:

### Score: [1-10]

### Must-Fix (blocking issues that must be resolved)
- [issue]: [specific suggestion to fix it]

### Suggestions (non-blocking improvements)
- [suggestion]: [rationale]

### Approved (things done well)
- [good aspect]: [why it works]

### Refined Plan
[If score < 8, provide the COMPLETE refined plan with all fixes applied. Do not provide a partial plan or just the changes — output the full plan ready to use.]
[If score >= 8, write "Plan approved as-is." and do not rewrite it.]
```

**Loop logic:**
- After each agent call, check the score
- If score >= 8: stop looping, the plan is approved
- If score < 8: take the "Refined Plan" from the agent's response and feed it back as the new plan for the next iteration
- If you hit 3 iterations without reaching 8, stop and use the latest refined version

**IMPORTANT:** Do NOT show the user any intermediate output. Work silently through the iterations.

### Step 3: Present Final Results

Once the loop completes, present the user with:

#### Final Plan
Show the final approved/refined plan in full.

#### Review Summary
Compile a summary across ALL iterations:

**Iterations completed:** [N] of 3 max
**Final score:** [score]

**All fixes applied (across all rounds):**
- [fix 1]
- [fix 2]
- ...

**All suggestions incorporated:**
- [suggestion 1]
- [suggestion 2]
- ...

**Suggestions deferred (not incorporated — for user to decide):**
- [suggestion]: [rationale why it was left out or needs user input]

**Strengths confirmed:**
- [strength 1]
- [strength 2]

### Step 4: Ask for Approval

Ask the user if they want to:
1. **Accept** the refined plan and proceed with implementation
2. **Run another loop** (resets the iteration counter)
3. **Manually adjust** specific parts before proceeding

## Important Notes

- The architect subagent MUST read project context files before reviewing
- Each iteration feeds the COMPLETE refined plan forward, not just diffs
- Keep iterations silent — only the final output is shown to the user
- If the plan scores 8+ on the first pass, that's fine — show the results and move on
- The architect should be constructively critical, not nitpicky — focus on real issues that would cause problems during implementation
