#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="$REPO_DIR/skills"
TARGET_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

if [[ ! -d "$SRC_DIR" ]]; then
  echo "ERROR: source skills dir not found: $SRC_DIR" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"

if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete "$SRC_DIR/" "$TARGET_DIR/"
else
  rm -rf "$TARGET_DIR"/*
  cp -R "$SRC_DIR/"* "$TARGET_DIR/"
fi

echo "Installed skills to: $TARGET_DIR"
ls -1 "$TARGET_DIR" | sed 's/^/- /'
