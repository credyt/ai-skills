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

### 2a: Get the API key from the user

Ask the user for their Credyt API key:

> "To connect to Credyt, I need your API key. You can find it in the **Developers** section of the Credyt dashboard.
>
> Don't have an account yet? Sign up at [app.credyt.ai/api/sign-up](https://app.credyt.ai/api/sign-up) — it only takes a minute.
>
> Please paste your API key below:"

Wait for the user to provide the key.

Once received, normalise the key:
- If it starts with `key_`, prepend `Bearer ` to get `Bearer key_...`
- If it already starts with `Bearer `, use it as-is

### 2b: Choose where to save the key

Ask the user:

> "Where would you like to save the API key?
>
> 1. **Global** — `~/.claude/settings.json` (available in all projects)
> 2. **Project** — `.claude/settings.local.json` (this project only, gitignored)
>
> Reply with **1** or **2**:"

Wait for their choice and resolve the target file path:
- Choice 1: `~/.claude/settings.json` (expand `~` to the user's home directory)
- Choice 2: `.claude/settings.local.json` (relative to the current working directory)

### 2c: Write the key to the settings file

Read the target settings file:

- **File does not exist** — create it with:
  ```json
  {
    "env": {
      "CREDYT_API_KEY": "Bearer key_..."
    }
  }
  ```

- **File exists, no `env` block** — parse the JSON and add an `env` key:
  ```json
  {
    "env": {
      "CREDYT_API_KEY": "Bearer key_..."
    }
  }
  ```

- **File exists, `env` block exists, no `CREDYT_API_KEY`** — merge the key into the existing `env` block without modifying any other keys.

- **File exists, `CREDYT_API_KEY` already present** — before writing, confirm with the user:
  > "A `CREDYT_API_KEY` is already set in that file. Would you like to overwrite it? (yes/no)"

  If they say no, keep the existing value and continue. If yes, overwrite with the new key.

Write the updated JSON back to the file, preserving formatting as much as possible (2-space indentation).

### 2d: Tell the user to restart

> "Your API key has been saved to `<file path>`. **Please restart Claude Code** for the environment variable to take effect, then run `/credyt:init` again to complete setup."

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
> - The value should be in the format `Bearer key_...` — the `Bearer ` prefix is required.
>
> Would you like me to check the settings files for you, or would you prefer to re-enter your API key?"

**Never** echo or print the API key value to the terminal. If the user wants to re-enter their key, go back to **Step 2a**. If they want you to check the files, read the relevant settings file and confirm whether `CREDYT_API_KEY` is present and correctly formatted (without outputting the full key — just confirm the format looks right, e.g. "starts with `Bearer key_` and is N characters long").
