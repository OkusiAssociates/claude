#!/bin/bash
# test_argument_parsing.sh - Tests for claude.agent argument parsing
# shellcheck disable=SC2034
set -euo pipefail
shopt -s inherit_errexit

# ============================================================================
# Setup
# ============================================================================

# shellcheck disable=SC2155
declare -g _THIS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$_THIS_DIR/test_framework.sh"

# ============================================================================
# Tests: Help and Version
# ============================================================================

test_help_flag() {
  local output
  output=$(run_claude_agent -T leet --help 2>&1) || true
  assert_contains "$output" "USAGE"
  assert_contains "$output" "OPTIONS"
  assert_contains "$output" "EXAMPLES"
}

test_help_short_flag() {
  local output
  output=$(run_claude_agent -T leet -h 2>&1) || true
  assert_contains "$output" "USAGE"
}

test_version_flag() {
  local output
  output=$(run_claude_agent -T leet --version 2>&1) || true
  assert_contains "$output" "claude.agent"
  assert_regex_match "$output" "[0-9]+\.[0-9]+\.[0-9]+"
}

test_version_short_flag() {
  local output
  output=$(run_claude_agent -T leet -V 2>&1) || true
  assert_contains "$output" "claude.agent"
}

# ============================================================================
# Tests: Agent Specification
# ============================================================================

test_agent_flag_long() {
  run_claude_agent --agent leet 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_contains "$output" "Leet - Full-Stack Programmer"
}

test_agent_flag_short() {
  run_claude_agent -T leet 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_contains "$output" "Leet - Full-Stack Programmer"
}

test_agent_flag_requires_argument() {
  local exit_code=0
  run_claude_agent -T 2>&1 || exit_code=$?
  assert_exit_code 22 "$exit_code" "Should exit with code 22 when -T has no argument"
}

test_no_agent_shows_help() {
  local exit_code=0
  run_claude_agent 2>&1 || exit_code=$?
  # Script exits with error when no agent specified
  # Exit code may be 1 (die) or 22 (EINVAL) depending on how the error is raised
  ((exit_code != 0)) || return 1
}

# ============================================================================
# Tests: List Agents
# ============================================================================

test_list_flag() {
  local output
  output=$(run_claude_agent --list 2>&1) || true
  assert_contains "$output" "Available agents"
  assert_contains "$output" "leet"
  assert_contains "$output" "draa"
}

test_list_short_flag() {
  local output
  output=$(run_claude_agent -l 2>&1) || true
  assert_contains "$output" "Available agents"
}

# ============================================================================
# Tests: New/Continue Flags
# ============================================================================

test_new_flag_long() {
  run_claude_agent -T leet --new 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_contains "$output" "--new"
}

test_new_flag_short() {
  run_claude_agent -T leet -n 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_contains "$output" "--new"
}

test_no_continue_flag() {
  run_claude_agent -T leet --no-continue 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_contains "$output" "--new"
}

test_continue_flag_long() {
  run_claude_agent -T leet --continue 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_contains "$output" "--continue"
}

test_continue_flag_short() {
  run_claude_agent -T leet -c 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_contains "$output" "--continue"
}

# ============================================================================
# Tests: Isolation Flags
# ============================================================================

test_isolated_flag_long() {
  run_claude_agent -T trans --isolated 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_contains "$output" "--setting-sources"
}

test_isolated_flag_short() {
  run_claude_agent -T trans -I 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_contains "$output" "--setting-sources"
}

test_no_isolated_flag() {
  # DrAA has isolated: true in Agents.json, but --no-isolated should override
  run_claude_agent -T draa --no-isolated 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_not_contains "$output" "--setting-sources"
}

# ============================================================================
# Tests: Max Tokens Flag
# ============================================================================

test_maxtokens_flag_long() {
  local output
  output=$(CLAUDE_CODE_MAX_OUTPUT_TOKENS=32000 run_claude_agent -T leet --maxtokens 2>&1) || true
  # The variable is set but we can't easily test it without more complex mocking
  # Just verify the command runs successfully
  assert_contains "$(get_mock_output)" "Leet"
}

test_maxtokens_flag_short() {
  local output
  output=$(run_claude_agent -T leet -M 2>&1) || true
  assert_contains "$(get_mock_output)" "Leet"
}

# ============================================================================
# Tests: Combined Short Options
# ============================================================================

test_combined_short_options() {
  run_claude_agent -T leet -ns 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_contains "$output" "--new"
  # -s goes to SHLOCK_ARGS, not directly visible in claude.x args
}

test_combined_short_options_multiple() {
  run_claude_agent -T trans -nI 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_contains "$output" "--new"
  assert_contains "$output" "--setting-sources"
}

# ============================================================================
# Tests: Double-Dash Separator
# ============================================================================

test_double_dash_passes_remaining() {
  run_claude_agent -T leet -- -p "test prompt" 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_contains "$output" "-p"
  assert_contains "$output" "test prompt"
}

test_unknown_options_passed_through() {
  run_claude_agent -T leet --unknown-flag 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_contains "$output" "--unknown-flag"
}

# ============================================================================
# Tests: Positional Arguments
# ============================================================================

test_positional_args_passed_through() {
  run_claude_agent -T leet "some message" 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_contains "$output" "some message"
}

# ============================================================================
# Run Tests
# ============================================================================

main() {
  setup_test_env
  trap teardown_test_env EXIT

  begin_test_suite "Argument Parsing Tests"

  # Help and version
  run_test "help_flag_long" test_help_flag
  run_test "help_flag_short" test_help_short_flag
  run_test "version_flag_long" test_version_flag
  run_test "version_flag_short" test_version_short_flag

  # Agent specification
  run_test "agent_flag_long" test_agent_flag_long
  run_test "agent_flag_short" test_agent_flag_short
  run_test "agent_flag_requires_argument" test_agent_flag_requires_argument
  run_test "no_agent_shows_help" test_no_agent_shows_help

  # List agents
  run_test "list_flag_long" test_list_flag
  run_test "list_flag_short" test_list_short_flag

  # New/continue
  run_test "new_flag_long" test_new_flag_long
  run_test "new_flag_short" test_new_flag_short
  run_test "no_continue_flag" test_no_continue_flag
  run_test "continue_flag_long" test_continue_flag_long
  run_test "continue_flag_short" test_continue_flag_short

  # Isolation
  run_test "isolated_flag_long" test_isolated_flag_long
  run_test "isolated_flag_short" test_isolated_flag_short
  run_test "no_isolated_flag" test_no_isolated_flag

  # Max tokens
  run_test "maxtokens_flag_long" test_maxtokens_flag_long
  run_test "maxtokens_flag_short" test_maxtokens_flag_short

  # Combined options
  run_test "combined_short_options" test_combined_short_options
  run_test "combined_short_options_multiple" test_combined_short_options_multiple

  # Passthrough
  run_test "double_dash_passes_remaining" test_double_dash_passes_remaining
  run_test "unknown_options_passed_through" test_unknown_options_passed_through
  run_test "positional_args_passed_through" test_positional_args_passed_through

  end_test_suite
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
  print_test_summary
fi
#fin
