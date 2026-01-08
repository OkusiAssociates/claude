#!/usr/bin/env bash
#shellcheck disable=SC2015,SC2155
# Wrapper for claude code with 'dangerous' permissions and optional Agent system prompts
set -euo pipefail
shopt -s inherit_errexit extglob nullglob

declare -r VERSION=1.2.0
declare -r SCRIPT_PATH=$(realpath -e -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

declare -- AGENTS_JSON=${AGENTS_JSON:-"$SCRIPT_DIR"/agents/Agents.json}
if [[ ! -f "$AGENTS_JSON" ]]; then
  declare -a locfiles=()
  declare -- locfile
  readarray -t locfiles < <(locate -b '\Agents.json' | grep -v 'checkpoint\|backup' | grep 'Agents.json$')
  for locfile in "${locfiles[@]}"; do
    [[ -L $locfile ]] && continue ||:
    [[ -f $locfile ]] || continue
    AGENTS_JSON="$locfile"
    break
  done
fi
readonly AGENTS_JSON

declare -i VERBOSE=0
if [[ -t 2 ]]; then
  declare -r RED=$'\033[0;31m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  declare -r RED='' CYAN='' NC=''
fi
info() { ((VERBOSE)) || return 0; >&2 echo "$SCRIPT_NAME: ${CYAN}◉${NC} $*"; }
error() { >&2 echo "$SCRIPT_NAME: ${RED}✗${NC} $*"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

# Pluralization helper: returns 's' unless count is 1
s() { (( ${1:-1} == 1 )) || echo -n 's'; }

has_conversation() {
  # Check if a conversation exists for the current directory
  # Returns 0 (success) if conversation exists, 1 otherwise

  local -- project_dir=${PWD//\//-}  # Replace / with -
  local -- project_path="$HOME"/.claude/projects/"$project_dir"

  # Check if directory exists and contains .jsonl files
  [[ -d "$project_path" ]] && compgen -G "$project_path"/*.jsonl >/dev/null 2>&1
}

show_help() {
  cat <<EOT
$SCRIPT_NAME $VERSION - 'dangerous' wrapper for claude code

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
    -c, --continue      Force continue previous conversation
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
    --system-prompt TEXT        Replace default prompt (CLAUDE.md ignored)
    --system-prompt-file FILE   Replace default prompt from file
    --append-system-prompt TEXT Append to default prompt (CLAUDE.md loaded)
    --append-system-prompt-file FILE  Append to default prompt from file
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
    jq -r 'keys[]' "$AGENTS_JSON" | cut -d' ' -f1
    )
echo "${Agents[*]}" | fold -s -w 72 |sed 's/^/    /g')

    (Use 'dv2-agents list' for detailed agent information)

NOTES
    Agents.json Location:
      Bundled: $SCRIPT_DIR/agents/Agents.json
      Override: AGENTS_JSON=/path/to/custom/Agents.json

    The bundled Agents.json is included in the repository.
    Use the AGENTS_JSON environment variable to override.

ENVIRONMENT
    AGENTS_JSON         Override path to Agents.json
    CLAUDE_CODE_MAX_OUTPUT_TOKENS
                        Max output tokens (default: 32000)

EXIT CODES
    0   Success
    1   Agent not found, Agents.json not found, or missing systemprompt
    22  Invalid option argument (EINVAL)
EOT
}

declare -ar addDirDefaultDirs=(
 "$HOME"
 /tmp
 /ai
 /usr/local/
 /usr/share
)

main() {
  local -a reference_files=()
  local -- agent_tag agent_key systemprompt ref_file

  [[ -n "$AGENTS_JSON" ]] || die 1 'Agents.json not found'

  # Parse arguments
  local -i query_flag=0 continue_flag=-1  # -1=auto-detect, 0=no, 1=yes
  local -- systemPrompt=''
  local -a allowedTools=() appendSystemPrompt=() addDir=( "${addDirDefaultDirs[@]}" )
  local -a claude_cmd=(
    --allowedTools Read Write Edit Bash
    --permission-mode acceptEdits
  )
  ((EUID==0)) || claude_cmd+=(--dangerously-skip-permissions)

  while (($#)); do
    case $1 in
      -V|--version)
        echo "$SCRIPT_NAME $VERSION"
        "$(command -v claude)" --version
        return 0
        ;;
      -h|--help)
        show_help
        return 0
        ;;

      -c|--continue)
        continue_flag=1
        ;;
      -n|--new|--no-continue)
        continue_flag=0
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
          (($#==1)) && break ||:
          (($#>1)) && [[ ${2:0:1} == '-' ]] && break ||:
          shift
        done
        ;;

      --add-dir)
        shift
        while (($#)) && [[ "${1:0:1}" != '-' ]]; do
          addDir+=("$1")
          (($#==1)) && break ||:
          (($#>1)) && [[ ${2:0:1} == '-' ]] && break ||:
          shift
        done
        ;;

      --append-system-prompt)
        (($#>1)) || die 22 "Option ${1@Q} requires an argument"
        shift
        appendSystemPrompt+=("$1")
        ;;

      --system-prompt)
        (($#>1)) || die 22 "Option ${1@Q} requires an argument"
        shift
        systemPrompt=$1
        ;;

      --system-prompt-file)
        (($#>1)) || die 22 "Option ${1@Q} requires an argument"
        shift
        [[ -f $1 ]] || die 1 "File not found: ${1@Q}"
        systemPrompt=$(<"$1")
        ;;

      --append-system-prompt-file)
        (($#>1)) || die 22 "Option ${1@Q} requires an argument"
        shift
        [[ -f $1 ]] || die 1 "File not found: ${1@Q}"
        appendSystemPrompt+=("$(<"$1")")
        ;;

      -v|--verbose)  VERBOSE+=1 ;;
      -q|--quiet)    VERBOSE=0 ;;
      --)
        shift
        (($#)) && claude_cmd+=("$@") ||:
        break
        ;;

      -[VhcnT]*) #shellcheck disable=SC2046
        set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}" ;;

      -*)
        claude_cmd+=("$1")
        ;;
      *)
        query_flag=1
        claude_cmd+=("$1")
        ;;
    esac
    shift || break
  done

  # Handle conversation continuation
  if ((continue_flag == -1)); then
    # Auto-detect: only continue if conversation exists
    if has_conversation; then
      claude_cmd+=(--continue)
      info 'Continuing existing conversation'
    else
      info 'No existing conversation found, starting fresh'
    fi
  elif ((continue_flag == 1)); then
    # User explicitly requested --continue
    claude_cmd+=(--continue)
    info 'Continuing (explicit)'
  fi
  # If continue_flag == 0, don't add --continue (user said --new)

  ((${#allowedTools[@]})) \
      && claude_cmd+=(--allowedTools "${allowedTools[@]}")

  [[ -n "$systemPrompt" ]] \
      && claude_cmd+=(--system-prompt "$systemPrompt")

  ((${#appendSystemPrompt[@]})) \
      && claude_cmd+=(--append-system-prompt "${appendSystemPrompt[@]}")

  ((${#addDir[@]})) \
      && claude_cmd+=(--add-dir "${addDir[@]}")

  ((query_flag)) \
      && claude_cmd+=(--print)

  ((VERBOSE)) \
      && info "$(declare -p claude_cmd | tr '[' $'\n')" || :

  echo -ne "\033]0;◯ ${agent_tag:-claude.x} .../$(basename -- "$PWD")\007"
  exec "$(command -v claude)" "${claude_cmd[@]}"
}

main "$@"
#fin
