#!/usr/bin/env bash
set -euo pipefail

FILE="${1:-RESULT.tsv}"

if [[ ! -f "$FILE" ]]; then
  echo "Missing file: $FILE" >&2
  exit 1
fi

echo "Column-count distribution for $FILE:"
awk -F '\t' '{print NF}' "$FILE" | sort | uniq -c

echo
if [[ "$(awk -F '\t' '{print NF}' "$FILE" | sort -u | wc -l | tr -d ' ')" != "1" ]]; then
  echo "ERROR: inconsistent column counts" >&2
  exit 2
fi

echo "OK: consistent column count"
