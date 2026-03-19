---
description: Set up your Credyt account and verify the MCP connection. Run this first before using other Credyt commands.
---

# Credyt Init

Get the user connected to Credyt so they can use `/credyt:setup`, `/credyt:verify`, and `/credyt:integrate`.

## Step 1: Check if already connected

Try calling `credyt:list_assets`. If it works, the MCP is connected and authenticated.

If connected, tell the user:

> "You're connected to Credyt. You can run `/credyt:setup` to configure your products and pricing."

And stop here — they're done.

## Step 2: Create a Credyt account

If the MCP call failed or isn't available, walk through account creation:

> "Let's get you set up with Credyt. First, head to [app.credyt.ai/api/sign-up](https://app.credyt.ai/api/sign-up) and create an account — it only takes a minute."

Wait for confirmation. Then:

> "Now go to the **Developers** section in the Credyt dashboard and copy your API key. You'll need it in the next step."

Wait for them to confirm they have the key.

## Step 3: Configure the API key

The plugin bundles the MCP server config, but the user needs to set their API key. Guide them based on their environment:

**Claude Code:**

> "Set your API key as an environment variable. Add this to your shell config (`.bashrc`, `.zshrc`, or similar):
>
> ```bash
> export CREDYT_API_KEY="Bearer sk_your_actual_key_here"
> ```
>
> Then restart Claude Code to pick it up."

**Claude Desktop:**

> "Open Settings → Developer → Edit config. Find the Credyt MCP server entry and replace `your_api_key` with the key you just copied:
>
> ```json
> "CREDYT_API_KEY": "Bearer sk_your_actual_key_here"
> ```
>
> Then restart Claude Desktop."

## Step 4: Verify the connection

After restart, try `credyt:list_assets` again.

If it works:

> "You're connected to Credyt. Run `/credyt:setup` to configure your products and pricing."

If it fails, troubleshoot: wrong key format, missing `Bearer` prefix, environment variable not loaded, restart needed.
