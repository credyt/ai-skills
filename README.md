# Credyt AI Skills

Set up and integrate [Credyt](https://credyt.ai) — real-time monetization infrastructure for AI products — directly from your AI agent. Three skills guide you from first configuration through production integration.

## Quick install (any AI agent)

Install skills for Claude Code, Cursor, Codex, Gemini, Copilot, and other agents:

```
npx skills add credyt/ai-skills
```

Or install a specific skill:

```
npx skills add credyt/ai-skills --skill setup
```

The skills use the Credyt MCP server. Connect it in your tool at `https://mcp.credyt.ai` with your API key as a Bearer token in the Authorization header. Get an API key at [app.credyt.ai](https://app.credyt.ai/api/sign-up).

### Available skills

| Skill                                                  | What it does                                                                                                        |
| ------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------- |
| [`pricing-strategy`](skills/pricing-strategy/SKILL.md) | Guides you through defining your pricing strategy before configuring billing tooling                                |
| [`setup`](skills/setup/SKILL.md)                       | Discovers your pricing model, configures products, assets, and pricing via MCP, and verifies the full billing cycle |
| [`verify`](skills/verify/SKILL.md)                     | Tests the billing cycle end-to-end for a specific product                                                           |
| [`integrate`](skills/integrate/SKILL.md)               | Wires Credyt billing into your application code                                                                     |

---

## skills.sh vs Claude Code plugin

This repo provides the same skills in two ways:

- **skills.sh** (`npx skills add credyt/ai-skills`) — works with any AI agent that supports MCP. You connect the Credyt MCP server yourself.
- **Claude Code plugin** (`/plugin install credyt@credyt/ai-skills`) — bundles the MCP server config so it auto-connects on install, and includes `/credyt:init` for guided API key setup.

The skills are identical — the plugin adds MCP auto-configuration and a guided init command for Claude Code users.

---

## Claude Code plugin

The plugin also connects to the **Credyt MCP server** (`mcp.credyt.ai`), which exposes the Credyt API as tools Claude can call directly — creating products, sending events, checking wallets, and more.

| Type    | Name                | What it does                                                                                                                                                                                                          |
| ------- | ------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Command | `/credyt:init`      | Gets you connected to Credyt. Creates an account, configures the API key, and verifies the MCP connection. Run this first.                                                                                            |
| Skill   | `/credyt:setup`     | Discovers your billing model through a guided conversation, then configures products, assets, and pricing in Credyt via MCP. Runs a full end-to-end billing cycle verification automatically.                         |
| Skill   | `/credyt:verify`    | Tests the full billing cycle for a specific product — creates a test customer, funds their wallet, sends a usage event, and confirms the fee was charged correctly. Use this after making changes or to troubleshoot. |
| Skill   | `/credyt:integrate` | Wires Credyt into your application code. Adds customer creation at signup, usage event tracking, balance checks, cost tracking, billing portal links, and balance display.                                            |

### Installation

#### 1. Get your API key

1. Go to [app.credyt.ai/api/sign-up](https://app.credyt.ai/api/sign-up) and create an account
2. Open the **Developers** section in the dashboard
3. Copy your API key

#### 2. Set the API key

**Claude Code** — run `/credyt:init` after installing the plugin. It will guide you through entering your API key and verify the MCP connection is working.

<details>
<summary>Manual setup</summary>

Add the key to a Claude settings file so it's available to the MCP server.

**Option 1 — Global (all projects):** Add to `~/.claude/settings.json`:

```json
{
  "env": {
    "CREDYT_API_KEY": "Bearer sk_your_api_key_here"
  }
}
```

**Option 2 — Project-scoped (not checked into source control):** Add to `.claude/settings.local.json` in your project directory:

```json
{
  "env": {
    "CREDYT_API_KEY": "Bearer sk_your_api_key_here"
  }
}
```

Claude Code automatically adds this file to `.gitignore`, so each developer on a team can set their own key without it ending up in source control.

**Option 3 — Terminal / shell profile:** Export the variable in your current session or add it to your shell profile (`~/.zshrc`, `~/.bashrc`, etc.):

```bash
export CREDYT_API_KEY="Bearer sk_your_api_key_here"
```

To persist across sessions, add the line to your shell profile and run `source ~/.zshrc` (or restart your terminal).

</details>

#### 3. Install the plugin

**From GitHub** — run these two commands inside Claude Code:

```
/plugin marketplace add credyt/ai-skills
/plugin install credyt@credyt/ai-skills
```

**From a local clone:**

```bash
git clone https://github.com/credyt/ai-skills
claude --plugin-dir ./ai-skills/claude-plugins/credyt
```

#### 4. Connect and verify

Run `/credyt:init` in Claude Code. It will guide you through setting your API key (if you haven't already), confirm the MCP is connected, and walk you through any remaining setup.

### Usage

Start here if you're new:

```
/credyt:init
```

Once connected, configure your billing:

```
/credyt:setup
```

Test that billing works correctly:

```
/credyt:verify
```

Wire billing into your app code:

```
/credyt:integrate
```

---

## Claude Desktop

Claude Desktop connects to the Credyt MCP server directly — no plugin system, no auto-configuration. It works well for managing an existing Credyt setup conversationally: querying recent activity, making ad-hoc price changes, viewing customer and wallet information, and similar tasks.

The guided skills (`setup`, `verify`, `integrate`) can also be used in Claude Desktop, but they must be uploaded manually — attach the relevant `SKILL.md` file or paste its contents into the conversation.

### Connect the MCP server

Open Settings → Developer → Edit config and add the Credyt entry:

```json
{
  "mcpServers": {
    "credyt": {
      "command": "npx",
      "args": [
        "mcp-remote",
        "https://mcp.credyt.ai",
        "--header",
        "Authorization:${CREDYT_API_KEY}"
      ],
      "env": {
        "CREDYT_API_KEY": "Bearer sk_your_api_key_here"
      }
    }
  }
}
```

Restart Claude Desktop after saving.

---

## Resources

- **Docs**: [docs.credyt.ai](https://docs.credyt.ai)
- **Integration guide**: [docs.credyt.ai/ai-integration.md](https://docs.credyt.ai/ai-integration.md)
- **Examples**: [github.com/credyt/learn](https://github.com/credyt/learn)
- **Dashboard**: [app.credyt.ai](https://app.credyt.ai)
