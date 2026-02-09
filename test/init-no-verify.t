#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

# Create a directory to init as subrepo
{
  (
    cd "$OWNER/foo"
    mkdir -p testdir
    echo "test content" > testdir/testfile
    git add testdir/testfile
    git commit -m "Add testdir"
  ) &> /dev/null || die
}

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

# Test that init without --verify succeeds (hooks bypassed by default)
{
  init_status=0
  init_output=$(
    cd "$OWNER/foo"
    git subrepo init testdir 2>&1
  ) || init_status=$?

  is "$init_status" "0" \
    'subrepo init succeeds by default (hooks bypassed)'

  unlike "$init_output" "Pre-commit hook triggered" \
    'pre-commit hook was bypassed by default'

  like "$init_output" "Subrepo created from 'testdir'" \
    'init output is correct'
}

# Test that the .gitrepo file was created
{
  test-exists "$OWNER/foo/testdir/.gitrepo"
}

# Clean up for next test
{
  (
    cd "$OWNER/foo"
    git reset --hard HEAD~1
    rm -f testdir/.gitrepo
  ) &> /dev/null || true
}

# Test that init with --verify runs the hook and fails
{
  init_status=0
  init_output=$(
    cd "$OWNER/foo"
    git subrepo init --verify testdir 2>&1
  ) || init_status=$?

  isnt "$init_status" "0" \
    'subrepo init with --verify fails when pre-commit hook fails'

  like "$init_output" "Pre-commit hook triggered and failing" \
    'pre-commit hook was triggered with --verify'
}

done_testing

teardown
