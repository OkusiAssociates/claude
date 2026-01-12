#!/bin/bash
# Sync Agents.json from dejavu2-cli repository to local agents directory
set -euo pipefail
shopt -s inherit_errexit shift_verbose

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

declare -- AGENTS_SRC=/ai/scripts/dejavu2-cli/Agents/Agents.json
declare -- AGENTS_DST="$SCRIPT_DIR"/Agents.json
readonly -- AGENTS_SRC AGENTS_DST

if [[ ! -f "$AGENTS_SRC" ]]; then
  >&2 echo "$SCRIPT_NAME: ✗ Source not found: $AGENTS_SRC"
  exit 1
fi

cp "$AGENTS_SRC" "$AGENTS_DST"
echo "$SCRIPT_NAME: ✓ Synced Agents.json from dejavu2-cli"

#fin
