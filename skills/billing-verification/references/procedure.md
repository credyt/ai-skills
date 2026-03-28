# Credyt Billing Cycle Verification Procedure

The six-step procedure for verifying a Credyt product end-to-end. Run once per product being verified. Track pass/fail for each step — if any step fails, stop and troubleshoot before continuing.

## Step 1: Create a test customer

Use `credyt:create_customer` with:
- Name: "Verification Test Customer"
- External ID: something unique like "verify_test_{timestamp}"
- Subscribe to **all products being verified** in this session (not just one)
- Specify the product version explicitly (e.g., `version: 1`) rather than relying on the default
- Include `return_url: "https://example.com/return"` — this is required when subscribing to any product with a fixed recurring fee

**Pass**: Customer created.
**Fail**: Check that the product is published and the product code is correct.

Record the customer ID for subsequent steps.

## Step 1a: Check for payment-required subscriptions

After creating the customer, inspect the subscription status in the `create_customer` response — no additional call is needed. If the product has a fixed recurring fee, the subscription may be `action_required` rather than immediately active.

If status is `action_required`:

1. Extract `required_actions[0].redirect_url` from the `create_customer` response
2. Tell the user:

   > "This subscription requires payment before it activates. Open this URL and complete checkout using Stripe test card `4242 4242 4242 4242`, any future expiry, and any CVC:
   > [payment URL]
   > Let me know once you've completed the payment."

3. Wait for the user to confirm payment before continuing.
4. If the URL has expired, call `credyt:get_customer` to retrieve a fresh one.

**Pass**: Subscription status is `active` after payment (or was `active` immediately for usage-only products).
**Fail**: Payment not completed, URL expired (refresh with `get_customer`), or wrong product type.

Usage events submitted before the subscription is active will not generate fees — do not proceed to later steps until the subscription is active.

## Step 2: Check starting balance

Use `credyt:get_wallet` to show the initial wallet state.

**Pass**: Wallet exists (created automatically with the subscription). Balance is $0.00 or empty.
**Fail**: No wallet found — check subscription status.

## Step 3: Fund the wallet

Use `credyt:create_adjustment` to add test funds in the same asset the product charges in. Add enough to cover a few test events (e.g., $10.00 USD or 200 credits).

- `reason`: "gift"
- `description`: "Verification test funding"
- `transaction_id`: Generate a unique UUID

Use `credyt:get_wallet` to confirm the balance updated.

**Pass**: Balance matches the amount added.
**Fail**: Check that the asset code matches what the product expects.

Record the balance after funding.

## Step 4: Send a test usage event

Use `credyt:submit_events` to send one realistic event. Construct it to match what the product expects:

- For **unit-based** products: send a single event with the correct event_type
- For **volume-based** products: include the volume field with a test quantity (e.g., `{ "total_tokens": 1000 }`)
- For **dimensional** products: include the dimension values (e.g., `{ "model": "gpt-4" }`)

Use a unique UUID for the event ID.

**Pass**: Event accepted (no error).
**Fail**: Check that event_type matches the product config, volume fields are present if needed, and the customer has an active subscription.

Record the event ID.

## Step 5: Verify fees were generated

Call `credyt:get_event` using the exact UUID submitted in Step 4. Do not rely on balance changes alone — always call this explicitly.

Check:
- `fees` array is not empty
- `fees[0].amount` matches the expected price for the product
- `fees[0].product_version` matches the version the customer is subscribed to

> "Event [UUID]: fees[0].amount = [X] (expected [Y]), product_version = [Z] ✓"

**Pass**: Fees present, amount matches, and product version is correct.
**Fail**: No fees — check product pricing config, subscription status, and event_type match. If fees are present but product_version is unexpected, the customer may be on a different version than intended.

Record the fee amount.

## Step 6: Verify balance changed

Use `credyt:get_wallet` to check the balance after billing.

Calculate: starting balance − fee amount = expected new balance.

**Pass**: Balance decreased by exactly the expected fee amount.
**Fail**: Balance unchanged (event may not have been processed) or decreased by wrong amount (pricing misconfiguration).

## Report results

Present a clear summary table:

> **Credyt Verification — [Product Name]**
>
> | Step | Result | Details |
> |------|--------|---------|
> | Create test customer | ✓ PASS | Customer ID: cust_xxx |
> | Subscription active | ✓ PASS | Status: active (payment completed) |
> | Check starting balance | ✓ PASS | Balance: $0.00 |
> | Fund wallet | ✓ PASS | Added $10.00, balance: $10.00 |
> | Send test event | ✓ PASS | Event ID: evt_xxx |
> | Verify fees | ✓ PASS | Fee: $2.50 (expected: $2.50), version: 1 |
> | Verify balance | ✓ PASS | Balance: $7.50 (expected: $7.50) |
>
> **Result: ALL PASSED** ✓

If any step failed:

> **Result: FAILED at step [N]**
>
> [Explain what went wrong and how to fix it.]
