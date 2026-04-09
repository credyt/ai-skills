# Credyt AI Skills

Set up and integrate [Credyt](https://credyt.ai) — real-time monetization infrastructure for AI products — directly from your AI agent. Four skills guide you from pricing strategy through production integration.

## Quick install (any AI agent)

Install for Claude Code, Cursor, Codex, Gemini, Copilot, and other agents:

**1. Connect the Credyt MCP server** — get an API key at [app.credyt.ai](https://app.credyt.ai/api/sign-up), then run:

```bash
npx add-mcp \
  https://mcp.credyt.ai \
  --header "Authorization: Bearer key_your_api_key_here"
```

**2. Add the skills:**

```bash
npx skills add credyt/ai-skills
```

Or install a specific skill:

```bash
npx skills add credyt/ai-skills --skill billing-setup
```

### Available skills

| Skill                                                  | What it does                                                                                                        |
| ------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------- |
| [`pricing-strategy`](skills/pricing-strategy/SKILL.md)             | Guides you through defining your pricing strategy before configuring billing tooling                                |
| [`billing-setup`](skills/billing-setup/SKILL.md)                   | Discovers your pricing model, configures products, assets, and pricing via MCP, and verifies the full billing cycle |
| [`billing-verification`](skills/billing-verification/SKILL.md)     | Tests the billing cycle end-to-end for a specific product                                                           |
| [`billing-integration`](skills/billing-integration/SKILL.md)       | Wires Credyt billing into your application code                                                                     |

---

## skills.sh vs Claude Code plugin

This repo provides the same skills in two ways:

- **skills.sh** (`npx skills add credyt/ai-skills`) — works with any AI agent that supports MCP.
- **Claude Code plugin** (`/plugin install credyt@credyt/ai-skills`) — makes skills available as slash commands in Claude Code.

Either way, connect the Credyt MCP server first with `npx add-mcp`.

---

## Claude Code plugin

The plugin makes Credyt skills available as slash commands in Claude Code and lists on the Anthropic marketplace. Connect the MCP server separately with `npx add-mcp` (see above).

| Skill   | `/credyt:billing-setup`        | Discovers your billing model through a guided conversation, then configures products, assets, and pricing in Credyt via MCP. Runs a full end-to-end billing cycle verification automatically.                         |
| Skill   | `/credyt:billing-verification` | Tests the full billing cycle for a specific product — creates a test customer, funds their wallet, sends a usage event, and confirms the fee was charged correctly. Use this after making changes or to troubleshoot. |
| Skill   | `/credyt:billing-integration`  | Wires Credyt into your application code. Adds customer creation at signup, usage event tracking, balance checks, cost tracking, billing portal links, and balance display.                                            |

### Installation

#### 1. Get your API key

1. Go to [app.credyt.ai/api/sign-up](https://app.credyt.ai/api/sign-up) and create an account
2. Open the **Developers** section in the dashboard
3. Copy your API key

#### 2. Connect the MCP server

Use `add-mcp` to wire in the Credyt MCP server and set your API key:

```bash
npx add-mcp \
  https://mcp.credyt.ai \
  --header "Authorization: Bearer key_your_api_key_here"
```

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

### Usage

Configure your billing:

```
/credyt:billing-setup
```

Test that billing works correctly:

```
/credyt:billing-verification
```

Wire billing into your app code:

```
/credyt:billing-integration
```

---

## Claude Desktop

Claude Desktop connects to the Credyt MCP server directly — no plugin system, no auto-configuration. It works well for managing an existing Credyt setup conversationally: querying recent activity, making ad-hoc price changes, viewing customer and wallet information, and similar tasks.

The guided skills (`billing-setup`, `billing-verification`, `billing-integration`) can also be used in Claude Desktop, but they must be uploaded manually — attach the relevant `SKILL.md` file or paste its contents into the conversation.

### Connect the MCP server

The fastest way is to use [`add-mcp`](https://github.com/neondatabase/add-mcp), which writes the config for you:

```bash
npx add-mcp "npx mcp-remote https://mcp.credyt.ai --header Authorization:\${CREDYT_API_KEY}" \
  --name credyt \
  --env "CREDYT_API_KEY=Bearer key_your_api_key_here" \
  -a claude-desktop -y
```

Replace `key_your_api_key_here` with your key from [app.credyt.ai](https://app.credyt.ai/api/sign-up), then restart Claude Desktop.

<details>
<summary>Manual setup</summary>

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
        "CREDYT_API_KEY": "Bearer key_your_api_key_here"
      }
    }
  }
}
```

Restart Claude Desktop after saving.

</details>

---

## Resources

- **Docs**: [docs.credyt.ai](https://docs.credyt.ai)
- **Integration guide**: [docs.credyt.ai/ai-integration.md](https://docs.credyt.ai/ai-integration.md)
- **Examples**: [github.com/credyt/learn](https://github.com/credyt/learn)
- **Dashboard**: [app.credyt.ai](https://app.credyt.ai)
