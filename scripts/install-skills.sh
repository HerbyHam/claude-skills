#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="$REPO_DIR/skills"
TARGET_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

if [[ ! -d "$SRC_DIR" ]]; then
  echo "ERROR: source skills dir not found: $SRC_DIR" >&2
  exit 1
fi

# If target is already a symlink pointing to the right place, nothing to do
if [[ -L "$TARGET_DIR" && "$(readlink "$TARGET_DIR")" == "$SRC_DIR" ]]; then
  echo "Symlink already exists: $TARGET_DIR -> $SRC_DIR"
  ls -1 "$TARGET_DIR" | sed 's/^/- /'
  exit 0
fi

# Remove whatever is currently at the target path
if [[ -L "$TARGET_DIR" ]]; then
  echo "Removing stale symlink: $TARGET_DIR -> $(readlink "$TARGET_DIR")"
  rm "$TARGET_DIR"
elif [[ -d "$TARGET_DIR" ]]; then
  echo "Removing existing skills directory: $TARGET_DIR"
  rm -rf "$TARGET_DIR"
fi

# Ensure parent directory exists
mkdir -p "$(dirname "$TARGET_DIR")"

# Create symlink
ln -s "$SRC_DIR" "$TARGET_DIR"

echo "Linked skills: $TARGET_DIR -> $SRC_DIR"
ls -1 "$TARGET_DIR" | sed 's/^/- /'
