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

# Test that we can handle .gitrepo in .gitignore
(
  cd $OWNER/init/doc
  echo .gitrepo > .gitignore
)

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
  test-gitrepo-field "remote" ""
  test-gitrepo-field "branch" ""
  test-gitrepo-field "commit" ""
  test-gitrepo-field "merged" ""
  test-gitrepo-field "parent" ""
  test-gitrepo-field "method" "merge"
  test-gitrepo-field "update" "auto"
  test-gitrepo-field "cmdver" "`git subrepo --version`"
}

rm -fr "$OWNER/init"
git clone $UPSTREAM/init $OWNER/init &>/dev/null
(
  cd "$OWNER/init"
  git subrepo init doc -r git@github.com:user/repo -b foo -M rebase -p manual
) >/dev/null

test-gitrepo-field "remote" "git@github.com:user/repo"
test-gitrepo-field "branch" "foo"
test-gitrepo-field "commit" ""
test-gitrepo-field "merged" ""
test-gitrepo-field "parent" ""
test-gitrepo-field "method" "rebase"
test-gitrepo-field "update" "manual"
test-gitrepo-field "cmdver" "`git subrepo --version`"

done_testing

teardown
