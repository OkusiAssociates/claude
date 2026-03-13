#!/bin/bash
# Sync Agents.json from dejavu2-cli repository to local agents directory
set -euo pipefail
shopt -s inherit_errexit

#shellcheck disable=SC2034
declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*}
declare -r SCRIPT_NAME=${SCRIPT_PATH##*/}

declare -r AGENTS_SRC=/ai/scripts/dejavu2-cli/Agents/Agents.json
declare -r AGENTS_DST="$SCRIPT_DIR"/Agents.json

if [[ ! -f "$AGENTS_SRC" ]]; then
  >&2 echo "$SCRIPT_NAME: ✗ Source not found: $AGENTS_SRC"
  exit 1
fi

cp -a "$AGENTS_SRC" "$AGENTS_DST"
echo "$SCRIPT_NAME: ✓ Synced Agents.json from dejavu2-cli"

#fin
