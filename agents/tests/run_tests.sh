#!/bin/bash
# run_tests.sh - Test runner for claude.agent test suite
# shellcheck disable=SC2034
set -euo pipefail
shopt -s inherit_errexit

# ============================================================================
# Script Metadata
# ============================================================================

declare -r VERSION=1.0.0
declare -r TEST_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
declare -r SCRIPT_NAME=${0##*/}

# Colors
if [[ -t 1 ]]; then
  declare -r RED=$'\033[0;31m'
  declare -r GREEN=$'\033[0;32m'
  declare -r YELLOW=$'\033[0;33m'
  declare -r CYAN=$'\033[0;36m'
  declare -r BOLD=$'\033[1m'
  declare -r NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' BOLD='' NC=''
fi

# Test results
declare -gi TOTAL_TESTS=0
declare -gi TOTAL_PASSED=0
declare -gi TOTAL_FAILED=0
declare -gi TOTAL_SKIPPED=0

# ============================================================================
# Utility Functions
# ============================================================================

info()  { printf '%s◉%s %s\n' "$CYAN" "$NC" "$*"; }
error() { printf '%s✗%s %s\n' "$RED" "$NC" "$*" >&2; }
die()   { error "$*"; exit 1; }

show_help() {
  cat <<EOF
$SCRIPT_NAME $VERSION - Test runner for claude.agent

USAGE
    $SCRIPT_NAME [OPTIONS] [TEST_SUITE...]

OPTIONS
    -v, --verbose     Show individual test output
    -q, --quiet       Suppress test output, show only summary
    -l, --list        List available test suites
    -h, --help        Show this help message
    -V, --version     Show version

TEST SUITES
    argument_parsing  Tests for argument parsing
    agent_resolution  Tests for agent name resolution
    build_command     Tests for build_command (isolation, BCS, agent_dir)
    integration       Integration tests with mocked claude.x
    all               Run all test suites (default)

EXAMPLES
    $SCRIPT_NAME                    # Run all tests
    $SCRIPT_NAME integration        # Run only integration tests
    $SCRIPT_NAME -v argument        # Run argument tests with verbose output
    $SCRIPT_NAME build integration  # Run multiple suites

EOF
}

show_version() {
  printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"
}

list_suites() {
  echo "Available test suites:"
  echo "  argument_parsing  - Tests for argument parsing"
  echo "  agent_resolution  - Tests for agent name resolution"
  echo "  build_command     - Tests for build_command"
  echo "  integration       - Integration tests"
  echo "  all               - Run all test suites"
}

# ============================================================================
# Test Suite Runner
# ============================================================================

run_suite() {
  local suite=$1
  local script="$TEST_DIR/test_${suite}.sh"

  if [[ ! -f "$script" ]]; then
    error "Test suite not found: $suite"
    return 1
  fi

  # Source the framework to get counters
  source "$TEST_DIR/test_framework.sh"

  # Run the test suite
  source "$script"
  main

  # Aggregate results
  ((TOTAL_TESTS += TESTS_RUN))
  ((TOTAL_PASSED += TESTS_PASSED))
  ((TOTAL_FAILED += TESTS_FAILED))
  ((TOTAL_SKIPPED += TESTS_SKIPPED))

  # Reset counters for next suite
  TESTS_RUN=0
  TESTS_PASSED=0
  TESTS_FAILED=0
  TESTS_SKIPPED=0
}

# ============================================================================
# Main
# ============================================================================

main() {
  local verbose=0
  local quiet=0
  local -a suites=()

  # Parse arguments
  while (($#)); do
    case $1 in
      -v|--verbose) verbose=1 ;;
      -q|--quiet)   quiet=1 ;;
      -l|--list)    list_suites; exit 0 ;;
      -h|--help)    show_help; exit 0 ;;
      -V|--version) show_version; exit 0 ;;
      -*)           die "Unknown option: $1" ;;
      *)            suites+=("$1") ;;
    esac
    shift
  done

  # Default to all suites
  if ((${#suites[@]} == 0)) || [[ "${suites[0]}" == all ]]; then
    suites=(argument_parsing agent_resolution build_command integration)
  fi

  # Expand partial names
  local -a expanded_suites=()
  for suite in "${suites[@]}"; do
    case $suite in
      arg*) expanded_suites+=(argument_parsing) ;;
      agent*|res*) expanded_suites+=(agent_resolution) ;;
      build*|cmd*|bcs*|iso*) expanded_suites+=(build_command) ;;
      int*) expanded_suites+=(integration) ;;
      all) expanded_suites+=(argument_parsing agent_resolution build_command integration) ;;
      *) expanded_suites+=("$suite") ;;
    esac
  done

  echo
  echo "${BOLD}${CYAN}claude.agent Test Suite${NC}"
  echo "${BOLD}========================${NC}"

  # Run each suite
  local suite_count=0
  local suite_failed=0
  for suite in "${expanded_suites[@]}"; do
    ((suite_count+=1))

    if ! run_suite "$suite"; then
      ((suite_failed+=1))
    fi
  done

  # Print summary
  echo
  echo "${BOLD}=== Overall Summary ===${NC}"
  echo
  echo "  Suites run: $suite_count"
  echo "  Total tests: $TOTAL_TESTS"
  echo "  ${GREEN}Passed: $TOTAL_PASSED${NC}"
  echo "  ${RED}Failed: $TOTAL_FAILED${NC}"
  echo "  ${YELLOW}Skipped: $TOTAL_SKIPPED${NC}"
  echo

  if ((TOTAL_FAILED > 0)); then
    echo "${RED}Some tests failed.${NC}"
    return 1
  else
    echo "${GREEN}All tests passed.${NC}"
    return 0
  fi
}

main "$@"
#fin
