---
description: Set up your Credyt account and verify the MCP connection. Run this first before using other Credyt commands.
---

# Credyt Init

Get the user connected to Credyt so they can use `/credyt:setup`, `/credyt:verify`, and `/credyt:integrate`.

## Step 1: Check for API key in the environment

Check if `CREDYT_API_KEY` is set in the current environment by running:

```bash
test -n "$CREDYT_API_KEY" && echo "set" || echo "not set"
```

**Never** echo or print the actual API key value to the terminal.

If it **is** set, skip directly to **Step 3: Verify the MCP connection**.

If it **is not** set, continue to Step 2.

## Step 2: Configure the API key

### 2a: Collect the API key

Ask the user for their Credyt API key. It's in the **Developers** section of the Credyt dashboard. If they don't have an account, direct them to sign up at https://app.credyt.ai/api/sign-up.

**Never** echo or print the API key value to the terminal.

### 2b: Ask where to save

Ask the user where they'd like to save the key:

1. **Global** (`~/.claude/settings.json`) — applies to all your projects
2. **Project** (`.claude/settings.local.json`) — this project only (gitignored)

Accept `1` or `2`. Map `1` → `global`, `2` → `project`.

### 2c: Save the key to the settings file

Resolve the target path based on the user's choice:
- **Global** → `~/.claude/settings.json`
- **Project** → `.claude/settings.local.json`

**Never** echo or print the API key value to the terminal.

#### If the file does not exist

Create the parent directory, then write a new settings file. Substitute the real key value — do not write the literal placeholder:

```bash
mkdir -p <parent-directory>
```

Then write a new file at `<target-path>` using the Write tool with this content:

```json
{
  "env": {
    "CREDYT_API_KEY": "<key>"
  }
}
```

#### If the file exists

Check whether `CREDYT_API_KEY` is already present:

```bash
grep -q '"CREDYT_API_KEY"' <target-path> && echo "exists" || echo "not set"
```

If **already set**, ask the user whether they want to overwrite it. If they decline, keep the existing value and skip to Step 2d.

If **not set** (or user confirms overwrite), merge the key into the existing file using `jq`, preserving all other settings:

```bash
jq --arg key "<key>" '.env.CREDYT_API_KEY = $key' <target-path> > tmp.$$.json && mv tmp.$$.json <target-path>
```

If `jq` is not installed, tell the user and suggest installing it (`brew install jq` on macOS, `apt install jq` on Linux) before retrying.

Confirm to the user: "Your API key has been saved to `<resolved-path>`."

### 2d: Tell the user to restart

> "Your API key has been saved to `<resolved-path>`. **Please restart Claude Code** for the environment variable to take effect, then run `/credyt:init` again to complete setup."

**Stop here.** The env var won't be available until restart, so do not proceed to MCP verification.

## Step 3: Verify the MCP connection

Try calling `credyt:list_assets`. If it works, the MCP is connected and authenticated.

If connected, tell the user:

> "You're connected to Credyt. You can run `/credyt:setup` to configure your products and pricing."

And stop here — they're done.

## Step 4: Troubleshoot a failed connection

If the MCP call failed or the tool isn't available, help the user troubleshoot:

> "The MCP connection failed. A few things to check:
>
> - Have you restarted Claude Code since setting the variable?
> - Check that `CREDYT_API_KEY` is present in your settings file (`~/.claude/settings.json` or `.claude/settings.local.json`) under the `env` block.
> - The value should be just the API key (e.g. `key_...`) — no `Bearer ` prefix.
>
> Would you like me to check the settings files for you, or would you prefer to re-enter your API key?"

**Never** echo or print the API key value to the terminal. If the user wants to re-enter their key, go back to **Step 2a**. If they want you to check the files, read the relevant settings file and confirm whether `CREDYT_API_KEY` is present and correctly formatted (without outputting the full key — just confirm the format looks right, e.g. "starts with `key_` and is N characters long").
