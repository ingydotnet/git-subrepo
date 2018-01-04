#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

(
  cd $OWNER/foo
  git subrepo --quiet clone ../../../$UPSTREAM/bar
)

test-exists \
  "$OWNER/foo/bar/bard/"

# Test foo/bar/.gitrepo file contents:
gitrepo=$OWNER/foo/bar/.gitrepo
{
  foo_clone_commit="$(cd $OWNER/foo; git rev-parse HEAD^)"
  bar_head_commit="$(cd $OWNER/bar; git rev-parse HEAD)"
  test-gitrepo-comment-block
  test-gitrepo-field "remote" "../../../$UPSTREAM/bar"
  test-gitrepo-field "branch" "master"
  test-gitrepo-field "commit" "$bar_head_commit"
  test-gitrepo-field "merged" ""
  test-gitrepo-field "parent" "$foo_clone_commit"
  test-gitrepo-field "cmdver" "`git subrepo --version`"
}

is "$(
  cd $OWNER/foo
  git subrepo --force clone ../../../$UPSTREAM/bar
)" \
  "Subrepo 'bar' is up to date." \
  "No reclone if same commit"

(
  cd $OWNER/foo
  git subrepo --quiet clone --force ../../../$UPSTREAM/bar --branch=refs/tags/A
)

test-exists \
  "!$OWNER/foo/bar/bard/"

{
  foo_clone_commit="$(cd $OWNER/foo; git rev-parse HEAD^)"
  bar_ref_a_commit="$(cd $OWNER/bar; git rev-parse refs/tags/A)"
  test-gitrepo-comment-block
  test-gitrepo-field "remote" "../../../$UPSTREAM/bar"
  test-gitrepo-field "branch" "refs/tags/A"
  test-gitrepo-field "commit" "$bar_ref_a_commit"
  test-gitrepo-field "merged" ""
  test-gitrepo-field "parent" "$foo_clone_commit"
  test-gitrepo-field "cmdver" "`git subrepo --version`"
}

(
  cd $OWNER/foo
  git subrepo --quiet clone --force ../../../$UPSTREAM/bar --branch=master
)

test-exists \
  "$OWNER/foo/bar/bard/"

{
  foo_clone_commit="$(cd $OWNER/foo; git rev-parse HEAD^)"
  bar_head_commit="$(cd $OWNER/bar; git rev-parse HEAD)"
  test-gitrepo-comment-block
  test-gitrepo-field "remote" "../../../$UPSTREAM/bar"
  test-gitrepo-field "branch" "master"
  test-gitrepo-field "commit" "$bar_head_commit"
  test-gitrepo-field "merged" ""
  test-gitrepo-field "parent" "$foo_clone_commit"
  test-gitrepo-field "cmdver" "`git subrepo --version`"
}

done_testing

teardown
