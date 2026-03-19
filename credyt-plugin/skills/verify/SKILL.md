---
name: verify
description: Test the full Credyt billing cycle end-to-end for a specific product. Creates a test customer, funds their wallet, sends a usage event, and verifies fees were charged correctly. Use this to re-verify a product after making changes in the dashboard, to test a specific product independently, or to troubleshoot billing issues. Note that /credyt:setup runs verification automatically — use this skill when you want to verify without re-running full setup.
---

# Credyt Verify

Run a full billing cycle test against a product to confirm everything is wired up correctly. Produces a clear pass/fail result for each step.

This is the standalone version of the verification that runs automatically at the end of `/credyt:setup`. Use this when you want to verify a product on its own — for example, after making changes in the Credyt dashboard, or to troubleshoot a billing issue.

## Determine what to verify

If the user specified a product (e.g., `/credyt:verify image_gen_std`), use that. The `$ARGUMENTS` value is the product code or name.

If no product was specified, call `credyt:list_products` and ask which one to test:

> "Which product do you want to verify? Here's what you have set up: [list products]"

Once a product is identified, retrieve its details with `credyt:get_product` and determine:
- The event type it expects
- The usage type (unit, volume, or both)
- The asset it charges in (USD, credits, etc.)
- Any required dimensions or volume fields
- The expected price per event

Summarize this to the user before proceeding:

> "I'll test '[Product Name]'. It expects an event of type '[event_type]' and should charge [price] per [unit/volume]. Let me run through the full cycle..."

## Run the verification

Execute each step and track pass/fail. If any step fails, stop and help troubleshoot before continuing.

### Step 1: Create a test customer

Use `credyt:create_customer` with:
- Name: "Verification Test Customer"
- External ID: something unique like "verify_test_{timestamp}"
- Subscribe to the product being tested

**Pass**: Customer created with an active subscription.
**Fail**: Check if the product is published, if the product code is correct.

Record the customer ID for subsequent steps.

### Step 2: Check starting balance

Use `credyt:get_wallet` to show the initial wallet state.

**Pass**: Wallet exists (it's created automatically with the subscription). Balance is $0.00 or empty.
**Fail**: No wallet found — check subscription status.

### Step 3: Fund the wallet

Use `credyt:create_adjustment` to add test funds. Use the same asset the product charges in. Add enough to cover a few test events (e.g., $10.00 USD or 200 credits).

- `reason`: "gift"
- `description`: "Verification test funding"
- `transaction_id`: Generate a unique UUID

Use `credyt:get_wallet` to confirm the balance updated.

**Pass**: Balance matches the amount added.
**Fail**: Check the asset code matches what the product expects.

Record the balance after funding.

### Step 4: Send a test usage event

Use `credyt:submit_events` to send one realistic event. Construct it to match what the product expects:

- For **unit-based** products: send a single event with the correct event_type
- For **volume-based** products: include the volume field with a test quantity (e.g., `{ "total_tokens": 1000 }`)
- For **dimensional** products: include the dimension values (e.g., `{ "model": "gpt-4" }`)

Use a unique UUID for the event ID.

**Pass**: Event accepted (no error).
**Fail**: Check event_type matches product config, volume fields are present if needed, customer has an active subscription.

Record the event ID.

### Step 5: Verify fees were generated

Use `credyt:get_event` with the event ID to retrieve the event details. Check that:
- Fees were generated (not empty)
- The fee amount matches the expected price

**Pass**: Fees present and amount matches expected price.
**Fail**: No fees — check product pricing config, subscription status, event_type match.

Record the fee amount.

### Step 6: Verify balance changed

Use `credyt:get_wallet` to check the balance after billing.

Calculate: starting balance - fee amount = expected new balance.

**Pass**: Balance decreased by exactly the expected fee amount.
**Fail**: Balance didn't change (event might not have been processed) or decreased by wrong amount (pricing misconfiguration).

## Report results

Present a clear summary:

> **Credyt Verification Report — [Product Name]**
>
> | Step | Result | Details |
> |------|--------|---------|
> | Create test customer | ✓ PASS | Customer ID: cust_xxx |
> | Check starting balance | ✓ PASS | Balance: $0.00 |
> | Fund wallet | ✓ PASS | Added $10.00, balance: $10.00 |
> | Send test event | ✓ PASS | Event ID: evt_xxx |
> | Verify fees | ✓ PASS | Fee: $2.50 (expected: $2.50) |
> | Verify balance | ✓ PASS | Balance: $7.50 (expected: $7.50) |
>
> **Result: ALL PASSED** ✓
>
> Your billing is configured correctly. Run `/credyt:integrate` when you're ready to wire this into your app.

If any step failed:

> **Result: FAILED at step [N]**
>
> [Explain what went wrong and how to fix it. Suggest running `/credyt:setup` to correct the configuration, then `/credyt:verify` again.]

## Cleanup note

> "The test customer will stay in your account — since you're in test mode, this won't affect anything. You can delete it from the Credyt dashboard if you want."
