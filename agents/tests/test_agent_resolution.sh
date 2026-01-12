#!/bin/bash
# test_agent_resolution.sh - Tests for claude.agent agent resolution
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
# Tests: Case-Insensitive Prefix Matching
# ============================================================================

test_lowercase_match() {
  run_claude_agent -T leet 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_contains "$output" "Leet - Full-Stack Programmer"
}

test_uppercase_match() {
  run_claude_agent -T LEET 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_contains "$output" "Leet - Full-Stack Programmer"
}

test_mixedcase_match() {
  run_claude_agent -T LeEt 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_contains "$output" "Leet - Full-Stack Programmer"
}

test_prefix_match() {
  run_claude_agent -T le 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_contains "$output" "Leet - Full-Stack Programmer"
}

test_draa_resolution() {
  run_claude_agent -T draa --no-isolated 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_contains "$output" "DrAA - Applied Anthropology"
}

test_trans_resolution() {
  run_claude_agent -T trans 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_contains "$output" "Trans - Translator"
}

test_test_agent_resolution() {
  run_claude_agent -T test 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_contains "$output" "Test Agent - No BCS"
}

# ============================================================================
# Tests: Error Cases
# ============================================================================

test_unknown_agent_fails() {
  local exit_code=0
  run_claude_agent -T nonexistent 2>&1 || exit_code=$?
  assert_exit_code 1 "$exit_code" "Should exit with code 1 for unknown agent"
}

test_unknown_agent_error_message() {
  local exit_code=0
  run_claude_agent -T nonexistent 2>&1 || exit_code=$?
  # Should fail with non-zero exit
  ((exit_code != 0)) || return 1
}

test_empty_agent_name() {
  local exit_code=0
  run_claude_agent -T "" 2>&1 || exit_code=$?
  # Empty string should fail to match
  ((exit_code != 0)) || return 1
}

# ============================================================================
# Tests: Symlink Detection
# ============================================================================

test_symlink_detection() {
  # This test verifies symlink detection works
  # When invoked via symlink named 'leet', it should auto-detect agent
  # Skip for now as it requires more complex setup
  skip_test "Symlink detection requires full environment setup"
}

test_direct_invocation_requires_agent() {
  # When called as 'claude.agent', should require -T flag
  local exit_code=0
  run_claude_agent 2>&1 || exit_code=$?
  # Should exit with error when no agent specified
  ((exit_code != 0)) || return 1
}

# ============================================================================
# Tests: Agent Info Display
# ============================================================================

test_agent_info_displayed() {
  local output
  output=$(run_claude_agent -v -T leet 2>&1) || true
  # Check stderr for info message (requires -v for verbose output)
  assert_contains "$output" "Agent:"
}

# ============================================================================
# Tests: First Match Wins
# ============================================================================

test_first_match_wins() {
  # 'l' should match 'Leet' not 'le' or anything else
  run_claude_agent -T l 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_contains "$output" "Leet"
}

test_d_matches_draa() {
  run_claude_agent -T d --no-isolated 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_contains "$output" "DrAA"
}

test_t_matches_first_t() {
  # Both Trans and Test start with T, first alphabetically should win
  run_claude_agent -T t 2>&1 || true
  local output
  output=$(get_mock_output)
  # Test Agent comes before Trans alphabetically
  assert_contains "$output" "Test Agent"
}

# ============================================================================
# Run Tests
# ============================================================================

main() {
  setup_test_env
  trap teardown_test_env EXIT

  begin_test_suite "Agent Resolution Tests"

  # Case-insensitive matching
  run_test "lowercase_match" test_lowercase_match
  run_test "uppercase_match" test_uppercase_match
  run_test "mixedcase_match" test_mixedcase_match
  run_test "prefix_match" test_prefix_match

  # Specific agents
  run_test "draa_resolution" test_draa_resolution
  run_test "trans_resolution" test_trans_resolution
  run_test "test_agent_resolution" test_test_agent_resolution

  # Error cases
  run_test "unknown_agent_fails" test_unknown_agent_fails
  run_test "unknown_agent_error_message" test_unknown_agent_error_message
  run_test "empty_agent_name" test_empty_agent_name

  # Symlink detection
  run_test "symlink_detection" test_symlink_detection
  run_test "direct_invocation_requires_agent" test_direct_invocation_requires_agent

  # Info display
  run_test "agent_info_displayed" test_agent_info_displayed

  # First match
  run_test "first_match_wins" test_first_match_wins
  run_test "d_matches_draa" test_d_matches_draa
  run_test "t_matches_first_t" test_t_matches_first_t

  end_test_suite
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
  print_test_summary
fi
#fin
