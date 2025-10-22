# Claude Code Memory Bank Template

A comprehensive template repository that implements a Memory Bank system for maintaining project context across Claude Code sessions. This template solves the fundamental challenge of AI memory resets by providing structured documentation that serves as institutional memory for your projects.

## Table of Contents

- [Why This Template?](#why-this-template)
- [What's Included](#whats-included)
- [Quick Start](#quick-start)
- [How It Works](#how-it-works)
- [Usage Guide](#usage-guide)
- [Memory Bank Files](#memory-bank-files)
- [Best Practices](#best-practices)
- [Advanced Usage](#advanced-usage)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## Why This Template?

Claude Code's memory resets completely between sessions. While this ensures privacy and clean starts, it means Claude has no context about your project when starting a new conversation. This template solves that problem by providing:

- **Structured Documentation**: Pre-built templates for capturing project context
- **Automatic Context Loading**: Claude reads your memory bank at every session start
- **Planning Workflows**: Built-in `/plan` command for structured feature development
- **Project Intelligence**: System that learns and captures project-specific patterns
- **Continuity**: Maintain context across unlimited session resets

### The Problem This Solves

Without a memory system:
- ❌ You re-explain your project every session
- ❌ Context is lost between conversations
- ❌ Claude doesn't learn project patterns
- ❌ Implementation decisions aren't documented
- ❌ Progress tracking is manual and error-prone

With this template:
- ✅ Claude has full project context immediately
- ✅ Knowledge accumulates over time
- ✅ Patterns and preferences are learned
- ✅ Decisions are documented with rationale
- ✅ Progress is tracked systematically

## What's Included

This template provides a complete memory bank infrastructure:

```
.claude/
├── claude.md                    # Main configuration & project intelligence
├── commands/
│   └── plan.md                  # /plan command for structured planning
└── memory-bank/
    ├── QUICKSTART.md            # Quick start guide
    ├── memory-rules.md          # Complete system documentation
    ├── projectbrief.md          # Foundation document (template)
    ├── productContext.md        # Product vision (template)
    ├── systemPatterns.md        # Architecture patterns (template)
    ├── techContext.md           # Tech stack & setup (template)
    ├── activeContext.md         # Current work focus (template)
    └── progress.md              # Status tracking (template)
```

### Key Components

1. **Configuration** (`.claude/claude.md`)
   - Automatic memory loading via `alwaysApply: true`
   - Project intelligence journal
   - Instructions for Claude on how to use the system

2. **Planning Command** (`.claude/commands/plan.md`)
   - Structured feature planning workflow
   - Automatic memory review
   - Clarifying questions before implementation

3. **Memory Bank** (`.claude/memory-bank/`)
   - 6 core template files for project documentation
   - Complete system documentation
   - Quick start guide

## Quick Start

### 1. Use This Template

Click "Use this template" on GitHub or clone this repository:

```bash
git clone https://github.com/yourusername/claude-code-memory-bank-template.git my-project
cd my-project
rm -rf .git  # Remove template git history
git init     # Start fresh
```

### 2. Fill Out Your Project Brief

Start by editing `.claude/memory-bank/projectbrief.md`:

```bash
# Open in your editor
code .claude/memory-bank/projectbrief.md
```

Fill in:
- Project name and purpose
- Core goals
- Scope (in/out of scope)
- Success criteria
- Constraints
- Key stakeholders

**This is your most important file** - everything else builds on it.

### 3. Complete Other Core Files

Work through each template file:

1. **productContext.md** - Why your project exists, who it's for
2. **systemPatterns.md** - How it's architected, key patterns
3. **techContext.md** - Tech stack, setup instructions
4. **activeContext.md** - What you're working on now
5. **progress.md** - What's done, what's left

Don't worry about perfection - these files evolve with your project.

### 4. Start Using Claude Code

Open Claude Code in your project directory:

```bash
claude
```

Claude will automatically read your memory bank and have full context. Try:

```
What does this project do?
```

Claude should answer based on your memory bank files!

### 5. Use the Planning Workflow

When starting a new feature:

```
/plan
```

Claude will:
1. Review all memory bank files
2. Ask 4-6 clarifying questions
3. Draft a comprehensive plan
4. Execute systematically with your approval

## How It Works

### Automatic Context Loading

The `.claude/claude.md` file has `alwaysApply: true` configured, which means:

1. **Every Session Start**: Claude automatically reads the instructions in `claude.md`
2. **Memory Bank Loading**: Instructions tell Claude to read all memory bank files in order
3. **Immediate Context**: Claude has full project understanding without you explaining anything

### File Hierarchy

Files build upon each other logically:

```
projectbrief.md (Foundation)
    ├── productContext.md (Why it exists)
    ├── systemPatterns.md (How it's built)
    └── techContext.md (What technologies)
        └── activeContext.md (Current state - synthesizes all)
            └── progress.md (Tracks active context over time)
```

### Update Workflow

When you've made significant changes:

```
update memory bank
```

Claude will:
1. Review **ALL** memory bank files (mandatory)
2. Update files that need changes
3. Focus on `activeContext.md` and `progress.md`
4. Document new patterns in `claude.md`

## Usage Guide

### Starting a New Session

Just open Claude Code - memory loads automatically:

```bash
claude
```

Claude now has full context. Start working immediately:

```
Let's continue with the authentication feature
```

### Planning a Feature

Use structured planning for complex work:

```
/plan

I want to add user authentication with OAuth
```

Claude will:
- Review memory bank
- Ask clarifying questions (OAuth provider? Token storage? Session management?)
- Draft comprehensive plan
- Get your approval
- Execute systematically

### Daily Workflow

1. **Start Session**: Open Claude Code (context loads automatically)
2. **Check Context**: Claude references `activeContext.md` for current priorities
3. **Work**: Implement features, fix bugs, refactor
4. **Update**: Say "update memory bank" after significant changes
5. **Plan Next**: Use `/plan` for next major feature

### Documenting as You Go

Update relevant files during development:

- **Making architectural decisions?** → Update `systemPatterns.md`
- **Adding dependencies?** → Update `techContext.md`
- **Completing features?** → Update `progress.md`
- **Switching focus?** → Update `activeContext.md`

Say "update memory bank" and Claude will help you document.

## Memory Bank Files

### projectbrief.md
**Purpose**: Foundation document
**Update Frequency**: Rarely (only when project scope changes)
**Contains**: Goals, scope, constraints, success criteria

This is your source of truth. All other files derive from it.

### productContext.md
**Purpose**: Product vision and user experience
**Update Frequency**: Occasionally (when product direction shifts)
**Contains**: Problems solved, user workflows, requirements

Answers "why does this exist?" and "who is it for?"

### systemPatterns.md
**Purpose**: Architecture and technical patterns
**Update Frequency**: Regularly (as patterns emerge)
**Contains**: Architecture, design patterns, technical decisions, critical paths

Include code examples and file references with line numbers.

### techContext.md
**Purpose**: Technology stack and setup
**Update Frequency**: When adding/removing dependencies
**Contains**: Tech stack, dependencies, setup instructions, infrastructure

Your technical reference manual.

### activeContext.md
**Purpose**: Current work focus
**Update Frequency**: Very frequently (after every significant change)
**Contains**: Current focus, recent changes, next steps, decisions in progress

Your most dynamic file - reflects immediate state.

### progress.md
**Purpose**: Status tracking
**Update Frequency**: Frequently (as features complete)
**Contains**: Completed work, in-progress items, planned features, known issues

Shows project health and what's left to build.

## Best Practices

### 1. Start with the Brief

Fill out `projectbrief.md` thoroughly before other files. It's your foundation.

### 2. Keep activeContext.md Current

This is your most important file for day-to-day work. Update it frequently:
- After implementing features
- When changing focus
- When making important decisions
- When encountering challenges

### 3. Be Specific

Vague documentation is worse than no documentation:

❌ **Bad**: "Fixed the bug in the auth system"
✅ **Good**: "Fixed OAuth token refresh race condition in `src/auth/token-manager.ts:156` by adding mutex lock"

### 4. Include File References

Always include file paths with line numbers:

```markdown
Authentication is handled in `src/auth/oauth.ts:45-120`
```

This helps Claude (and humans) find the code quickly.

### 5. Document the Why

Don't just document what you did - document why:

❌ **Bad**: "Using PostgreSQL"
✅ **Good**: "Using PostgreSQL because we need ACID transactions for financial data and team has expertise"

### 6. Update Regularly

Don't let memory bank get stale. Update after:
- Completing features
- Making architectural decisions
- Discovering new patterns
- Changing dependencies
- Shifting focus

### 7. Review Periodically

Set a reminder to review all memory bank files monthly to ensure accuracy.

### 8. Use the Planning Workflow

For complex features, always use `/plan`:
- Ensures thorough analysis
- Clarifies requirements
- Creates systematic approach
- Tracks progress automatically

## Advanced Usage

### Adding Custom Context Files

Create additional files in `.claude/memory-bank/` for complex areas:

```
.claude/memory-bank/
├── [core files...]
├── features/
│   ├── authentication.md
│   └── payment-processing.md
├── integrations/
│   ├── stripe-api.md
│   └── sendgrid-api.md
└── testing/
    └── e2e-strategy.md
```

Reference them in `claude.md` for automatic loading.

### Custom Slash Commands

Add more commands in `.claude/commands/`:

```bash
# Create a review command
cat > .claude/commands/review.md << 'EOF'
---
description: Review and improve code quality
---

Review the codebase for:
1. Code quality issues
2. Security vulnerabilities
3. Performance optimizations
4. Documentation gaps

Provide specific recommendations with file references.
EOF
```

Use with: `/review`

### Project Intelligence Growth

The `.claude/claude.md` file grows smarter over time. Add sections like:

```markdown
## Project-Specific Patterns

### Error Handling
- Always use custom AppError class
- Include error codes and user messages
- Log with structured logging

### API Design
- RESTful conventions
- Consistent response format: {data, error, meta}
- Version all endpoints: /api/v1/...
```

Claude will learn and apply these patterns automatically.

### Team Usage

For team projects:

1. **Onboarding**: New members read memory bank to understand project
2. **Knowledge Sharing**: Memory bank is living documentation
3. **Decision History**: `systemPatterns.md` explains why things are built certain ways
4. **Consistency**: Everyone works from same understanding

## Troubleshooting

### Claude Doesn't Have Context

**Problem**: Claude asks about basic project info despite memory bank

**Solutions**:
1. Verify `.claude/claude.md` has `alwaysApply: true`
2. Check that memory bank files are filled out (not just templates)
3. Try explicitly saying "Read the memory bank first"
4. Restart Claude Code session

### Memory Bank Out of Date

**Problem**: Documentation doesn't match current code

**Solution**:
```
update memory bank
```

Then work with Claude to update each file systematically.

### Too Much Information

**Problem**: Memory bank files are overwhelming

**Solution**:
- Focus on `activeContext.md` and `progress.md` for daily work
- Keep `projectbrief.md` concise (1-2 pages max)
- Use additional context files for detailed specs
- Remember: better to have some context than none

### Planning Workflow Not Working

**Problem**: `/plan` command doesn't trigger properly

**Solutions**:
1. Verify `.claude/commands/plan.md` exists
2. Check file has proper YAML frontmatter with `description`
3. Try restarting Claude Code
4. Use alternative: just say "Let's plan this feature carefully"

## Example Workflows

### Starting a New Project

```bash
# 1. Clone template
git clone <this-repo> my-new-project
cd my-new-project

# 2. Fill out project brief
code .claude/memory-bank/projectbrief.md
# (fill in your project details)

# 3. Fill out other core files
code .claude/memory-bank/productContext.md
code .claude/memory-bank/techContext.md
# etc.

# 4. Start Claude Code
claude

# 5. Verify context
> "Explain this project to me"
# Claude should explain based on your memory bank!

# 6. Start building
> "/plan
>  Let's build the first feature"
```

### Adding a Major Feature

```bash
# 1. Open Claude Code
claude

# 2. Use planning workflow
> "/plan
>  I want to add payment processing with Stripe"

# Claude asks clarifying questions, you answer

# 3. Review and approve plan
> "Yes, let's proceed with that plan"

# 4. Claude implements systematically

# 5. Update memory bank
> "update memory bank"

# Claude updates relevant files with new patterns and progress
```

### Onboarding to Existing Project

```bash
# 1. Clone project with memory bank
git clone <project-repo>
cd <project>

# 2. Read the memory bank
cat .claude/memory-bank/projectbrief.md
cat .claude/memory-bank/productContext.md
cat .claude/memory-bank/systemPatterns.md
# etc.

# 3. Start Claude Code
claude

# 4. Ask questions
> "Walk me through the authentication flow"
> "Where is error handling implemented?"
> "What's our testing strategy?"

# Claude answers based on memory bank - you're up to speed!
```

## FAQ

### Do I need to fill out all memory bank files?

Start with `projectbrief.md` and `activeContext.md`. Add others as your project grows. Some context is better than none.

### How often should I update the memory bank?

- `activeContext.md`: After every significant change
- `progress.md`: When features complete or status changes
- Others: When architectural decisions are made or patterns emerge

### Can I use this with existing projects?

Absolutely! Just:
1. Copy `.claude/` directory to your project
2. Fill out memory bank files based on current state
3. Start using Claude Code with full context

### What if my project changes significantly?

Update `projectbrief.md` first (it's the foundation), then cascade changes to other files. Say "update memory bank" and work with Claude to revise documentation.

### Is this only for Claude Code?

While designed for Claude Code, the memory bank structure works great for:
- Human team members (excellent documentation)
- Other AI tools
- Project handoffs
- Future reference

### How is this different from comments in code?

Memory bank provides:
- High-level context and rationale
- User perspective and product vision
- Project evolution and decision history
- Current status and next steps

Code comments explain how specific code works. Memory bank explains why the project exists and how everything fits together.

## Contributing

Found a way to improve this template? Contributions welcome!

1. Fork the repository
2. Create a feature branch
3. Make your improvements
4. Submit a pull request

Ideas for contributions:
- Additional template files for specific use cases
- More slash commands
- Documentation improvements
- Example projects
- Integration guides

## License

[Your chosen license - e.g., MIT]

## Credits

This memory bank system is adapted from Cursor's memory bank approach and optimized for Claude Code's architecture, hook system, and workflow patterns.

---

**Ready to get started?** Read [`.claude/memory-bank/QUICKSTART.md`](.claude/memory-bank/QUICKSTART.md) for step-by-step setup instructions.

**Questions?** Open an issue or check the [troubleshooting section](#troubleshooting).

**Happy building with Claude Code!** 🚀
