# Source Analysis Patterns

Phase 1 intelligence. For each source: where to look, what to extract, which presentation element it feeds.

## Principle

Every extracted fact maps to a slide element. If it doesn't map, don't extract it. If a source is unavailable, note the gap and compensate with interview questions.

---

## 1. Codebase Analysis

Read these files in order. Stop extracting once you have enough signal for the detected presentation type.

### README.md

| Look for | Extract | Maps to |
|----------|---------|---------|
| First paragraph / badges | Project name, one-liner description | Title slide, Hook |
| Features section | Bullet list of capabilities | Solution, Features slides |
| Quick start / installation | Setup complexity, prerequisites | How It Works, Technical Depth |
| Screenshots / diagrams | Visual assets to reference | Any visual slide |
| "Why" or "Motivation" section | Problem statement, origin story | Problem slide, Why Now |
| Comparison tables | Competitive positioning | Comparison slide |

### package.json / pyproject.toml / Cargo.toml / go.mod

| Look for | Extract | Maps to |
|----------|---------|---------|
| `name`, `description` | Canonical project name and tagline | Title slide |
| `dependencies` / `[tool.poetry.dependencies]` | Core tech stack (top 5-8 meaningful deps) | Tech Stack slide |
| `version` | Maturity signal (0.x = early, 1.x+ = stable) | Traction context |
| `scripts` / `[tool.poetry.scripts]` | Key workflows, automation level | Technical Depth |
| `license` | Open source status | Business Model context |
| `author` / `contributors` | Team size signal | Team slide |
| `repository`, `homepage` | Links to website for Phase 1b | Website analysis input |

### CLAUDE.md / AGENTS.md / ARCHITECTURE.md

| Look for | Extract | Maps to |
|----------|---------|---------|
| Architecture patterns | System design, key decisions | Architecture slide |
| Conventions and rules | Engineering culture signals | Technical Depth |
| Anti-patterns listed | What the team avoids (shows maturity) | Architecture slide |
| Service/layer descriptions | Component breakdown | How It Works |
| Infrastructure notes | Deployment, scaling approach | Tech Stack, Scale |

### docs/ directory

| Look for | Extract | Maps to |
|----------|---------|---------|
| API reference | Endpoint count, capability surface | Features, Technical Depth |
| User guides | Target user profile, use cases | Problem, Solution |
| Architecture docs / diagrams | System topology | Architecture slide |
| Changelog / release notes | Recent momentum, feature velocity | Traction |
| ADRs (Architecture Decision Records) | Key technical decisions and rationale | Architecture, Why Now |

### git log (last 90 days)

Run: `git log --oneline --since="90 days ago" | head -50` and `git shortlog -sn --since="90 days ago"`

| Look for | Extract | Maps to |
|----------|---------|---------|
| Commit count (90 days) | Activity level | Traction |
| Unique contributors | Team size | Team slide |
| Commit message themes | Current focus areas | Roadmap context |
| Tag frequency | Release cadence | Traction, Maturity |

### LICENSE

| Look for | Extract | Maps to |
|----------|---------|---------|
| License type | MIT/Apache = open core possible; proprietary = closed | Business Model context |
| Copyright holder | Company vs individual | Team context |

### .github/ directory

| Look for | Extract | Maps to |
|----------|---------|---------|
| Workflow files | CI/CD maturity, test automation | Technical Depth |
| Issue/PR templates | Process maturity | Team, Process |
| Actions count and complexity | DevOps investment | Technical Depth |
| Dependabot / security configs | Security posture | Trust signals |

---

## 2. Website Analysis

Use WebFetch for each page. Process in priority order — stop early if you have sufficient signal.

> **Resilience note:** WebFetch may fail due to auth walls, bot blocking, rate limits, or the site being down. For each unreachable page, record it as `[UNREACHABLE: <url> — <reason>]` and add compensating interview questions. A presentation can be built without any website data.

### Landing page (/)

| Look for | Extract | Maps to |
|----------|---------|---------|
| Hero headline + subheadline | Value proposition (use their words) | Hook slide |
| Hero CTA button text | Desired user action | Ask slide |
| Social proof (logos, numbers) | Traction evidence | Traction slide |
| "How it works" section | Process flow (usually 3-4 steps) | How It Works slide |
| Feature grid/cards | Top capabilities | Solution slide |
| Footer links | Sitemap for further fetching | Analysis routing |

### About page (/about)

| Look for | Extract | Maps to |
|----------|---------|---------|
| Mission statement | Company purpose | Why Now, Hook |
| Founding story | Origin narrative | Story arc |
| Team photos/bios | Team size, backgrounds | Team slide |
| Company timeline / milestones | Growth trajectory | Traction |
| Office locations | Geographic reach | Market context |

### Pricing page (/pricing)

| Look for | Extract | Maps to |
|----------|---------|---------|
| Tier names and prices | Business model structure | Business Model slide |
| Free tier existence | GTM strategy (freemium vs direct) | Business Model |
| Enterprise tier / "Contact us" | Upmarket signal | Market Size context |
| Feature comparison table | Tier differentiation | Features, Comparison |
| Annual vs monthly pricing | Revenue model details | Business Model |

### Features page (/features)

| Look for | Extract | Maps to |
|----------|---------|---------|
| Feature categories | Capability areas | Solution slide |
| Feature descriptions | Detailed differentiators | Features slides |
| Integration logos/list | Ecosystem positioning | Tech Stack, Comparison |
| "Coming soon" items | Roadmap signals | Roadmap slide |

### Blog / Changelog (/blog, /changelog)

| Look for | Extract | Maps to |
|----------|---------|---------|
| Recent post titles (last 3-6 months) | Momentum, narrative themes | Traction |
| Product launch posts | Feature milestones | Traction |
| Case studies / customer stories | Social proof, use cases | Problem, Traction |
| Metrics mentioned in posts | Quantitative traction | Traction slide |

---

## 3. Interview Questions

Ask ONLY for information that could not be extracted from codebase or website. Never repeat what you already know. Cap at 3-5 questions total.

Before asking, state what you already extracted so the user can correct misunderstandings.

### By presentation type

**Pitch deck — common gaps:**

- "Who is your target customer and what's their current alternative?"
- "What's your current traction? (revenue, users, growth rate, pipeline)"
- "What's the specific funding ask and planned use of funds?"
- "What's your unfair advantage or defensibility?"
- "How big is the market opportunity? (TAM/SAM/SOM if known)"

**Technical overview — common gaps:**

- "Who is the audience for this presentation? (engineers, PMs, executives, mixed)"
- "What's the key architectural decision or tradeoff you want to highlight?"
- "What scale or performance numbers matter? (requests/sec, data volume, latency)"
- "Are there specific technical challenges you want to showcase solving?"

**Project update — common gaps:**

- "What time period does this update cover?"
- "What are the top 3 accomplishments in this period?"
- "Any blockers, risks, or requests for the audience?"
- "What are the key metrics and how did they move?"

**General / overview — common gaps:**

- "Who is the audience and what's their familiarity with the topic?"
- "What context do they already have vs. what needs explaining?"

### Universal questions (ask when still unclear after all sources)

- "What's the single thing you want the audience to remember?"
- "What specific action should they take after viewing this?"

### Presentation type clarification

If the type is ambiguous after source analysis, ask ONE question:

- "This looks like it could be a [type A] or [type B]. Which fits better, or is it something else?"

---

## Extraction Checklist

Before moving to Phase 2, verify you have signal for these elements (mark each as extracted, gap, or not-applicable):

| Element | Required for | Source |
|---------|-------------|--------|
| Project/company name | All types | Any |
| One-line description | All types | README, landing page, package.json |
| Problem statement | Pitch, General | README, landing page, interview |
| Target audience | All types | Website, interview |
| Key features (3-5) | All types | README, features page, docs |
| Tech stack | Technical | package.json, codebase |
| Architecture overview | Technical | CLAUDE.md, docs, codebase |
| Traction / metrics | Pitch, Update | Website, git log, interview |
| Team info | Pitch | About page, package.json, git log |
| Business model | Pitch | Pricing page, interview |
| Competitive landscape | Pitch | README comparison, interview |
| Ask / CTA | Pitch | Interview |
| Key message | All types | Interview (if not obvious from sources) |

If any required element for the detected type is still a gap after all available sources, fill it via interview questions. If the user declines to answer, mark it as "omitted by user" and design the deck without that slide.
