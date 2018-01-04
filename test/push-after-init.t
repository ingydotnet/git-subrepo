#!/usr/bin/env bash

set -e

source test/setup

use Test::More

# Create directory and init git locally as this will test some corner
# cases when you don't have any previous commits to rely on
# see issue/122
(
  mkdir -p $OWNER/init
  cd $OWNER/init
  git init
  mkdir doc
  add-new-files doc/FooBar
  git subrepo init doc || die
  mkdir ../upstream
  git init --bare ../upstream || die
) &> /dev/null

# Test init/doc/.gitrepo file contents:
gitrepo=$OWNER/init/doc/.gitrepo
{
  test-gitrepo-field "remote" ""
  test-gitrepo-field "branch" ""
  test-gitrepo-field "parent" ""
  test-gitrepo-field "merged" ""
}

before_push="$(cd $OWNER/init;git rev-parse HEAD)"
output="$(
  cd $OWNER/init
  git subrepo push doc --remote=../upstream --branch=master
)"
after_push="$(cd $OWNER/init;git rev-parse HEAD)"

is "$output" "Subrepo 'doc' pushed to '../upstream' (master)." \
  'Command output is correct'
is "$before_push" "$after_push" \
  'Pushing without tracking should not create local commit'

# Test init/doc/.gitrepo file contents:
{
  test-gitrepo-field "remote" ""
  test-gitrepo-field "branch" ""
  test-gitrepo-field "parent" ""
  test-gitrepo-field "merged" ""
}

output="$(
  cd $OWNER/init
  git subrepo push doc --remote=../upstream --branch=other --update
)"

is "$output" "Subrepo 'doc' pushed to '../upstream' (other)." \
  'Command output is correct'

{
  parent_commit="$(cd $OWNER/init;git rev-parse HEAD^)"
  test-gitrepo-field "remote" "../upstream"
  test-gitrepo-field "branch" "other"
  test-gitrepo-field "parent" "$parent_commit"
  test-gitrepo-field "merged" ""
}

(
  cd $OWNER
  git clone upstream up
) &>/dev/null

{
  test-exists \
    "$OWNER/up/.git/" \
    "!$OWNER/up/.gitrepo"
}

done_testing

teardown
