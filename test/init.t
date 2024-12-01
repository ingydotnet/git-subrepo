#!/usr/bin/env bash

set -e

source test/setup

use Test::More

git clone "$UPSTREAM/init" "$OWNER/init" &>/dev/null

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

output=$(
  cd "$OWNER/init"
  git config user.email "ini@ini"
  git config user.name "IniUser"
  git config init.defaultBranch "${DEFAULTBRANCH}"
  git subrepo init doc
)

is "$output" "Subrepo created from 'doc' (with no remote)." \
  'Command output is correct'

{
  test-exists \
    "$gitrepo"
}

# Test init/doc/.gitrepo file contents:
{
  test-gitrepo-comment-block
  test-gitrepo-field "remote" "none"
  test-gitrepo-field "branch" "master"
  test-gitrepo-field "commit" ""
  test-gitrepo-field "parent" ""
  test-gitrepo-field "method" "merge"
  test-gitrepo-field "cmdver" "$(git subrepo --version)"
}

rm -fr "$OWNER/init"
git clone "$UPSTREAM/init" "$OWNER/init" &>/dev/null
(
  cd "$OWNER/init"
  git config user.email "ini@ini"
  git config user.name "IniUser"
  git config init.defaultBranch "${DEFAULTBRANCH}"
  git subrepo init doc -r git@github.com:user/repo -b foo -M rebase
) >/dev/null

test-gitrepo-field "remote" "git@github.com:user/repo"
test-gitrepo-field "branch" "foo"
test-gitrepo-field "commit" ""
test-gitrepo-field "parent" ""
test-gitrepo-field "method" "rebase"
test-gitrepo-field "cmdver" "$(git subrepo --version)"

done_testing

teardown
