---
name: billing-setup
description: Discover your billing model and configure products, assets, and pricing in Credyt via MCP. Can be run multiple times to add products or adjust pricing. Automatically verifies the full billing cycle after configuration. Use when the user wants to set up billing, create products, configure pricing, add new billable activities, or change how they charge.
---

# Credyt Setup

Guide the user through understanding their billing model, then configure everything in Credyt via MCP tools, then automatically verify the full billing cycle end-to-end. This skill can be run multiple times — to add new products, change pricing, or set up additional assets.

## First: Check what already exists

Before jumping into discovery, check the current state by calling `credyt:list_assets` and `credyt:list_products`.

If they already have products configured, acknowledge what's there:

> "I can see you already have [X] set up. Are you looking to add something new, change existing pricing, or start fresh?"

If they want to start fresh, **do not archive or delete existing products**. Leave them as-is. The user can manage existing products conversationally at any time (e.g. "archive the Pro product", "delete this product") — never do this automatically.

If this is their first time, proceed with full discovery.

## Discovery: Understand their business

Ask questions **one at a time**. Listen to each answer before asking the next. Adapt follow-ups based on what they tell you. This is a conversation, not a form.

### What does your app do?

> "Tell me about your app — what does it do, and what are the main things your users do in it?"

Ground every follow-up question in their specific app and activities.

### What costs you money?

> "Which of those activities cost you money to provide? For example, if you're calling an AI model, each call has a cost. What are the expensive parts?"

This identifies the billable events — the activities they'll track and eventually charge for.

### How do you want to charge?

Help them pick between three approaches. Explain each using examples from *their* app, not abstract concepts:

- **Pay-as-you-go (prepaid wallet)**: Users add funds. Each activity deducts from their balance. When it runs out, they top up or service pauses. This is how OpenAI and Replicate work.

- **Monthly subscription**: Flat monthly fee regardless of usage. Classic SaaS model, like Netflix. Good if they're still figuring out pricing or want predictable revenue.

- **Hybrid (subscription + credits)**: Monthly fee that includes a credit allowance. Extra usage costs more. This is how Cursor and Clay work.

### It's OK not to know yet

If they're unsure about pricing, guide them to track first and price later:

> "No problem — you don't need to decide on pricing now. We can start tracking all the meaningful activities in your app and what they cost you. Credyt will show you your unit economics, and you can set pricing based on real data."

For this path: set up products with zero or placeholder prices, and emphasize attaching costs to events.

### Dollars or credits?

> "Do you want your users to see prices in dollars (like '$2.50 per video') or in your own currency like credits or tokens (like '10 credits per video')?"

**Credits make sense when**: costs vary behind the scenes, users aren't technical, you want users to earn credits, or you might adjust pricing later.

**Dollars make sense when**: costs are fixed per activity, users are developers, you want full transparency.

If unsure, suggest credits — more flexibility to adjust later.

### Does pricing vary?

> "Does the cost change depending on anything? Like a higher-quality output costing more, or a different AI model being pricier?"

If yes, get the specifics. These become pricing dimensions in Credyt.

### Discovery checkpoint

Before configuring, confirm you understand:
- What the app does and what activities matter
- Which activities cost them money
- Billing approach (pay-as-you-go, subscription, hybrid, or tracking first)
- Dollars or custom currency
- Whether pricing varies by any dimensions

If anything is unclear, ask. Don't proceed until discovery is complete.

## Configure via MCP

Walk the user through each step. Before executing any MCP call that creates or modifies data, show the user a table of the intended parameters and get explicit confirmation:

> "I'm going to create [X] with these settings — does everything look right?"
>
> | Field | Value |
> |-------|-------|
> | ... | ... |
>
> "Let me know if you'd like to change anything before I proceed."

This applies to every mutation: creating assets, products, vendors, versions, and adjustments. Never assume values the user hasn't confirmed — especially precision, pricing, and event types.

### Create a custom currency (if using credits/tokens/coins)

Only if they chose a custom currency. This must be created before any products that use it.

Use `credyt:create_asset`. Verify precision explicitly — credits are typically whole numbers (precision 0) but this must be confirmed. For example:

> | Field | Value |
> |-------|-------|
> | Name | Credits |
> | Code | `credits` |
> | Precision | 0 (whole credits, no fractions) |
> | Exchange rate | 1 credit = $0.05 → $1 buys 20 credits |

Explain the conversion in concrete terms so the user can verify it makes sense:

**After creating**, use `credyt:quote_asset` to verify the conversion. Quote how many units $1, $10, and $50 would buy:

> "Let me verify that... ✓ $1 buys 20 credits, $10 buys 200, $50 buys 1,000. Does that look right?"

If the conversion is wrong, use `credyt:add_asset_rate` to correct it and re-quote.

### Create products with pricing

Use `credyt:create_product` for each billable activity. For example:

> | Field | Value |
> |-------|-------|
> | Name | Image Generation |
> | Code | `image_gen` |
> | Event type | `image_generated` |
> | Usage type | unit |
> | Price | 10 credits per event |

Key fields to confirm with the user:
- **Product name and code**: What this billing item is called and its identifier
- **Event type**: The activity name that triggers billing (e.g., "image_generated") — must match exactly what the app will send
- **Usage type**: Per occurrence ("unit") or based on a quantity like tokens ("volume")
- **Pricing**: How much each event costs

For "tracking first", set price to zero and make that explicit in the table.

**A product can have both a fixed recurring price and a usage-based real-time price.** For example, a $20/month subscription that also charges 1 credit per AI job is a single product with two prices — a recurring USD price and a per-event credit price. By default, use a single product with multiple prices; only create separate products if the user specifically wants them.

**To update pricing on an existing product, always create a new version** using `credyt:create_product_version` — never create a new product. This preserves billing history and keeps customers on their existing subscription. Show the same confirmation table before creating a version.

**After creating or updating every product**, use `credyt:simulate_usage` to validate. Always specify the product version explicitly in the simulation (e.g., `version: 1`) rather than relying on the default — this ensures you're testing what you just configured:

> "Let me test this — one image generation should cost 10 credits... ✓ Confirmed: 10 credits deducted, that's $0.50. Does that match what you expected?"

If the simulation doesn't match, create a new product version with `credyt:create_product_version` using the corrected pricing and re-simulate until it's right. Confirm the new version parameters in a table before creating it.

**Note on version changes**: After creating a new product version, any existing test customers will still be subscribed to the old version. Either create a new test customer subscribed to the new version, or update the existing customer's subscription before running verification.

### Included credits (entitlements)

If the billing model includes credits bundled into a subscription (e.g., "$20/month includes 1,000 credits"), those are configured as **entitlements** at the product level — not as a negative price or a separate product.

Include an `entitlements` array in the `create_product` (or `create_product_version`) call. For example, a product that grants 1,000 credits per day:

```json
"entitlements": [
  {
    "name": "Daily Credit Allowance",
    "asset": "{assetCode}",
    "amount": 1000,
    "purpose": "bundled",
    "refresh": {
      "interval": "day",
      "strategy": "expire_and_replace"
    },
    "accounting": {
      "revenue_basis": 0.00,
      "cost_basis": "auto"
    }
  }
]
```

Confirm the entitlement fields (name, asset, amount, refresh interval) with the user before creating, using the standard parameter table.

Do not attempt to model included credits as a negative fixed price — this fails validation and isn't the correct approach.

### Set up cost tracking (prompt for this)

Before verification, ask if they want to track what activities cost them:

> "Do you want to track what each activity actually costs you? For example, if generating an image costs you $0.03 in API fees, Credyt can record that alongside the revenue so you can see your margins in real time."

**If yes**, create vendors with `credyt:create_vendor` for each service provider (OpenAI, Anthropic, AWS, etc.):

> "You mentioned you're using OpenAI for image generation — I'll register them as a cost provider so we can track those costs."

Explain that when they send usage events from their app, they'll include a `costs` array with the vendor and amount. Credyt then calculates profit automatically.

**If no**, that's fine — they can add cost tracking later.

## Verify the configuration

After all products are configured, automatically run a full billing cycle test. Don't ask — just do it.

> "Now let me verify everything works end-to-end by running a test billing cycle..."

Run the verification against each product that was created or modified in this session. For each product, follow the six-step procedure in `skills/billing-verification/references/procedure.md`.

If any step fails, explain what went wrong and help fix it, then re-run the verification for that product.

> "The test customer will stay in your account — since you're in test mode, this won't affect anything."

## Wrap up

Summarize what was created and verified, then suggest next steps:

> "Here's what's set up and verified in Credyt:
> - [List assets created]
> - [List products with pricing summary and verification status]
> - [List vendors if created]
>
> Run `/credyt:billing-integration` when you're ready to wire this into your app, or `/credyt:billing-setup` again to add more products."
