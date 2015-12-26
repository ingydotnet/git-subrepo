#!/usr/bin/env bash

set -e

source test/setup

use Test::More

git clone $UPSTREAM/init $OWNER/init &>/dev/null

gitrepo=$OWNER/init/doc/.gitrepo

# Test that the initial repo look ok:
{
  test-exists \
    "$OWNER/init/.git/" \
    "$OWNER/init/ReadMe" \
    "$OWNER/init/doc/" \
    "$OWNER/init/doc/init.swim" \
    "!$gitrepo"
}

output="$(
  cd "$OWNER/init"
  git subrepo init doc
)"

is "$output" "Subrepo created from 'doc' (with no remote)." \
  'Command output is correct'

{
  test-exists \
    "$gitrepo"
}

# Test init/doc/.gitrepo file contents:
{
  init_clone_commit="$(cd $OWNER/init; git rev-parse HEAD^)"
  test-gitrepo-comment-block
  test-gitrepo-field "remote" "none"
  test-gitrepo-field "branch" "master"
  test-gitrepo-field "parent" "$init_clone_commit"
  test-gitrepo-field "cmdver" "`git subrepo --version`"
}

rm -fr "$OWNER/init"
git clone $UPSTREAM/init $OWNER/init &>/dev/null
(
  cd "$OWNER/init"
  git subrepo init doc -r git@github.com:user/repo -b foo
) >/dev/null

test-gitrepo-field "remote" "git@github.com:user/repo"
test-gitrepo-field "branch" "foo"

done_testing

teardown
