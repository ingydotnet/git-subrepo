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

# Clone without verify - should succeed (default)
{
  clone_status=0
  clone_output=$(
    cd "$OWNER/foo"
    git subrepo clone "$UPSTREAM/bar" 2>&1
  ) || clone_status=$?

  is "$clone_status" "0" \
    'subrepo clone succeeds by default (hooks bypassed)'

  test-exists "$OWNER/foo/bar/.gitrepo"
}

# Test that verify config can be set in .gitrepo
{
  (
    cd "$OWNER/foo"
    git config --file="bar/.gitrepo" subrepo.verify true
  ) &> /dev/null || true

  verify_value=$(
    cd "$OWNER/foo"
    git config --file="bar/.gitrepo" subrepo.verify
  )

  is "$verify_value" "true" \
    'verify=true can be set in .gitrepo config'
}

# Test that verify config set to false works
{
  (
    cd "$OWNER/foo"
    git config --file="bar/.gitrepo" subrepo.verify false
  ) &> /dev/null || true

  verify_value=$(
    cd "$OWNER/foo"
    git config --file="bar/.gitrepo" subrepo.verify
  )

  is "$verify_value" "false" \
    'verify=false can be set in .gitrepo config'
}

done_testing

teardown
