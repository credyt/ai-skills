# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Credyt Claude Plugin — an official Claude Code plugin that integrates [Credyt](https://credyt.ai) real-time billing infrastructure into Claude Code and Claude Desktop. It provides guided conversational workflows for setting up usage-based billing, prepaid credit systems, and subscriptions for AI products.

## Repository Structure

This is a **pure plugin scaffold** — no build system, no tests, no application code. The repo contains only plugin metadata, MCP configuration, and skill definitions (Markdown files).

- `.claude-plugin/marketplace.json` — Plugin marketplace distribution config
- `credyt-plugin/` — The plugin itself:
  - `.claude-plugin/plugin.json` — Plugin metadata (name, version, author)
  - `.mcp.json` — MCP server config pointing to `https://mcp.credyt.ai` with bearer token auth
  - `commands/init.md` — `/credyt:init` command: account setup and API key verification
  - `skills/setup/SKILL.md` — `/credyt:setup` skill: guided billing model discovery and product configuration
  - `skills/verify/SKILL.md` — `/credyt:verify` skill: end-to-end billing cycle test
  - `skills/integrate/SKILL.md` — `/credyt:integrate` skill: wire Credyt into application code

## How It Works

Each skill is a multi-step guided conversation (not automated scripts). They use Credyt MCP tools (`create_asset`, `create_product`, `simulate_usage`, `submit_events`, etc.) to interact with the Credyt API. The recommended user flow is: `init` → `setup` → `verify` → `integrate`.

## Authentication

Requires `CREDYT_API_KEY` environment variable set to `Bearer sk_...` format. Configured in shell profile or Claude Desktop settings.

## Installation

From marketplace: `/plugin marketplace add credyt/ai-skills` then `/plugin install credyt@credyt/ai-skills`

Local development: `claude --plugin-dir ./ai-skills/credyt-plugin`

## Editing Skills

Skills are entirely defined in their `SKILL.md` files. These contain the full prompt, workflow steps, user-facing copy, error handling, and MCP tool call patterns. Changes to billing workflows happen here — there is no code to compile or deploy.
