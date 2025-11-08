# Project-Specific Architecture Rules (Example)

**⚠️ THIS IS A TEMPLATE - Replace "ProjectName" with your project name and customize the patterns below.**

This prompt contains architecture patterns, invariants, and anti-patterns specific to your project. It extends the general architecture review with domain-specific knowledge.

---

## Project Context

**Project Name**: [Your Project Name]
**Tech Stack**: [e.g., Node.js, React, PostgreSQL, Redis]
**Architecture Style**: [e.g., Microservices, Monolith, Event-Driven]
**Team Size**: [e.g., 3-10 engineers]
**Deployment**: [e.g., AWS, GCP, On-Premise]

---

## Critical Architectural Invariants

These are non-negotiable patterns that **MUST** be enforced in every PR. Violations are blockers.

### 1. [Pattern Name - e.g., "Service Layer Consolidation"]

**Rule**: [Describe the rule]
- Example: "All business logic MUST go through the service layer, never in controllers or routes"

**Why This Matters**:
- [Reason 1]
- [Reason 2]
- [Production incident reference if applicable]

**How to Check**:
```
Look for:
- ❌ BAD: Controller methods with complex business logic
- ✅ GOOD: Thin controllers calling service methods
```

**Example - Bad Pattern**:
```javascript
// ❌ BAD: Business logic in controller
router.post('/create-order', async (req, res) => {
  const user = await User.findById(req.user.id);
  if (user.credits < req.body.amount) {
    throw new Error('Insufficient credits');
  }
  user.credits -= req.body.amount;
  await user.save();

  const order = new Order({
    userId: user.id,
    amount: req.body.amount
  });
  await order.save();

  res.json(order);
});
```

**Example - Good Pattern**:
```javascript
// ✅ GOOD: Business logic in service
router.post('/create-order', async (req, res) => {
  const order = await OrderService.createOrder(
    req.user.id,
    req.body.amount
  );
  res.json(order);
});

// In OrderService.js
class OrderService {
  static async createOrder(userId, amount) {
    // All business logic here
    const user = await User.findById(userId);
    if (!user.hasCredits(amount)) {
      throw new InsufficientCreditsError();
    }
    return await this.processOrder(user, amount);
  }
}
```

---

### 2. [Another Pattern - e.g., "Multi-Tenant Data Isolation"]

**Rule**: All database queries MUST filter by `organizationId` or `tenantId`

**Why This Matters**:
- Prevents cross-tenant data leakage
- GDPR/compliance requirement
- Production incident: [Date] - exposed customer data

**How to Check**:
```
Search for:
- Model.find() without organizationId filter
- Aggregation pipelines missing $match stage
- JOIN queries without tenant filter
```

**Example - Bad Pattern**:
```javascript
// ❌ BAD: No tenant isolation
const orders = await Order.find({ status: 'pending' });
```

**Example - Good Pattern**:
```javascript
// ✅ GOOD: Always filter by organization
const orders = await Order.find({
  organizationId: req.user.organizationId,
  status: 'pending'
});
```

---

### 3. [Another Pattern - e.g., "Event-Driven Updates"]

**Rule**: All state changes MUST emit domain events for audit trail

**Why This Matters**:
- Event sourcing for audit compliance
- Enables async workflows (notifications, webhooks)
- Production debugging requires event history

**How to Check**:
```
Look for:
- Model save() operations without EventBus.emit()
- State transitions without event emission
- Missing event type definitions
```

**Example - Bad Pattern**:
```javascript
// ❌ BAD: State change without event
user.status = 'active';
await user.save();
```

**Example - Good Pattern**:
```javascript
// ✅ GOOD: Emit event after state change
user.status = 'active';
await user.save();

EventBus.emit('user.activated', {
  userId: user.id,
  organizationId: user.organizationId,
  timestamp: new Date()
});
```

---

## Technology-Specific Patterns

### Database (PostgreSQL / MongoDB / etc.)

**Required Patterns**:
- [ ] **Indexes**: All queries have supporting indexes (check with EXPLAIN)
- [ ] **Transactions**: Multi-table updates use transactions
- [ ] **Connection Pooling**: No direct connection creation
- [ ] **Query Timeouts**: All queries have timeout limits

**Anti-Patterns to Block**:
- ❌ `SELECT *` in production queries
- ❌ Unbounded result sets (missing LIMIT)
- ❌ N+1 queries (check for loops calling DB)
- ❌ Queries in loops (batch operations instead)

### Caching (Redis / Memcached / etc.)

**Required Patterns**:
- [ ] **TTL on all keys**: No infinite cache entries
- [ ] **Namespacing**: Cache keys prefixed by tenant/feature
- [ ] **Invalidation strategy**: Clear plan for cache invalidation

**Anti-Patterns to Block**:
- ❌ Cache stampede (missing cache warming)
- ❌ Serialization issues (storing complex objects)
- ❌ Missing error handling (cache down = app down)

### Message Queue (RabbitMQ / SQS / Kafka / etc.)

**Required Patterns**:
- [ ] **Idempotent handlers**: Jobs can safely retry
- [ ] **Dead letter queues**: Failed jobs go to DLQ
- [ ] **Timeouts**: Jobs have max execution time

**Anti-Patterns to Block**:
- ❌ Synchronous HTTP in queue handlers
- ❌ Unbounded job payloads (use references)
- ❌ Missing retry logic

---

## Common Production Issues (Learned Lessons)

Document patterns that caused production incidents:

### Issue 1: [Name - e.g., "Deployment Environment Variable Hell"]

**Date**: [When it happened]

**What Broke**:
- [Brief description of incident]

**Root Cause**:
- [What pattern was violated]

**How to Prevent**:
```
Check for:
- ❌ Environment variables used directly in code
- ✅ Config module with validation at startup
```

**Code Pattern to Enforce**:
```javascript
// ✅ GOOD: Centralized config validation
// config.js
const config = {
  database: {
    url: process.env.DATABASE_URL || throwError('DATABASE_URL required'),
    poolSize: parseInt(process.env.DB_POOL_SIZE || '10')
  }
};

// Validate at startup
validateConfig(config);

module.exports = config;
```

---

### Issue 2: [Another Production Issue]

[Follow same pattern as Issue 1]

---

## Project-Specific Anti-Patterns

### Anti-Pattern: [Name]

**Description**: [What to avoid]

**Why It's Bad**:
- [Consequence 1]
- [Consequence 2]

**Detection**:
```
grep for:
- Pattern to detect
- File locations
```

**Remediation**:
```
Suggest:
- Alternative approach
- File:line examples
```

---

## Deployment & Infrastructure Patterns

### Required Practices

- [ ] **Docker builds use --build flag**: Code changes require fresh build
- [ ] **Environment-specific configs**: No hardcoded prod URLs
- [ ] **Health check endpoints**: All services expose /health
- [ ] **Graceful shutdown**: Services handle SIGTERM
- [ ] **Log structured JSON**: All logs parseable by log aggregator

### Anti-Patterns to Block

- ❌ Secrets in Dockerfile or docker-compose.yml
- ❌ Port conflicts (multiple services on same port)
- ❌ Missing resource limits (CPU/memory)
- ❌ Direct database access from dev machines

---

## Code Review Checklist for This Project

When reviewing a PR, verify:

**Business Logic**:
- [ ] All logic in service layer, not controllers
- [ ] Input validation at API boundary
- [ ] Output sanitization for user-facing data

**Data Access**:
- [ ] All queries filter by tenant/organization ID
- [ ] Indexes exist for query patterns
- [ ] Transactions used for multi-step updates

**Security**:
- [ ] No hardcoded secrets
- [ ] Authorization checks on all protected endpoints
- [ ] Input sanitized against injection attacks

**Testing**:
- [ ] Unit tests for new business logic
- [ ] Integration tests for API changes
- [ ] Test coverage > [X%]

**Observability**:
- [ ] Structured logs for key operations
- [ ] Error tracking integration
- [ ] Performance metrics instrumented

**Documentation**:
- [ ] CLAUDE.md updated if patterns changed
- [ ] Memory bank updated for architecture decisions
- [ ] API docs updated for new endpoints

---

## Severity Guidelines for This Project

Use this scale when assigning severity:

**Severity 0**: Documentation only, no code changes
**Severity 1**: Minor improvements, nice-to-haves
**Severity 2**: Should fix soon, but not blocking
**Severity 3**: Must fix before merge (high risk)
**Severity 4**: Critical - security or data loss risk (BLOCKER)

**Blockers = true** when:
- Security vulnerability (injection, auth bypass)
- Data integrity issue (cross-tenant leak)
- Critical pattern violated (listed above as "MUST")

---

## Integration with General Prompt

This prompt **extends** the general architecture review (`01-general-architecture-review.prompt.md`) by adding project-specific context. Both prompts work together:

1. **General Prompt**: Universal patterns (SOLID, DRY, security)
2. **This Prompt**: Project-specific patterns (your architecture decisions)

Claude will apply **both** sets of rules when reviewing PRs.
