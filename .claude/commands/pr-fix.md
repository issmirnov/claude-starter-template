---
description: Iteratively address PR feedback and CI failures until the PR is clean
---

# PR Fix Command

You are entering an autonomous loop that drives a pull request to a clean state. Each round: read CI status + all reviewer feedback, fix what's blocking, commit, push, wait for new signal, repeat.

## Prerequisites

The current branch MUST have an open PR. Verify with `gh pr view --json number,state,headRefName`. If no PR exists, tell the user to run `/pr` first and stop.

## Process

### Step 1: Identify the PR

Capture once and reuse throughout the loop:

```
PR_NUMBER=$(gh pr view --json number -q .number)
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
```

### Step 2: Run the Fix Loop

Execute up to **5 iterations**. Each iteration is one full read → fix → push → wait cycle.

#### 2a. Read PR state (all five surfaces)

You MUST fetch all of these every round — feedback lives in different endpoints and silently dropping any one of them is the most common failure mode of this command:

1. **CI checks** — pass/fail/pending status for every workflow:
   ```
   gh pr checks $PR_NUMBER
   ```
   For a failing check, fetch logs:
   ```
   gh run view <run-id> --log-failed
   ```

2. **Issue comments** — PR-level comments. **This is where architect-gate posts the SAR review summary.**
   ```
   gh api repos/$REPO/issues/$PR_NUMBER/comments
   ```

3. **Review comments** — inline diff comments. **This is where Codex and inline human reviewers post.** If you skip this endpoint, you will silently miss Codex feedback entirely.
   ```
   gh api repos/$REPO/pulls/$PR_NUMBER/comments
   ```

4. **Reviews** — top-level review bodies (approvals, request-changes, review summaries):
   ```
   gh api repos/$REPO/pulls/$PR_NUMBER/reviews
   ```

5. **Last-commit timestamp** — anchor for distinguishing addressed vs. unaddressed feedback:
   ```
   git log -1 --format=%cI
   ```

#### 2b. Classify the signal

For each piece of feedback, decide:

- **Already addressed** — `created_at` is older than the last commit on the branch AND the diff visibly resolves it. Skip.
- **Blocking** — SAR severity ≥ 3, explicit "request changes" review, failing CI check, Codex inline comment flagging correctness/security/architecture. Must fix.
- **Nice-to-have** — style nits, optional suggestions, low-severity SAR notes. Defer and report at the end.

CI status that is still **pending** is not a failure — proceed to 2d (wait).

#### 2c. Apply fixes

For each blocking item:

1. Make the code change.
2. Reference the specific comment/check being addressed in the commit message body.

When all blocking items in this round are fixed, commit and push using the same pattern as `/pr`:

```
git add <files>
git commit -m "$(cat <<'EOF'
fix: address PR feedback (round N)

- [item 1 — link to comment or check]
- [item 2 — link to comment or check]

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
git push
```

#### 2d. Wait for new signal

After pushing (or if no fixes were needed because everything is pending), wait for CI and reviewers to respond:

```
sleep 60
```

Then re-run `gh pr checks $PR_NUMBER` until the status changes from the previous round (new run started, or new comments appeared). Cap the wait at 10 minutes per round — if nothing has changed after 10 minutes, bail and report.

#### 2e. Exit conditions

Stop the loop when **all three** hold:

- `gh pr checks` reports every check as `pass` (no `pending`, no `fail`)
- No blocking feedback newer than the most recent commit exists across all three comment endpoints
- The most recent review (if any) is not `CHANGES_REQUESTED`

If you hit 5 iterations without converging, stop and report the remaining blockers.

**IMPORTANT:** Work silently through iterations — do NOT spam the user with per-round status. Only emit the final summary in Step 3.

### Step 3: Report

After the loop exits, present:

#### Final Status
- **PR:** #$PR_NUMBER ($PR_URL)
- **Outcome:** `clean` | `blocked after N rounds` | `timed out waiting for CI`
- **Iterations:** N of 5
- **Final check status:** [output of `gh pr checks`]

#### Fixes Applied
- Round 1: [list of commits + what they addressed]
- Round 2: ...

#### Deferred (Nice-to-Haves Not Addressed)
- [suggestion]: [why deferred — usually "non-blocking" or "needs user judgment"]

#### Remaining Blockers (if outcome ≠ clean)
- [item]: [why it couldn't be auto-resolved — e.g., needs human decision, ambiguous, requires infra change]

## Important Notes

- **Always read all three comment endpoints.** Issue comments alone miss Codex; review comments alone miss the SAR. The pattern is non-negotiable.
- **Anchor on commit timestamp** to avoid re-fixing already-addressed feedback in subsequent loops.
- **Never force-push** unless the user explicitly asks. Normal pushes only.
- **Never skip hooks** (`--no-verify`). If a pre-commit hook fails, fix the underlying issue.
- If feedback is ambiguous or requires a product/architecture decision, defer it and surface in the final report — do not guess.
- The architect-gate SAR uses severity 1–5. Treat ≥ 3 as blocking; 1–2 as nice-to-have.
