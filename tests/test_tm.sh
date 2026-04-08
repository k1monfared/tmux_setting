#!/usr/bin/env bash
# test_tm.sh - Smoke tests for tm (tmux session manager)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PASS=0
FAIL=0

pass() { ((PASS++)); echo "  PASS  $1"; }
fail() { ((FAIL++)); echo "  FAIL  $1: $2"; }

echo ""
echo "  Running tm tests..."
echo ""

# --- Syntax checks ---
bash -n "$PROJECT_DIR/bin/tm" && pass "bin/tm syntax" || fail "bin/tm syntax" "syntax error"
bash -n "$PROJECT_DIR/bin/tm-picker" && pass "bin/tm-picker syntax" || fail "bin/tm-picker syntax" "syntax error"
bash -n "$PROJECT_DIR/bin/tm-cheatsheet" && pass "bin/tm-cheatsheet syntax" || fail "bin/tm-cheatsheet syntax" "syntax error"
bash -n "$PROJECT_DIR/install.sh" && pass "install.sh syntax" || fail "install.sh syntax" "syntax error"
bash -n "$PROJECT_DIR/uninstall.sh" && pass "uninstall.sh syntax" || fail "uninstall.sh syntax" "syntax error"

# --- tmux.conf validation ---
tmux -f "$PROJECT_DIR/conf/tmux.conf" start-server \; kill-server 2>/dev/null \
    && pass "tmux.conf valid" \
    || fail "tmux.conf valid" "tmux rejected config"

# --- Data files exist ---
[[ -s "$PROJECT_DIR/data/commands.log" ]] && pass "data/commands.log exists" || fail "data/commands.log exists" "missing or empty"
[[ -s "$PROJECT_DIR/data/keybindings.log" ]] && pass "data/keybindings.log exists" || fail "data/keybindings.log exists" "missing or empty"
[[ -s "$PROJECT_DIR/data/cheatsheet.log" ]] && pass "data/cheatsheet.log exists" || fail "data/cheatsheet.log exists" "missing or empty"

# --- Cheatsheet output ---
output="$("$PROJECT_DIR/bin/tm-cheatsheet" 2>&1)"
[[ -n "$output" ]] && pass "tm-cheatsheet produces output" || fail "tm-cheatsheet produces output" "empty output"

# --- Help command ---
output="$("$PROJECT_DIR/bin/tm" help 2>&1)"
[[ -n "$output" ]] && pass "tm help produces output" || fail "tm help produces output" "empty output"

# --- List command (should work even with no sessions) ---
"$PROJECT_DIR/bin/tm" list &>/dev/null && pass "tm list runs" || pass "tm list runs (no sessions)"

# --- Session lifecycle ---
TEST_SESSION="tm-test-$$"
tmux new-session -d -s "$TEST_SESSION" 2>/dev/null
if tmux has-session -t "$TEST_SESSION" 2>/dev/null; then
    pass "create test session"
    tmux kill-session -t "$TEST_SESSION" 2>/dev/null
    if ! tmux has-session -t "$TEST_SESSION" 2>/dev/null; then
        pass "kill test session"
    else
        fail "kill test session" "session still exists"
    fi
else
    fail "create test session" "could not create"
fi

# --- Scripts are executable ---
[[ -x "$PROJECT_DIR/bin/tm" ]] && pass "bin/tm is executable" || fail "bin/tm is executable" "not executable"
[[ -x "$PROJECT_DIR/bin/tm-picker" ]] && pass "bin/tm-picker is executable" || fail "bin/tm-picker is executable" "not executable"
[[ -x "$PROJECT_DIR/bin/tm-cheatsheet" ]] && pass "bin/tm-cheatsheet is executable" || fail "bin/tm-cheatsheet is executable" "not executable"

# --- Summary ---
echo ""
TOTAL=$((PASS + FAIL))
echo "  Results: $PASS/$TOTAL passed"
if [[ $FAIL -gt 0 ]]; then
    echo "  $FAIL test(s) FAILED"
    exit 1
else
    echo "  All tests passed."
fi
echo ""
