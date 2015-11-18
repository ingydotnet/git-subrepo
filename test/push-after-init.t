#!/usr/bin/env bash

set -e

source test/setup

use Test::More

git clone $UPSTREAM/init $OWNER/init &>/dev/null || die

(
  cd $OWNER/init
  git subrepo init doc || die
  mkdir ../upstream
  git init --bare ../upstream || die
)
# &> /dev/null

output="$(
  cd $OWNER/init
  git subrepo push doc --remote=../upstream --update
)"

is "$output" "Subrepo 'doc' pushed to '../upstream' (master)." \
  'Command output is correct'

# Test init/doc/.gitrepo file contents:
gitrepo=$OWNER/init/doc/.gitrepo
{
  test-gitrepo-field "remote" "../upstream"
  test-gitrepo-field "branch" "master"
}

(
  cd $OWNER
  git clone upstream up
) &>/dev/null

{
  test-exists \
    "$OWNER/up/.git/" \
    "$OWNER/up/init.swim" \
    "!$OWNER/up/.gitrepo"
}

done_testing

teardown
