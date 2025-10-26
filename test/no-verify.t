#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

# Create a pre-commit hook that will fail
{
  hook_file="$OWNER/foo/.git/hooks/pre-commit"
  mkdir -p "$(dirname "$hook_file")"
  cat > "$hook_file" <<'EOF'
#!/bin/bash
# This hook will always fail
echo "Pre-commit hook triggered and failing"
exit 1
EOF
  chmod +x "$hook_file"
}

# Test that clone without --verify succeeds (hooks bypassed by default)
{
  clone_status=0
  clone_output=$(
    cd "$OWNER/foo"
    git subrepo clone "$UPSTREAM/bar" 2>&1
  ) || clone_status=$?

  is "$clone_status" "0" \
    'subrepo clone succeeds by default (hooks bypassed)'

  unlike "$clone_output" "Pre-commit hook triggered" \
    'pre-commit hook was bypassed by default'

  is "$clone_output" \
    "Subrepo '$UPSTREAM/bar' (master) cloned into 'bar'." \
    'clone output is correct'
}

# Test that the subrepo was actually cloned
{
  test-exists \
    "$OWNER/foo/bar/" \
    "$OWNER/foo/bar/Bar" \
    "$OWNER/foo/bar/.gitrepo"
}

# Clean up for next test
{
  (
    cd "$OWNER/foo"
    git reset --hard HEAD~1
    rm -rf bar
  ) &> /dev/null || true
}

# Test that clone with --verify runs the hook and fails
{
  clone_status=0
  clone_output=$(
    cd "$OWNER/foo"
    git subrepo clone --verify "$UPSTREAM/bar" 2>&1
  ) || clone_status=$?

  isnt "$clone_status" "0" \
    'subrepo clone with --verify fails when pre-commit hook fails'

  like "$clone_output" "Pre-commit hook triggered and failing" \
    'pre-commit hook was triggered with --verify'
}

done_testing

teardown
