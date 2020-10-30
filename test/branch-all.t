#!/usr/bin/env bash

set -e

source test/setup

use Test::More

note "Test commands work using --all flag"

clone-foo-and-bar

(
  cd "$OWNER/foo"
  git subrepo clone --quiet "$UPSTREAM/bar" one
  git subrepo clone --quiet "$UPSTREAM/bar" two
  add-new-files two/file
)

ok "$(
  cd "$OWNER/foo"
  git subrepo branch --all &> /dev/null
)" "branch command works with --all even when a subrepo has no new commits"

ok "$(
  cd "$OWNER/foo"
  git:branch-exists subrepo/two
)" "The 'subrepo/two' branch exists"

test-exists "$OWNER/foo/.git/tmp/subrepo/two/"

ok "$(
  cd "$OWNER/foo"
  git:branch-exists subrepo/one
)" "The 'subrepo/one' branch exists"

test-exists "$OWNER/foo/.git/tmp/subrepo/one/"

done_testing

teardown
