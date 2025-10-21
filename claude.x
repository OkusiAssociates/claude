#!/bin/bash
#shellcheck disable=SC2015
# Wrapper for claude code with 'dangerous' permissions and optional Agent system prompts
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='1.0.5'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

declare -- AGENTS_JSON="${SCRIPT_DIR}/agents/Agents.json"
if [[ ! -f "$AGENTS_JSON" ]]; then
  AGENTS_JSON=$(locate -b '\Agents.json' | grep '/Agents/Agents.json' || echo '')
fi
readonly -- AGENTS_JSON

if [[ -t 2 ]]; then
  declare -- RED=$'\033[0;31m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  declare -- RED='' CYAN='' NC=''
fi
declare -i VERBOSE=0
info() { ((VERBOSE)) || return 0; >&2 echo "$SCRIPT_NAME: ${CYAN}◉${NC} $*"; }
error() { >&2 echo "$SCRIPT_NAME: ${RED}✗${NC} $*"; }
die() { (($#>1)) && error "${@:2}"; exit "${1:0}"; }
s() { (( ${1:-1} == 1 )) || echo -n 's'; }
#shellcheck disable=SC2120
trim() {
  if (($#)); then
    local -- v
    [[ $1 == '-e' ]] && { shift; v="$(echo -en "$*")"; } || v="$*"
    v="${v#"${v%%[![:blank:]]*}"}"
    echo -n "${v%"${v##*[![:blank:]]}"}"
    return 0
  fi
  if [[ ! -t 0 ]]; then
    local -- REPLY
    while IFS= read -r REPLY || [[ -n "$REPLY" ]]; do
      REPLY="${REPLY#"${REPLY%%[![:blank:]]*}"}"
      REPLY="${REPLY%"${REPLY##*[![:blank:]]}"}"
      echo "$REPLY"
    done
  fi
  return 0
}


show_help() {
  cat <<EOT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  $SCRIPT_NAME $VERSION - 'dangerous' wrapper for claude code
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DESCRIPTION
    Runs claude with 'dangerous' permissions (unrestricted file operations)
    and optional Agent system prompts loaded from Agents.json.

    Agent definitions are loaded from:
      1. Bundled: $SCRIPT_DIR/agents/Agents.json (included in repository)
      2. Fallback: System-wide Agents.json (found via locate)

USAGE
    $SCRIPT_NAME [OPTIONS] [PROMPT]

OPTIONS
    -T AGENT            Load agent template (see Available Agents below)
                        Case-insensitive matching supported

    -n, --new           Start fresh conversation (don't continue previous)
    --no-continue       Alias for --new

    -v, --verbose       Increase verbosity (repeatable: -vv, -vvv)
    -q, --quiet         Suppress informational messages

    -h, --help          Show this help message
    -V, --version       Show version information

DANGEROUS DEFAULTS
    The following permissions are automatically configured:

$(echo "${claude_cmd[*]}" | fold -s -w 72 |sed 's/^/        /g')

    ▲ WARNING: These settings allow unrestricted file operations without
               confirmation prompts. Use with caution.

PASS-THROUGH CLAUDE OPTIONS
    The following claude CLI options can be used and will be passed through:

    --debug                     Enable debug output
    --verbose                   Verbose mode
    --print                     One-shot query mode (auto-enabled with PROMPT)
    --output-format FORMAT      Set output format
    --input-format FORMAT       Set input format
    --append-system-prompt TEXT Add custom system prompt
    --add-dir PATH              Add directory to working context
    --continue, -c              Resume previous conversation (default)
    --resume, -r                Resume from specific point

    (See 'claude --help' for complete list)

EXAMPLES
    Show version:
        $SCRIPT_NAME --version
        $SCRIPT_NAME -V

    Interactive session with dangerous permissions:
        $SCRIPT_NAME

    Load specific agent template:
        $SCRIPT_NAME -T leet
        $SCRIPT_NAME -T trans
        $SCRIPT_NAME -T LEET          # Case-insensitive

    Use agent wrapper scripts (recommended):
        agents/leet                   # Leet agent with BCS context
        agents/bcs-compliance         # BCS compliance expert
        agents/trans                  # Translation specialist

    Add additional context directories:
        $SCRIPT_NAME -T leet --add-dir /data --add-dir /var/www

    One-shot query (auto-enables --print):
        $SCRIPT_NAME "Explain the main() function in script.sh"
        $SCRIPT_NAME -T trans "Translate this Indonesian text"

    Fresh conversation with verbose output:
        $SCRIPT_NAME --new -vv -T leet

    Debug mode (shows full command):
        $SCRIPT_NAME -vv --help       # Shows claude_cmd array

AVAILABLE AGENTS
$(readarray -t Agents < <(
    #shellcheck disable=SC2120
    jq -r 'keys[]' "$AGENTS_JSON" | cut -d' ' -f1 | trim
    )
echo "${Agents[*]}" | fold -s -w 72 |sed 's/^/    /g')

    (Use 'dv2-agents list' for detailed agent information)

NOTES
    Agents.json Location:
      Current: $AGENTS_JSON
      Source:  /ai/scripts/dejavu2-cli/Agents/Agents.json

    For developers with dejavu2-cli:
      - Agents.json auto-syncs when using './.gitcommit'
      - Manual sync: agents/sync-agents-json

    For end users:
      - Agents.json is bundled in the repository
      - No external dependencies required

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOT
}

declare -ar addDirDefaultDirs=(
 "$HOME"
 /tmp
 /ai
 /usr/local/
 /usr/share
)

declare -a claude_cmd=(
  --allowedTools Read Write Edit Bash
  --permission-mode acceptEdits
  --dangerously-skip-permissions
)

main() {
  local -a reference_files=()
  local -- agent_tag agent_key systemprompt ref_file

  [[ -n "$AGENTS_JSON" ]] || die 1 'Agents.json not found'

  # Parse arguments
  local -i query_flag=0 continue_flag=1
  local -a allowedTools=() appendSystemPrompt=() addDir=( "${addDirDefaultDirs[@]}" )

  while (($#)); do
    case $1 in
      -c|--continue)
        continue_flag=1
        ;;
      -n|--new|--no-continue)
        continue_flag=0
        ;;

      -h|--help)
        show_help
        return 0
        ;;
      -V|--version)
        echo "$SCRIPT_NAME $VERSION"
        return 0
        ;;
      -T)
        (($# > 1)) || die 22 "Option ${1@Q} requires an argument"
        shift
        agent_tag=$1

        # Extract matching key from Agents.json (case-insensitive)
        agent_key=$(jq -r 'keys[]' "$AGENTS_JSON" | grep -i "^$agent_tag" | head -n1)
        [[ -n "$agent_key" ]] || die 1 "Agent ${agent_tag@Q} not found in $AGENTS_JSON"

        # Get systemprompt
        systemprompt=$(jq -r ".\"$agent_key\".systemprompt" "$AGENTS_JSON")
        [[ -n "$systemprompt" && "$systemprompt" != null ]] || die 1 "No systemprompt for agent ${agent_tag@Q}"
        claude_cmd+=(--append-system-prompt "$systemprompt")

        info "Loading Agent ${agent_tag@Q}"

        # Get knowledgebase files
        readarray -t reference_files < <(jq -r ".\"$agent_key\".knowledgebase" "$AGENTS_JSON")

        if ((${#reference_files[@]}==0)) || [[ ${reference_files[0]} == null || -z ${reference_files[0]} ]]; then
          reference_files=()
        else
          info "${#reference_files[@]} reference file$(s "${#reference_files[@]}") found"
          for ref_file in "${reference_files[@]}"; do
            [[ -f "$ref_file" ]] && claude_cmd+=(--append-system-prompt "$(<"$ref_file")")
          done
        fi
        ;;

      --allowedTools)
        shift
        while (($#)) && [[ "${1:0:1}" != '-' ]]; do
          allowedTools+=("$1")
          (($#==1)) && break
          (($#>1)) && [[ ${2:0:1} == '-' ]] && break || :
          shift
        done
        ;;

      --add-dir)
        shift
        while (($#)) && [[ "${1:0:1}" != '-' ]]; do
          addDir+=("$1")
          (($#==1)) && break
          (($#>1)) && [[ ${2:0:1} == '-' ]] && break || :
          shift
        done
        ;;

      --append-system-prompt)
        (($#>1)) || die 22 "Invalid option argument for ${1@Q}"
        shift
        appendSystemPrompt+=("$1")
        ;;

      -v|--verbose)  VERBOSE+=1 ;;
      -q|--quiet)    VERBOSE=0 ;;
      --)
        shift
        (($#)) && claude_cmd+=("$@")
        break
        ;;
      -[!-]?*)
        # Disaggregate combined short options: -vq becomes -v -q
        set -- "${1:0:2}" "-${1:2}" "${@:2}"
        continue
        ;;
      -*)
        claude_cmd+=("$1")
        ;;
      *)
        query_flag=1
        claude_cmd+=("$1")
        ;;
    esac
    shift || :
  done

  ((continue_flag)) \
      && claude_cmd+=(--continue)

  ((${#allowedTools[@]})) \
      && claude_cmd+=(--allowedTools "${allowedTools[@]}")

  ((${#appendSystemPrompt[@]})) \
      && claude_cmd+=(--append-system-prompt "${appendSystemPrompt[@]}")

  ((${#addDir[@]})) \
      && claude_cmd+=(--add-dir "${addDir[@]}")

  ((query_flag)) \
      && claude_cmd+=(--print)

  ((VERBOSE)) \
      && info "$(declare -p claude_cmd | tr '[' $'\n')" || :

  echo -ne "\033]0;◯ Leet .../$(basename -- "$PWD")\007"
  exec "$(command -v claude)" "${claude_cmd[@]}"
}

main "$@"

#fin
