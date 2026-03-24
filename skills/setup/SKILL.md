---
name: setup
description: Discover your billing model and configure products, assets, and pricing in Credyt via MCP. Run this after /credyt:init. Can be run multiple times to add products or adjust pricing. Automatically verifies the full billing cycle after configuration. Use when the user wants to set up billing, create products, configure pricing, add new billable activities, or change how they charge.
---

# Credyt Setup

Guide the user through understanding their billing model, then configure everything in Credyt via MCP tools, then automatically verify the full billing cycle end-to-end. This skill can be run multiple times — to add new products, change pricing, or set up additional assets.

## First: Check what already exists

Before jumping into discovery, check the current state by calling `credyt:list_assets` and `credyt:list_products`.

If they already have products configured, acknowledge what's there:

> "I can see you already have [X] set up. Are you looking to add something new, change existing pricing, or start fresh?"

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

Walk the user through each step. Explain what you're creating in plain terms and confirm before executing.

### Create a custom currency (if using credits/tokens/coins)

Only if they chose a custom currency. This must be created before any products that use it.

Use `credyt:create_asset`. Before creating, explain the conversion clearly:

> "So if 1 credit = $0.05, that means $1 gets you 20 credits. A user topping up $10 would get 200 credits. Does that feel right?"

**After creating**, use `credyt:quote_asset` to verify the conversion. Quote how many units $1, $10, and $50 would buy:

> "Let me verify that... ✓ $1 buys 20 credits, $10 buys 200, $50 buys 1,000. Does that look right?"

If the conversion is wrong, use `credyt:add_asset_rate` to correct it and re-quote.

### Create products with pricing

Use `credyt:create_product` for each billable activity. Walk them through what you're setting up:

> "I'm going to create a product called 'Image Generation' that tracks every time a user generates an image and charges 10 credits. Here's what that means..."

For "tracking first": create with zero or placeholder pricing:

> "This will track every image generation. The price is set to 0 for now — we're just recording activity. Once you see the cost data, we can set real prices."

Explain key fields in plain terms:
- **Product name and code**: What this billing item is called and its identifier
- **Event type**: The activity name that triggers billing (e.g., "image_generated")
- **Usage type**: Per occurrence ("unit") or based on a quantity like tokens ("volume")
- **Pricing**: How much each event costs

**After creating every product**, use `credyt:simulate_usage` to validate. Construct a sample event matching what would happen in their app:

> "Let me test this — one image generation should cost 10 credits... ✓ Confirmed: 10 credits deducted, that's $0.50. Does that match what you expected?"

If the simulation doesn't match, create a new product version with `credyt:create_product_version` using the corrected pricing and re-simulate until it's right.

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

Run the verification against each product that was created or modified in this session. For each product, follow the six-step procedure in `skills/verify/references/procedure.md`.

If any step fails, explain what went wrong and help fix it, then re-run the verification for that product.

> "The test customer will stay in your account — since you're in test mode, this won't affect anything."

## Wrap up

Summarize what was created and verified, then suggest next steps:

> "Here's what's set up and verified in Credyt:
> - [List assets created]
> - [List products with pricing summary and verification status]
> - [List vendors if created]
>
> Run `/credyt:integrate` when you're ready to wire this into your app, or `/credyt:setup` again to add more products."
