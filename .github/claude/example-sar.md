# Example System Architecture Review (SAR)

This is an example of what Architect-Gate produces for each PR. Replace "FooBar" references with your actual project name.

---

## Executive Summary

This PR adds a new payment provider integration for Stripe. The implementation introduces 250 lines of code but duplicates existing payment processing logic instead of using the shared `PaymentService`. **High architectural risk** due to duplicate transaction handling and missing webhook signature verification.

**Risk Level**: 3/4 (High)
**Merge Recommendation**: ❌ Request Changes - Blockers Present

---

## System Context (C4-Lite)

### Current System State

```
PayPal Provider ──┐
                  ├──> PaymentService ──> Database (Transactions)
Square Provider  ┘          │
                            ├──> Transaction Engine
                            └──> Webhook Handler (3-tier validation)
```

**Components**:
- **PayPal Provider**: OAuth + REST API → PaymentService
- **Square Provider**: API Key + webhooks → PaymentService
- **PaymentService**: Shared transaction logic, validation, storage (850 lines)

### Proposed Changes

```
PayPal Provider ──┐
                  ├──> PaymentService ──> Database
Square Provider  ┘
                          ┌─ Custom Transaction Logic (150 lines)
Stripe Provider ──> [NEW] ├─ Custom Webhook Handler (100 lines)
                          └─ Direct Database Insert
```

**Impact**: Introduces parallel path with duplicate logic.

---

## Diff Impact Analysis

### Files Changed (4 files)

1. **src/services/StripePaymentService.js** (+250 lines)
   - New provider service with custom transaction logic
   - Direct database operations
   - Role: Payment processing orchestration

2. **src/routes/api/stripe.js** (+65 lines)
   - New API endpoints for Stripe webhooks
   - Role: HTTP route handlers

3. **src/models/StripeTransaction.js** (+40 lines)
   - Stripe-specific transaction model
   - Role: Data model

4. **package.json** (+1 line)
   - Added `stripe` dependency

### Risk Surface

**Runtime**:
- New external dependency (Stripe SDK)
- Custom transaction logic (untested against edge cases)
- Potential duplicate charge issues

**Data Integrity**:
- Missing webhook signature verification
- No idempotency keys for retries
- Risk of duplicate transactions

**Security**:
- Webhook endpoint exposed without auth
- Missing input validation
- API keys stored correctly (✓)

**Operations**:
- No queue-based processing (synchronous HTTP)
- Missing progress tracking for multi-step flows
- No retry logic for transient failures

### Blast Radius

**Direct Impact**:
- New Stripe users only (limited initial blast)

**Indirect Impact**:
- Payment reconciliation affects ALL payment providers
- Future maintenance burden (2 transaction implementations)
- Payment processing system complexity increased

---

## Anti-Pattern Findings

### 🚫 CRITICAL: Duplicate Transaction Logic

**Severity**: 4 (Critical)
**Category**: Code Duplication / Architecture Violation
**Location**: `src/services/StripePaymentService.js:45-120`

**Issue**: New provider reimplements payment transaction handling instead of using `PaymentService`.

**Evidence**:
```javascript
// ❌ BAD: Duplicate transaction logic
async processPayment(stripeCharge) {
  // Custom transaction creation (80 lines)
  const transaction = new Transaction({
    amount: stripeCharge.amount,
    currency: stripeCharge.currency,
    provider: 'stripe',
    status: 'pending'
  });
  await transaction.save();

  // Custom validation (40 lines)
  if (stripeCharge.status === 'succeeded') {
    transaction.status = 'completed';
    await transaction.save();
  }

  // Custom idempotency (30 lines)
  const hash = crypto.createHash('md5')
    .update(stripeCharge.id)
    .digest('hex');
  // ...
}
```

**Why This is Critical**:
1. Duplicates 150+ lines from `PaymentService`
2. Uses MD5 (weak) vs SHA256 (in PaymentService)
3. Different transaction state machine than PayPal/Square
4. Will diverge from shared improvements
5. Violates "Payment Provider Consolidation" pattern

**Impact**:
- Maintenance burden: 3 places to update transaction logic
- Inconsistency: Different behavior across providers
- Bugs: Edge cases handled in PaymentService missed here
- Technical debt: $8,000+ to refactor later vs $800 now

**Recommendation**:
```javascript
// ✅ GOOD: Reuse shared service
async processPayment(stripeCharge) {
  // Normalize to common format
  const normalizedPayment = {
    amount: stripeCharge.amount / 100, // Stripe uses cents
    currency: stripeCharge.currency,
    externalId: stripeCharge.id,
    provider: 'stripe',
    metadata: stripeCharge.metadata
  };

  // Shared service handles transaction logic
  return await PaymentService.processPayment(
    normalizedPayment,
    userId
  );
}
```

**Priority**: 🚨 BLOCKER - Must fix before merge

---

### 🚫 CRITICAL: Missing Webhook Signature Verification

**Severity**: 4 (Critical)
**Category**: Security Vulnerability
**Location**: `src/routes/api/stripe.js:23`

**Issue**: Webhook endpoint doesn't verify Stripe signature, allowing anyone to forge webhook events.

**Evidence**:
```javascript
// ❌ BAD: No signature verification
router.post('/webhooks/stripe', async (req, res) => {
  const event = req.body;  // Accepts ANY data!

  await StripePaymentService.handleWebhook(event);
  res.json({ received: true });
});
```

**Why This is Critical**:
1. Attacker can send fake "payment succeeded" events
2. Could credit accounts without actual payment
3. Financial loss and fraud risk
4. Violates PCI compliance requirements

**Impact**:
- **Security**: Financial fraud possible
- **Compliance**: PCI-DSS violation
- **Business**: Potential monetary loss

**Recommendation**:
```javascript
// ✅ GOOD: Verify webhook signature
router.post('/webhooks/stripe', async (req, res) => {
  const sig = req.headers['stripe-signature'];
  let event;

  try {
    // Verify webhook came from Stripe
    event = stripe.webhooks.constructEvent(
      req.rawBody,  // Must be raw body, not parsed JSON
      sig,
      process.env.STRIPE_WEBHOOK_SECRET
    );
  } catch (err) {
    console.error('⚠️ Webhook signature verification failed', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  await StripePaymentService.handleWebhook(event);
  res.json({ received: true });
});
```

**Priority**: 🚨 BLOCKER - Security vulnerability

---

### ⚠️ HIGH: Synchronous Webhook Processing

**Severity**: 3 (High)
**Category**: Performance / UX Anti-Pattern
**Location**: `src/routes/api/stripe.js:23-35`

**Issue**: Webhook endpoint processes payments inline, blocking HTTP request.

**Evidence**:
```javascript
// ❌ BAD: Inline processing blocks request
router.post('/webhooks/stripe', async (req, res) => {
  const event = req.body;

  // This could take 10+ seconds for complex processing
  await StripePaymentService.handleWebhook(event);

  res.json({ received: true });
});
```

**Why This is High Severity**:
1. Stripe expects 200 response within 5 seconds
2. Timeout causes Stripe to retry webhook (duplicate processing)
3. No recovery if processing fails mid-way
4. Blocks server resources during processing

**Impact**:
- **Reliability**: Webhook retries cause duplicate charges
- **UX**: User sees delayed confirmation
- **Scalability**: Can't handle concurrent webhooks

**Recommendation**:
```javascript
// ✅ GOOD: Queue-based async processing
router.post('/webhooks/stripe', async (req, res) => {
  const event = verifyWebhook(req);

  // Immediately queue for background processing
  await WebhookQueue.enqueue('stripe.webhook', {
    eventId: event.id,
    type: event.type,
    data: event.data,
    timestamp: new Date()
  });

  // Return immediately (Stripe won't retry)
  res.status(200).json({ received: true });
});
```

**Priority**: ⚠️ HIGH - Should fix in this PR or immediately after

---

## Recommendations

### Now (Blockers) - Must Fix Before Merge

- [ ] **StripePaymentService.js:45-120**: Remove custom transaction logic, use `PaymentService.processPayment()` (Est: 2-3 hours)
- [ ] **stripe.js:23**: Add Stripe webhook signature verification (Est: 30 minutes)
- [ ] **Test coverage**: Add integration test verifying signature validation (Est: 30 minutes)

**Estimated Total**: 3-4 hours

### Soon (Next PR or This PR) - Stabilize Integration

- [ ] **stripe.js:23**: Convert to queue-based webhook processing (Est: 3-4 hours)
- [ ] **Idempotency**: Add idempotency keys for Stripe API calls (Est: 2 hours)
- [ ] **Error recovery**: Implement retry logic for transient Stripe API failures (Est: 2 hours)

**Estimated Total**: 7-8 hours

### Later (Technical Debt) - Hardening

- [ ] Extract common OAuth patterns to shared `PaymentProviderAuth` service
- [ ] Add rate limiting for Stripe webhook endpoint
- [ ] Implement webhook replay for debugging failed events
- [ ] Add Stripe Connect support for multi-merchant

---

## Architecture Evolution

### Component Map (Proposed Fix)

```
┌────────────────────────────────────────────────────┐
│  Payment Provider Integration                      │
├────────────────────────────────────────────────────┤
│                                                    │
│  PayPal Provider ──┐                               │
│                    ├──> PaymentService ─┐          │
│  Square Provider ──┘          │          │         │
│                               │          │         │
│  Stripe Provider ─────────────┘          │         │
│                                           ▼         │
│                                      Database      │
│                                  (unified schema)  │
│                                                    │
│  Shared Components:                                │
│  - Transaction State Machine                       │
│  - 3-Tier Idempotency (ID, hash, dedup)          │
│  - Webhook Signature Verification                 │
│  - Queue-Based Processing                         │
│  - Error Recovery (retry logic)                   │
└────────────────────────────────────────────────────┘
```

---

## Testing Gaps

### Critical Tests Missing

1. **Webhook signature validation test**:
```javascript
// src/routes/api/__tests__/stripe.test.js
describe('POST /webhooks/stripe', () => {
  it('should reject webhook with invalid signature', async () => {
    const fakeEvent = { type: 'charge.succeeded', data: {} };

    const res = await request(app)
      .post('/webhooks/stripe')
      .set('stripe-signature', 'invalid_signature')
      .send(fakeEvent);

    expect(res.status).toBe(400);
    expect(res.text).toContain('Webhook Error');
  });

  it('should accept webhook with valid signature', async () => {
    const validEvent = createStripeWebhook('charge.succeeded');
    const signature = stripe.webhooks.generateTestHeaderString(validEvent);

    const res = await request(app)
      .post('/webhooks/stripe')
      .set('stripe-signature', signature)
      .send(validEvent);

    expect(res.status).toBe(200);
  });
});
```

2. **Payment service integration test**:
```javascript
describe('StripePaymentService', () => {
  it('should use PaymentService for transaction processing', async () => {
    const processSpy = jest.spyOn(PaymentService, 'processPayment');

    await stripeService.processPayment(mockStripeCharge);

    expect(processSpy).toHaveBeenCalledWith(
      expect.objectContaining({ provider: 'stripe' }),
      userId
    );
  });
});
```

---

## Security Checklist

- [x] Input validation present (Stripe SDK handles)
- [x] Authentication checked (webhook signature - NEEDS FIX)
- [❌] Authorization proper (missing signature verification)
- [x] No secrets in code (using env vars)
- [x] Injection risks mitigated (Stripe SDK parameterization)
- [x] Secure crypto used (N/A - delegated to Stripe)
- [❌] Webhook authentication (CRITICAL ISSUE)

**Findings**: Missing webhook signature verification is the primary security concern.

---

## Merge Decision

**Decision**: 🚫 **Request Changes** (Blockers Present)

**Justification**:

This PR introduces valuable Stripe integration but has two **critical blockers**:

1. **Security vulnerability**: Missing webhook signature verification allows financial fraud
2. **Duplicate architecture**: Violates "Payment Provider Consolidation" pattern

Both issues are fixable in 3-4 hours total. The architecture fix (using PaymentService) actually **reduces** code by ~150 lines while improving maintainability.

**Conditions for Approval**:

1. ✅ Remove custom transaction logic, use `PaymentService`
2. ✅ Add webhook signature verification
3. ✅ Add test for signature validation
4. ⚠️ Consider queue-based webhooks (can be follow-up PR)

**Post-Merge Recommendations**:

- Open follow-up issue for queue-based webhook processing
- Add webhook replay functionality for debugging
- Extract shared OAuth patterns across all payment providers

**Encouragement**: The Stripe SDK integration is well-structured! The core API integration and error handling are solid. These blockers are quick fixes that will make the feature production-ready and maintainable long-term. 🚀

---

## Machine-Readable Footer

```
SEVERITY: 3
BLOCKERS: true
FILES_CHANGED: 4
RISK_AREAS: security, architecture, financial, compliance
```

---

**End of SAR**

*Generated by Architect-Gate on 2025-11-07*
