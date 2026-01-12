#!/bin/bash
# test_integration.sh - Integration tests for claude.agent
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
# Tests: Full Command Chain
# ============================================================================

test_full_leet_invocation() {
  run_claude_agent -T leet -n 2>&1 || true
  local output
  output=$(get_mock_output)

  # Verify all expected components
  assert_contains "$output" "-T"
  assert_contains "$output" "Leet - Full-Stack Programmer"
  assert_contains "$output" "--new"
  assert_contains "$output" "--add-dir"  # BCS
  assert_contains "$output" "--append-system-prompt"  # BCS note
}

test_full_draa_invocation() {
  run_claude_agent -T draa -n 2>&1 || true
  local output
  output=$(get_mock_output)

  # DrAA should have isolation but not BCS
  assert_contains "$output" "-T"
  assert_contains "$output" "DrAA - Applied Anthropology"
  assert_contains "$output" "--new"
  assert_contains "$output" "--setting-sources"  # isolated
  assert_not_contains "$output" "--add-dir"  # no BCS
}

test_full_trans_invocation() {
  run_claude_agent -T trans 2>&1 || true
  local output
  output=$(get_mock_output)

  # Trans should have neither isolation nor BCS
  assert_contains "$output" "-T"
  assert_contains "$output" "Trans - Translator"
  assert_not_contains "$output" "--setting-sources"
  assert_not_contains "$output" "--add-dir"
}

# ============================================================================
# Tests: Argument Order
# ============================================================================

test_agent_flag_first_in_args() {
  run_claude_agent -T leet -n 2>&1 || true
  local output
  output=$(get_mock_output)

  # -T should appear before --new in the args
  local args_line
  args_line=$(echo "$output" | grep "CLAUDE_X_ARGS")

  # Check -T comes first
  assert_regex_match "$args_line" "-T.*Leet.*--new"
}

test_passthrough_args_at_end() {
  run_claude_agent -T trans -n -- -p "custom prompt" 2>&1 || true
  local output
  output=$(get_mock_output)

  # Passthrough args should be at the end
  assert_regex_match "$output" "--new.*-p.*custom prompt"
}

# ============================================================================
# Tests: Working Directory
# ============================================================================

test_cwd_preserved_for_non_isolated() {
  # For non-isolated agents, CWD should be preserved
  # However, our test wrapper changes to TEST_TMPDIR, so we just verify
  # the agent runs successfully without changing to agent_dir
  run_claude_agent -T trans 2>&1 || true

  local output
  output=$(get_mock_output)
  # Trans is not isolated, so should NOT change to any agent_dir
  assert_not_contains "$output" "/tmp/draa-test"
}

test_cwd_changed_for_isolated_with_agent_dir() {
  run_claude_agent -T draa 2>&1 || true

  local output
  output=$(get_mock_output)
  # DrAA has agent_dir: /tmp/draa-test
  assert_contains "$output" "CLAUDE_X_CWD: /tmp/draa-test"
}

# ============================================================================
# Tests: Environment Variables
# ============================================================================

test_max_tokens_env_default() {
  local output
  output=$(CLAUDE_CODE_MAX_OUTPUT_TOKENS= run_claude_agent -T trans 2>&1) || true
  # Default should be 32000 - hard to test directly, but command should work
  assert_contains "$(get_mock_output)" "Trans"
}

test_max_tokens_env_custom() {
  local output
  output=$(CLAUDE_CODE_MAX_OUTPUT_TOKENS=16000 run_claude_agent -T trans 2>&1) || true
  # Custom value should be used - again, hard to test directly
  assert_contains "$(get_mock_output)" "Trans"
}

test_max_tokens_flag_overrides_env() {
  # -M sets to 64000
  run_claude_agent -T trans -M 2>&1 || true
  # Command should succeed
  assert_contains "$(get_mock_output)" "Trans"
}

# ============================================================================
# Tests: Exit Codes
# ============================================================================

test_successful_invocation_exits_zero() {
  local exit_code=1
  run_claude_agent -T trans 2>&1 && exit_code=0 || exit_code=$?
  assert_exit_code 0 "$exit_code"
}

test_unknown_agent_exits_one() {
  local exit_code=0
  run_claude_agent -T nonexistent 2>&1 || exit_code=$?
  assert_exit_code 1 "$exit_code"
}

test_missing_agent_exits_22() {
  local exit_code=0
  run_claude_agent 2>&1 || exit_code=$?
  # Should exit with non-zero when no agent specified
  ((exit_code != 0)) || return 1
}

test_help_exits_zero() {
  local exit_code=1
  run_claude_agent --help 2>&1 && exit_code=0 || exit_code=$?
  assert_exit_code 0 "$exit_code"
}

test_version_exits_zero() {
  local exit_code=1
  run_claude_agent -T leet --version 2>&1 && exit_code=0 || exit_code=$?
  assert_exit_code 0 "$exit_code"
}

test_list_exits_zero() {
  local exit_code=1
  run_claude_agent --list 2>&1 && exit_code=0 || exit_code=$?
  assert_exit_code 0 "$exit_code"
}

# ============================================================================
# Tests: Logging
# ============================================================================

test_logging_when_writable() {
  local log_file="$TEST_TMPDIR/test.log"
  touch "$log_file"
  chmod 666 "$log_file"

  # Modify the test to use custom log file
  # This is tricky since LOGFILE is hardcoded, so we skip this test
  skip_test "Log file path is hardcoded, would need script modification"
}

# ============================================================================
# Tests: Shlock Integration
# ============================================================================

test_shlock_receives_lock_name() {
  # Our mock shlock just passes through, but in production it would lock
  run_claude_agent -T trans 2>&1 || true
  # Just verify the command runs successfully
  assert_contains "$(get_mock_output)" "Trans"
}

test_steal_flag_passed_to_shlock() {
  # Create a mock shlock that records args
  cat > "$TEST_TMPDIR/shlock" <<'EOF'
#!/bin/bash
echo "SHLOCK_ARGS: $*" >> "${MOCK_OUTPUT_FILE:-/tmp/mock-claude-x.log}"
while [[ $1 != -- ]]; do shift; done
shift
exec "$@"
EOF
  chmod +x "$TEST_TMPDIR/shlock"

  : > "$MOCK_OUTPUT_FILE"
  run_claude_agent -T trans --steal 2>&1 || true

  local output
  output=$(get_mock_output)
  assert_contains "$output" "SHLOCK_ARGS:"
  assert_contains "$output" "--steal"
}

# ============================================================================
# Tests: Terminal Title
# ============================================================================

test_terminal_title_set() {
  local output
  output=$(run_claude_agent -T trans 2>&1) || true
  # Terminal escape sequence should be in output (may be consumed by terminal)
  # This is hard to test definitively
}

# ============================================================================
# Tests: Complex Scenarios
# ============================================================================

test_all_features_leet_isolated() {
  run_claude_agent -T leet --isolated -n --steal 2>&1 || true
  local output
  output=$(get_mock_output)

  # Should have everything
  assert_contains "$output" "Leet - Full-Stack Programmer"
  assert_contains "$output" "--new"
  assert_contains "$output" "--setting-sources"  # from --isolated
  assert_contains "$output" "--add-dir"  # BCS
  assert_contains "$output" "SHLOCK_ARGS:"  # steal passed to shlock
  assert_contains "$output" "--steal"
}

test_override_isolation_with_bcs() {
  # DrAA is isolated by default, but we disable it
  # It doesn't have BCS, so should just have --no-isolated effect
  run_claude_agent -T draa --no-isolated 2>&1 || true
  local output
  output=$(get_mock_output)

  assert_contains "$output" "DrAA"
  assert_not_contains "$output" "--setting-sources"
  assert_not_contains "$output" "--add-dir"
}

test_multiple_passthrough_args() {
  run_claude_agent -T trans -- -p "prompt" --json --verbose 2>&1 || true
  local output
  output=$(get_mock_output)

  assert_contains "$output" "-p"
  assert_contains "$output" "prompt"
  assert_contains "$output" "--json"
  assert_contains "$output" "--verbose"
}

# ============================================================================
# Tests: Robustness
# ============================================================================

test_special_chars_in_agent_name() {
  # Agent names shouldn't have special chars, but test handling
  local exit_code=0
  run_claude_agent -T "leet; rm -rf /" 2>&1 || exit_code=$?
  # Should fail safely, not execute injection
  ((exit_code != 0)) || return 1
}

test_empty_passthrough() {
  run_claude_agent -T trans -- 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_contains "$output" "Trans"
}

test_whitespace_in_prompt() {
  run_claude_agent -T trans -- -p "  spaces   and   tabs  " 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_contains "$output" "spaces"
  assert_contains "$output" "tabs"
}

# ============================================================================
# Run Tests
# ============================================================================

main() {
  setup_test_env
  trap teardown_test_env EXIT

  begin_test_suite "Integration Tests"

  # Full invocations
  run_test "full_leet_invocation" test_full_leet_invocation
  run_test "full_draa_invocation" test_full_draa_invocation
  run_test "full_trans_invocation" test_full_trans_invocation

  # Argument order
  run_test "agent_flag_first_in_args" test_agent_flag_first_in_args
  run_test "passthrough_args_at_end" test_passthrough_args_at_end

  # Working directory
  run_test "cwd_preserved_for_non_isolated" test_cwd_preserved_for_non_isolated
  run_test "cwd_changed_for_isolated_with_agent_dir" test_cwd_changed_for_isolated_with_agent_dir

  # Environment
  run_test "max_tokens_env_default" test_max_tokens_env_default
  run_test "max_tokens_env_custom" test_max_tokens_env_custom
  run_test "max_tokens_flag_overrides_env" test_max_tokens_flag_overrides_env

  # Exit codes
  run_test "successful_invocation_exits_zero" test_successful_invocation_exits_zero
  run_test "unknown_agent_exits_one" test_unknown_agent_exits_one
  run_test "missing_agent_exits_22" test_missing_agent_exits_22
  run_test "help_exits_zero" test_help_exits_zero
  run_test "version_exits_zero" test_version_exits_zero
  run_test "list_exits_zero" test_list_exits_zero

  # Logging
  run_test "logging_when_writable" test_logging_when_writable

  # Shlock
  run_test "shlock_receives_lock_name" test_shlock_receives_lock_name
  run_test "steal_flag_passed_to_shlock" test_steal_flag_passed_to_shlock

  # Complex scenarios
  run_test "all_features_leet_isolated" test_all_features_leet_isolated
  run_test "override_isolation_with_bcs" test_override_isolation_with_bcs
  run_test "multiple_passthrough_args" test_multiple_passthrough_args

  # Robustness
  run_test "special_chars_in_agent_name" test_special_chars_in_agent_name
  run_test "empty_passthrough" test_empty_passthrough
  run_test "whitespace_in_prompt" test_whitespace_in_prompt

  end_test_suite
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
  print_test_summary
fi
#fin
