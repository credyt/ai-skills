# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository. Read it before making any changes.

---

## Project Overview

Credyt AI Skills — skill definitions for setting up, verifying, and integrating [Credyt](https://credyt.ai) real-time monetization infrastructure into AI products. Skills work with any AI agent via skills.sh, and are also bundled as a Claude Code plugin with MCP auto-configuration.

## Repository Structure

This is a **pure skill scaffold** — no build system, no tests, no application code. The repo contains only skill definitions (Markdown files), plugin metadata, and MCP configuration.

- `skills/` — Shared skill definitions (the single source of truth):
  - `setup/SKILL.md` — Guided pricing model discovery and product configuration
  - `verify/SKILL.md` — End-to-end billing cycle test
  - `integrate/SKILL.md` — Wire Credyt into application code
- `claude-plugins/credyt/` — Claude Code plugin:
  - `.claude-plugin/plugin.json` — Plugin metadata (name, version, author)
  - `.mcp.json` — MCP server config (auto-connects on plugin install)
  - `commands/init.md` — `/credyt:init` command: account setup and API key verification
  - `skills/` — Symlinks to `../../skills/` (shared skill files)
- `.claude-plugin/marketplace.json` — Claude Code marketplace distribution config

## How It Works

Each skill is a multi-step guided conversation (not automated scripts). They use Credyt MCP tools (`create_asset`, `create_product`, `simulate_usage`, `submit_events`, etc.) to interact with the Credyt API. The recommended user flow is: `init` → `setup` → `verify` → `integrate`.

## Authentication

Requires `CREDYT_API_KEY` environment variable set to `Bearer sk_...` format. Configured in shell profile or Claude Desktop settings.

## Installation

From marketplace: `/plugin marketplace add credyt/ai-skills` then `/plugin install credyt@credyt/ai-skills`

Local development: `claude --plugin-dir ./claude-plugins/credyt`

Via skills.sh (any agent): `npx skills add credyt/ai-skills`

---

## The Core Standard

Write skills that a thoughtful senior engineer would be proud to ship. That means prompts that are easy to read, easy to understand, and easy to change. A working skill that is hard to follow is not a finished skill.

Every change should be as simple as possible. Touch only what is necessary. The best solution solves the problem without introducing new complexity or risk.

When in doubt, ask: _would a staff engineer look at this and approve it immediately?_

---

## Editing Skills

Skills are entirely defined in their `SKILL.md` files. These contain the full prompt, workflow steps, user-facing copy, error handling, and MCP tool call patterns. Changes to billing workflows happen here — there is no code to compile or deploy.

Always edit the skill files in `skills/` at the repo root. The files in `claude-plugins/credyt/skills/` are symlinks — do not create separate copies there.

Read the full `SKILL.md` file before making any edits. Preserve the conversational tone — skills guide users through a workflow, they don't run scripts. Test locally using `claude --plugin-dir ./claude-plugins/credyt` before committing.

---

## Skill Design Principles

- **Guide, don't automate.** Skills are conversations, not scripts. Each step should involve the user, confirm intent, and explain what's happening before calling a MCP tool.
- **Fail gracefully.** If an MCP call fails or returns unexpected results, the skill should explain what happened, suggest a fix, and offer a retry path — not silently continue or abort without context.
- **Be explicit about MCP calls.** Name the tool being called and explain why before invoking it. Users should never be surprised by what the skill is doing on their behalf.
- **Keep steps atomic.** Each numbered step should accomplish one thing. If a step is doing multiple things, split it.

---

## Plan Before You Code

For any non-trivial task, plan before making changes. Create a task-specific plan file in `tasks/` named descriptively in kebab-case — for example `tasks/add-verify-skill.md` or `tasks/fix-init-flow.md`. Write the plan there as a checklist, then check in before starting. This surfaces misunderstandings early, when they are cheap to fix.

Each task gets its own file so plans don't overwrite each other. Name the file after what the task does, not generically.

If something goes sideways mid-implementation, stop and re-plan. If you are uncertain between two approaches, say so and explain the trade-offs rather than silently picking one.

---

## Learning From Mistakes

After any correction, capture the pattern in `tasks/lessons.md`. Write it as a rule that prevents the same mistake recurring. Review this file at the start of each session for anything relevant to the work at hand.

The goal is a declining mistake rate over time. If the same class of error keeps appearing, the lesson wasn't written clearly enough — rewrite it.

---

## Readability and Maintainability

Skill files are read far more often than they are written. Optimise for the reader.

Prefer simple, linear workflows over clever branching. If a step requires a parenthetical explanation of what it does, consider whether it can be restructured to be self-explanatory. Comments in skill files should explain _why_ a particular approach was taken, not narrate what the step is doing.

For any non-trivial change, pause before finishing and ask: _is there a more elegant way to express this workflow?_ If it feels like a workaround, it probably is.

---

## Error Handling

MCP tool calls can fail. Skills must handle this explicitly — never assume a tool call succeeds.

When a tool call fails, explain what happened, provide enough context to diagnose the problem, and give the user a clear next step. In a guided workflow, one failed step should not abort the entire session unless there is no meaningful way to continue.

Find root causes. A recovery path that masks a symptom is not a fix.

---

## Verification

Never consider a task complete without proving it works. Run the skill locally end-to-end. Demonstrate correctness — don't assume it.

When given a bug report, fix it and confirm the fix. Don't ask for hand-holding through a debugging process you can drive yourself.

---

## Git Workflow

Never commit directly to `main`. All work happens on a dedicated branch, created before any changes are made.

Branch names should follow the pattern `type/short-description` — for example `feat/add-upgrade-skill`, `fix/verify-error-handling`, `docs/update-readme`. A branch name should tell a reviewer what to expect before they look at a single file.

Commit messages follow the format `type: description` where type is one of `feat`, `fix`, `docs`, `refactor`, or `chore`.

When the work is complete and verified, raise a pull request. The PR description must include:

**## What changed** — what the PR does and why.

**## How to test** — every step a reviewer needs to verify the change locally, including any required environment variables and the local dev command.

**## Trade-offs** — decisions made, limitations, and any follow-on work worth noting.

The PR description is the permanent record of the decision. Write it for someone who wasn't in the room when the work was done.

---

## Documentation

Good documentation is part of the work, not a task for later.

**The README is a contract.** If someone clones this repo, follows the README, and something doesn't work, that is a bug. Keep it accurate and complete.

**Document decisions, not just outcomes.** When a non-obvious decision is made — a design trade-off, a workaround, a deliberate simplification — leave a record of why. This might be a comment in a skill file or a note in the README.

---

## Consistency

Follow the patterns already established across skill files. If you introduce a new pattern, document why the existing one was insufficient. Inconsistency has a real cost — it forces every reader to hold multiple mental models of how things work.

---

## Work Efficiently

Be deliberate about what actions you take and when. Before reaching for a tool, ask whether it's actually necessary.

Don't re-read files you just wrote or edited. Don't echo back large blocks of content unless asked. Batch related edits into a single operation. Skip narrating what you're about to do — just do it.

The same principle that applies to skills applies here: use the minimum needed to get the job done correctly.

---

## Working with Claude Code

- **Ask over guess.** If the intent behind a change is unclear, ask before proceeding. A wrong assumption is more expensive than a short clarifying question.
- **Prefer small changes.** Make the minimum change needed to accomplish the goal. Don't refactor surrounding code, rename variables, or adjust formatting unless explicitly asked.
- **Don't exceed stated scope.** If you notice something worth fixing while working on something else, flag it rather than silently fixing it.
- **Surface unexpected findings.** If you discover something surprising — a broken workflow step, a missing auth check, an inconsistency between skill files — say so rather than working around it quietly.

---

_This file should be updated when new architectural decisions are made or project-wide conventions are established._
