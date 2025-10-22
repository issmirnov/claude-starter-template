---
description: Project configuration and memory bank system for Claude Code
alwaysApply: true
---

# Project Configuration

This file contains project-specific intelligence and configuration for Claude Code sessions.

## Memory Bank System

This project uses a Memory Bank system to maintain context across sessions. All memory files are stored in `.claude/memory-bank/` and should be read at the start of every conversation.

### Core Memory Files (Read these in order):
1. **memory-rules.md** - System documentation
2. **projectbrief.md** - Foundation document
3. **productContext.md** - Product vision
4. **systemPatterns.md** - Architecture patterns
5. **techContext.md** - Technical setup
6. **activeContext.md** - Current work focus
7. **progress.md** - Status tracking

## Instructions for Claude

### On Every Session Start:
1. **Read all core memory bank files** in the order listed above
2. Verify understanding of current context
3. Check activeContext.md for immediate priorities
4. Review progress.md to understand what's complete and what's pending

### When User Says "update memory bank":
1. **Review ALL memory bank files** (mandatory - don't skip any)
2. Update files that need changes based on recent work
3. Pay special attention to activeContext.md and progress.md
4. Document any new patterns discovered
5. Update project intelligence in this file if needed

### Planning Mode (via /plan command):
1. Read Memory Bank (automatic)
2. Verify context completeness
3. Ask 4-6 clarifying questions based on findings
4. Draft comprehensive plan
5. Get user approval
6. Implement systematically

## Project Intelligence

This section grows as patterns and preferences are discovered during work on this project.

### Project-Specific Patterns
[Document patterns as they emerge]

### User Preferences
[Document user's working style and preferences]

### Lessons Learned
[Document key insights from work sessions]

### Known Gotchas
[Document tricky areas or common pitfalls]

### Effective Approaches
[Document what works well for this project]

---

## Notes

- Memory Bank files are in `.claude/memory-bank/`
- Templates are provided - fill them out based on actual project
- Update frequently to maintain accuracy
- The Memory Bank is the primary context system for this project
