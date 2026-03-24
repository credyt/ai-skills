#!/usr/bin/env bash
# Configure CREDYT_API_KEY in a Claude Code settings file.
#
# Usage: configure-api-key.sh --key <api-key> --target <settings-file> [--force]
#
# Exit codes:
#   0  Key was set successfully
#   1  Key already exists; re-run with --force to overwrite
#   2  Error (missing args, jq not found, invalid JSON, write failure)
#
# Stdout: JSON result — { "status": "set"|"exists"|"error", "target": "...", "message": "..." }
# Stderr: diagnostic messages only

set -euo pipefail

KEY=""
TARGET=""
FORCE=false

usage() {
  cat >&2 <<'EOF'
Usage: configure-api-key.sh --key <api-key> --target <path> [--force]

  --key     Credyt API key. Accepts "key_..." or pre-prefixed "Bearer key_..."
  --target  Path to Claude Code settings file (e.g. ~/.claude/settings.json)
  --force   Overwrite an existing CREDYT_API_KEY without confirmation
  --help    Show this message
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --key)    KEY="$2";    shift 2 ;;
    --target) TARGET="$2"; shift 2 ;;
    --force)  FORCE=true;  shift   ;;
    --help)   usage; exit 0 ;;
    *)        echo "Unknown option: $1" >&2; usage; exit 2 ;;
  esac
done

if [[ -z "$KEY" || -z "$TARGET" ]]; then
  echo "Error: --key and --target are required" >&2
  usage
  exit 2
fi

# Resolve named targets to their canonical paths
case "$TARGET" in
  global)  TARGET="~/.claude/settings.json" ;;
  project) TARGET=".claude/settings.local.json" ;;
esac

# Normalise: ensure Bearer prefix
if [[ "$KEY" != "Bearer "* ]]; then
  KEY="Bearer $KEY"
fi

# Require jq for safe JSON manipulation
if ! command -v jq &>/dev/null; then
  printf '{"status":"error","message":"jq is required but not installed. Install with: brew install jq (macOS) or apt install jq (Linux)"}\n'
  exit 2
fi

# Expand ~ in target path
TARGET="${TARGET/#\~/$HOME}"

# Case 1: File does not exist — create it from scratch
if [[ ! -f "$TARGET" ]]; then
  mkdir -p "$(dirname "$TARGET")"
  jq -n --arg key "$KEY" '{"env":{"CREDYT_API_KEY":$key}}' > "$TARGET"
  printf '{"status":"set","target":"%s","message":"Created settings file with API key"}\n' "$TARGET"
  exit 0
fi

# File exists — validate it is parseable JSON before touching it
if ! jq empty "$TARGET" 2>/dev/null; then
  printf '{"status":"error","target":"%s","message":"Settings file exists but contains invalid JSON"}\n' "$TARGET"
  exit 2
fi

# Case 2: Key already set — exit 1 unless --force
EXISTING=$(jq -r '.env.CREDYT_API_KEY // empty' "$TARGET")
if [[ -n "$EXISTING" ]] && [[ "$FORCE" != true ]]; then
  printf '{"status":"exists","target":"%s","message":"CREDYT_API_KEY is already set. Re-run with --force to overwrite."}\n' "$TARGET"
  exit 1
fi

# Case 3 / 4: Merge key into the file via a temp file (safe write)
TMP=$(mktemp)
jq --arg key "$KEY" '.env.CREDYT_API_KEY = $key' "$TARGET" > "$TMP" && mv "$TMP" "$TARGET"

if [[ -n "$EXISTING" ]]; then
  printf '{"status":"set","target":"%s","message":"API key updated (previous value overwritten)"}\n' "$TARGET"
else
  printf '{"status":"set","target":"%s","message":"API key added to existing settings file"}\n' "$TARGET"
fi
exit 0
