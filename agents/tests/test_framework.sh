#!/bin/bash
# test_framework.sh - Testing utilities for claude-agent test suite
# shellcheck disable=SC2034
set -euo pipefail
shopt -s inherit_errexit

# ============================================================================
# Test Framework Configuration
# ============================================================================

# Path configuration - use explicit checks to avoid readonly errors
if [[ -z "${TEST_DIR:-}" ]]; then
  TEST_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
fi
if [[ -z "${SCRIPT_DIR:-}" ]]; then
  SCRIPT_DIR=${TEST_DIR%/*}
fi
if [[ -z "${CLAUDE_AGENT:-}" ]]; then
  CLAUDE_AGENT="$SCRIPT_DIR/claude-agent"
fi

# Colors - set only if not already set (suppress readonly warnings)
if [[ -z "${RED:-}" ]]; then
  {
    if [[ -t 1 ]]; then
      RED=$'\033[0;31m'
      GREEN=$'\033[0;32m'
      YELLOW=$'\033[0;33m'
      CYAN=$'\033[0;36m'
      BOLD=$'\033[1m'
      NC=$'\033[0m'
    else
      RED='' GREEN='' YELLOW='' CYAN='' BOLD='' NC=''
    fi
  } 2>/dev/null
fi

# Test counters (reset each source)
declare -gi TESTS_RUN=0
declare -gi TESTS_PASSED=0
declare -gi TESTS_FAILED=0
declare -gi TESTS_SKIPPED=0

# Test output
declare -g CURRENT_TEST=''
declare -ga FAILED_TESTS=()

# ============================================================================
# Test Setup and Teardown
# ============================================================================

declare -g TEST_TMPDIR=''

setup_test_env() {
  TEST_TMPDIR=$(mktemp -d -t claude-agent-test.XXXXXX)

  # Create mock Agents.json for testing
  cat > "$TEST_TMPDIR/Agents.json" <<'EOF'
{
  "Leet - Full-Stack Programmer": {
    "category": "Specialist",
    "bcs_context": true,
    "systemprompt": "You are Leet, a programmer.",
    "available": 1,
    "enabled": 1
  },
  "DrAA - Applied Anthropology": {
    "category": "Specialist",
    "isolated": true,
    "agent_dir": "/tmp/draa-test",
    "systemprompt": "You are DrAA.",
    "available": 1,
    "enabled": 1
  },
  "Trans - Translator": {
    "category": "Specialist",
    "systemprompt": "You are Trans.",
    "available": 1,
    "enabled": 1
  },
  "Test Agent - No BCS": {
    "category": "Test",
    "isolated": false,
    "systemprompt": "Test agent.",
    "available": 1,
    "enabled": 1
  }
}
EOF

  # Create mock claude.x that records arguments
  cat > "$TEST_TMPDIR/claude.x" <<'EOF'
#!/bin/bash
# Mock claude.x - records arguments to file
echo "CLAUDE_X_ARGS: $*" >> "${MOCK_OUTPUT_FILE:-/tmp/mock-claude-x.log}"
echo "CLAUDE_X_CWD: $PWD" >> "${MOCK_OUTPUT_FILE:-/tmp/mock-claude-x.log}"
exit 0
EOF
  chmod +x "$TEST_TMPDIR/claude.x"

  # Create mock shlock that passes through
  cat > "$TEST_TMPDIR/shlock" <<'EOF'
#!/bin/bash
# Mock shlock - skip locking, just exec the command
while [[ $1 == --* || $1 != -- ]]; do
  [[ $1 == -- ]] && break
  shift
done
shift  # skip lockname
[[ $1 == -- ]] && shift  # skip --
exec "$@"
EOF
  chmod +x "$TEST_TMPDIR/shlock"

  # Create mock bcs command
  cat > "$TEST_TMPDIR/bcs" <<'EOF'
#!/bin/bash
if [[ $1 == default && $2 == -f ]]; then
  echo "/usr/share/yatti/bash-coding-standard/data/BASH-CODING-STANDARD.md"
fi
EOF
  chmod +x "$TEST_TMPDIR/bcs"

  # Export test environment
  export PATH="$TEST_TMPDIR:$PATH"
  export MOCK_OUTPUT_FILE="$TEST_TMPDIR/mock-output.log"

  # Create draa test directory
  mkdir -p /tmp/draa-test
}

teardown_test_env() {
  if [[ -n "$TEST_TMPDIR" && -d "$TEST_TMPDIR" ]]; then
    rm -rf "$TEST_TMPDIR"
  fi
  rm -rf /tmp/draa-test 2>/dev/null || true
}

# ============================================================================
# Test Assertion Functions
# ============================================================================

assert_equals() {
  local expected=$1
  local actual=$2
  local message=${3:-"Expected '$expected', got '$actual'"}

  if [[ "$expected" == "$actual" ]]; then
    return 0
  else
    echo "  ${RED}FAIL${NC}: $message"
    echo "    Expected: $expected"
    echo "    Actual:   $actual"
    return 1
  fi
}

assert_contains() {
  local haystack=$1
  local needle=$2
  local message=${3:-"Expected to contain '$needle'"}

  if [[ "$haystack" == *"$needle"* ]]; then
    return 0
  else
    echo "  ${RED}FAIL${NC}: $message"
    echo "    String: $haystack"
    echo "    Missing: $needle"
    return 1
  fi
}

assert_not_contains() {
  local haystack=$1
  local needle=$2
  local message=${3:-"Expected to NOT contain '$needle'"}

  if [[ "$haystack" != *"$needle"* ]]; then
    return 0
  else
    echo "  ${RED}FAIL${NC}: $message"
    echo "    String: $haystack"
    echo "    Found (unexpected): $needle"
    return 1
  fi
}

assert_exit_code() {
  local expected=$1
  local actual=$2
  local message=${3:-"Expected exit code $expected, got $actual"}

  if ((expected == actual)); then
    return 0
  else
    echo "  ${RED}FAIL${NC}: $message"
    return 1
  fi
}

assert_file_exists() {
  local filepath=$1
  local message=${2:-"Expected file to exist: $filepath"}

  if [[ -f "$filepath" ]]; then
    return 0
  else
    echo "  ${RED}FAIL${NC}: $message"
    return 1
  fi
}

assert_file_contains() {
  local filepath=$1
  local pattern=$2
  local message=${3:-"Expected file $filepath to contain '$pattern'"}

  if [[ -f "$filepath" ]] && grep -q "$pattern" "$filepath"; then
    return 0
  else
    echo "  ${RED}FAIL${NC}: $message"
    return 1
  fi
}

assert_regex_match() {
  local string=$1
  local pattern=$2
  local message=${3:-"Expected to match pattern '$pattern'"}

  if [[ "$string" =~ $pattern ]]; then
    return 0
  else
    echo "  ${RED}FAIL${NC}: $message"
    echo "    String: $string"
    echo "    Pattern: $pattern"
    return 1
  fi
}

# ============================================================================
# Test Execution Functions
# ============================================================================

run_test() {
  local test_name=$1
  local test_func=$2

  CURRENT_TEST=$test_name
  ((TESTS_RUN+=1))

  printf "  %-50s " "$test_name"

  # Run test in subshell to isolate failures
  local output
  local exit_code=0
  output=$($test_func 2>&1) || exit_code=$?

  if ((exit_code == 0)); then
    ((TESTS_PASSED+=1))
    echo "${GREEN}PASS${NC}"
  elif ((exit_code == 77)); then
    ((TESTS_SKIPPED+=1))
    echo "${YELLOW}SKIP${NC}"
    [[ -n "$output" ]] && echo "    Reason: $output"
  else
    ((TESTS_FAILED+=1))
    FAILED_TESTS+=("$test_name")
    echo "${RED}FAIL${NC}"
    [[ -n "$output" ]] && echo "$output" | sed 's/^/    /'
  fi
}

skip_test() {
  local reason=${1:-"Skipped"}
  echo "$reason"
  exit 77
}

# ============================================================================
# Test Suite Functions
# ============================================================================

begin_test_suite() {
  local suite_name=$1
  echo
  echo "${BOLD}${CYAN}=== $suite_name ===${NC}"
  echo
}

end_test_suite() {
  echo
}

print_test_summary() {
  echo
  echo "${BOLD}=== Test Summary ===${NC}"
  echo
  echo "  Total:   $TESTS_RUN"
  echo "  ${GREEN}Passed:  $TESTS_PASSED${NC}"
  echo "  ${RED}Failed:  $TESTS_FAILED${NC}"
  echo "  ${YELLOW}Skipped: $TESTS_SKIPPED${NC}"

  if ((TESTS_FAILED > 0)); then
    echo
    echo "${RED}Failed tests:${NC}"
    for test in "${FAILED_TESTS[@]}"; do
      echo "  - $test"
    done
  fi

  echo

  if ((TESTS_FAILED > 0)); then
    return 1
  fi
  return 0
}

# ============================================================================
# Utility Functions
# ============================================================================

# Run claude-agent with test Agents.json
run_claude_agent() {
  local args=("$@")

  # Clear previous mock output
  : > "$MOCK_OUTPUT_FILE"

  # Run with modified script that uses test Agents.json
  (
    cd "$TEST_TMPDIR"

    # Create a wrapper that overrides AGENTS_JSON path
    cat > run-test.sh <<WRAPPER
#!/bin/bash
export PATH="$TEST_TMPDIR:\$PATH"
# Patch the AGENTS_JSON path in claude-agent
sed 's|declare -r AGENTS_JSON=.*|declare -r AGENTS_JSON="$TEST_TMPDIR/Agents.json"|' \
  "$CLAUDE_AGENT" > "$TEST_TMPDIR/claude-agent-test"
chmod +x "$TEST_TMPDIR/claude-agent-test"
"$TEST_TMPDIR/claude-agent-test" "\$@"
WRAPPER
    chmod +x run-test.sh
    ./run-test.sh "${args[@]}"
  )
}

# Get mock claude.x output
get_mock_output() {
  cat "$MOCK_OUTPUT_FILE" 2>/dev/null || true
}

# Source this file for test utilities
:
#fin
