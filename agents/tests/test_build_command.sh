#!/bin/bash
# test_build_command.sh - Tests for claude-agent build_command (isolation, BCS, agent_dir)
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
# Tests: Isolation Mode from Agents.json
# ============================================================================

test_isolation_enabled_from_config() {
  # DrAA has isolated: true in Agents.json
  run_claude_agent -T draa 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_contains "$output" "--setting-sources"
}

test_isolation_disabled_by_default() {
  # Trans has no isolated field - should default to false
  run_claude_agent -T trans 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_not_contains "$output" "--setting-sources"
}

test_isolation_false_in_config() {
  # Test Agent has isolated: false
  run_claude_agent -T test 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_not_contains "$output" "--setting-sources"
}

# ============================================================================
# Tests: Isolation Flag Override
# ============================================================================

test_isolated_flag_overrides_config_false() {
  # Trans has no isolation, but -I should enable it
  run_claude_agent -T trans --isolated 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_contains "$output" "--setting-sources"
}

test_no_isolated_overrides_config_true() {
  # DrAA has isolated: true, but --no-isolated should disable
  run_claude_agent -T draa --no-isolated 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_not_contains "$output" "--setting-sources"
}

test_isolated_info_message() {
  local output
  output=$(run_claude_agent -T trans --isolated 2>&1) || true
  assert_contains "$output" "Isolation mode enabled"
}

# ============================================================================
# Tests: BCS Context
# ============================================================================

test_bcs_context_added() {
  # Leet has bcs_context: true
  run_claude_agent -T leet 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_contains "$output" "--add-dir"
  assert_contains "$output" "--append-system-prompt"
}

test_bcs_context_not_added_when_false() {
  # Trans has no bcs_context
  run_claude_agent -T trans 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_not_contains "$output" "BCS"
}

test_bcs_context_info_message() {
  local output
  output=$(run_claude_agent -T leet 2>&1) || true
  assert_contains "$output" "BCS context added"
}

test_bcs_path_in_system_prompt() {
  run_claude_agent -T leet 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_contains "$output" "BASH-CODING-STANDARD.md"
}

test_bcs_missing_command_warning() {
  # Remove bcs from path temporarily
  local output
  output=$(PATH="${TEST_TMPDIR}/no-bcs:$PATH" run_claude_agent -T leet 2>&1) || true
  # Should show warning but still work
  # Note: This test depends on bcs not being in the modified path
}

# ============================================================================
# Tests: Agent Directory Handling
# ============================================================================

test_agent_dir_change_when_isolated() {
  # DrAA has agent_dir and isolated: true
  run_claude_agent -T draa 2>&1 || true
  local output
  output=$(get_mock_output)
  # Check that CWD was changed
  assert_contains "$output" "CLAUDE_X_CWD: /tmp/draa-test"
}

test_agent_dir_not_changed_when_not_isolated() {
  # DrAA with --no-isolated should NOT change directory
  local orig_pwd=$PWD
  run_claude_agent -T draa --no-isolated 2>&1 || true
  local output
  output=$(get_mock_output)
  # CWD should be test temp dir, not agent_dir
  assert_not_contains "$output" "CLAUDE_X_CWD: /tmp/draa-test"
}

test_agent_dir_info_message() {
  local output
  output=$(run_claude_agent -T draa 2>&1) || true
  assert_contains "$output" "Changing to agent directory"
}

test_claude_dir_created() {
  # Remove .claude dir if exists
  rm -rf /tmp/draa-test/.claude 2>/dev/null || true

  run_claude_agent -T draa 2>&1 || true

  # .claude should be created (check for directory)
  if [[ -d /tmp/draa-test/.claude ]]; then
    return 0
  else
    echo "  ${RED}FAIL${NC}: Should create .claude directory"
    return 1
  fi
}

test_claude_local_md_created() {
  # Remove .claude dir if exists
  rm -rf /tmp/draa-test/.claude 2>/dev/null || true

  run_claude_agent -T draa 2>&1 || true

  # CLAUDE.local.md should be created with systemprompt
  assert_file_exists /tmp/draa-test/.claude/CLAUDE.local.md
  assert_file_contains /tmp/draa-test/.claude/CLAUDE.local.md "DrAA"
}

test_claude_local_md_not_overwritten() {
  # Create existing CLAUDE.local.md
  mkdir -p /tmp/draa-test/.claude
  echo "EXISTING CONTENT" > /tmp/draa-test/.claude/CLAUDE.local.md

  run_claude_agent -T draa 2>&1 || true

  # Should NOT be overwritten
  assert_file_contains /tmp/draa-test/.claude/CLAUDE.local.md "EXISTING CONTENT"
}

# ============================================================================
# Tests: Agent Key Passed to claude.x
# ============================================================================

test_agent_key_passed_with_T() {
  run_claude_agent -T leet 2>&1 || true
  local output
  output=$(get_mock_output)
  # Should pass -T "Leet - Full-Stack Programmer"
  assert_contains "$output" "-T"
  assert_contains "$output" "Leet - Full-Stack Programmer"
}

test_agent_key_is_full_name() {
  run_claude_agent -T dr --no-isolated 2>&1 || true
  local output
  output=$(get_mock_output)
  # Even with prefix 'dr', should pass full name
  assert_contains "$output" "DrAA - Applied Anthropology"
}

# ============================================================================
# Tests: Multiple Features Combined
# ============================================================================

test_isolation_and_bcs_combined() {
  # Leet with --isolated should have both BCS and isolation
  run_claude_agent -T leet --isolated 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_contains "$output" "--setting-sources"
  assert_contains "$output" "--add-dir"
}

test_new_and_isolation_combined() {
  run_claude_agent -T draa -n 2>&1 || true
  local output
  output=$(get_mock_output)
  assert_contains "$output" "--new"
  assert_contains "$output" "--setting-sources"
}

# ============================================================================
# Run Tests
# ============================================================================

main() {
  setup_test_env
  trap teardown_test_env EXIT

  begin_test_suite "Build Command Tests (Isolation, BCS, agent_dir)"

  # Isolation from config
  run_test "isolation_enabled_from_config" test_isolation_enabled_from_config
  run_test "isolation_disabled_by_default" test_isolation_disabled_by_default
  run_test "isolation_false_in_config" test_isolation_false_in_config

  # Isolation flag override
  run_test "isolated_flag_overrides_config_false" test_isolated_flag_overrides_config_false
  run_test "no_isolated_overrides_config_true" test_no_isolated_overrides_config_true
  run_test "isolated_info_message" test_isolated_info_message

  # BCS context
  run_test "bcs_context_added" test_bcs_context_added
  run_test "bcs_context_not_added_when_false" test_bcs_context_not_added_when_false
  run_test "bcs_context_info_message" test_bcs_context_info_message
  run_test "bcs_path_in_system_prompt" test_bcs_path_in_system_prompt

  # Agent directory
  run_test "agent_dir_change_when_isolated" test_agent_dir_change_when_isolated
  run_test "agent_dir_not_changed_when_not_isolated" test_agent_dir_not_changed_when_not_isolated
  run_test "agent_dir_info_message" test_agent_dir_info_message
  run_test "claude_dir_created" test_claude_dir_created
  run_test "claude_local_md_created" test_claude_local_md_created
  run_test "claude_local_md_not_overwritten" test_claude_local_md_not_overwritten

  # Agent key
  run_test "agent_key_passed_with_T" test_agent_key_passed_with_T
  run_test "agent_key_is_full_name" test_agent_key_is_full_name

  # Combined features
  run_test "isolation_and_bcs_combined" test_isolation_and_bcs_combined
  run_test "new_and_isolation_combined" test_new_and_isolation_combined

  end_test_suite
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
  print_test_summary
fi
#fin
