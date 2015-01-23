#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

(
  mkdir -p "$OWNER/empty"
  git init "$OWNER/empty"
)

# Test that the repos look ok:
{
  test-exists \
    "$OWNER/foo/.git/" \
    "$OWNER/foo/Foo" \
    "!$OWNER/foo/bar/" \
    "$OWNER/bar/.git/" \
    "$OWNER/bar/Bar" \
    "$OWNER/empty/.git/"
}

# Do the subrepo clone and test the output:
{
  clone_output="$(
    cd $OWNER/foo
    git subrepo clone ../../../$UPSTREAM/bar
  )"

  # Check output is correct:
  is "$clone_output" \
    "Subrepo '../../../tmp/upstream/bar' (master) cloned into 'bar'." \
    'subrepo clone command output is correct'

  clone_output_empty="$(
    cd $OWNER/empty
    git subrepo clone ../../../$UPSTREAM/bar
  )"

  # Check output is correct:
  is "$clone_output_empty" \
    "Subrepo '../../../tmp/upstream/bar' (master) cloned into 'bar'." \
    'subrepo clone command output is correct'
}

# Check that subrepo files look ok:
gitrepo=$OWNER/foo/bar/.gitrepo
{
  test-exists \
    "$OWNER/foo/bar/" \
    "$OWNER/foo/bar/Bar" \
    "$gitrepo" \
    "$OWNER/empty/bar/" \
    "$OWNER/empty/bar/Bar" \
    "$OWNER/empty/bar/.gitrepo"
}

# Test foo/bar/.gitrepo file contents:
{
  foo_clone_commit="$(cd $OWNER/foo; git rev-parse HEAD^)"
  bar_head_commit="$(cd $OWNER/bar; git rev-parse HEAD)"
  test-gitrepo-comment-block
  test-gitrepo-field "remote" "../../../$UPSTREAM/bar"
  test-gitrepo-field "branch" "master"
  test-gitrepo-field "commit" "$bar_head_commit"
  test-gitrepo-field "parent" "$foo_clone_commit"
  test-gitrepo-field "cmdver" "`git subrepo --version`"
}

# # Check commit messages:
# {
#   # Check head commit msg contains head id:
#   foo_merge_commit_msg="$(cd $OWNER/foo; git log --max-count=1)"
#   foo_head_commit="$(cd $OWNER/foo; git rev-parse HEAD)"
#   like "$foo_merge_commit_msg" \
#     "$foo_head_commit" \
#     'subrepo clone merge commit is head'
# 
#   # Check the subrepo clone commit message:
#   foo_clone_commit_msg="$(cd $OWNER/foo; git log --skip=1 --max-count=1)"
#   pass TODO
#   # TODO: fix like to support regex meta chars
#   # like "$foo_clone_commit_msg" \
#   #   "subrepo clone: .+ bar/" \
#   #   'Subrepo clone commit msg is ok'
# 
#   note $(git rev-parse --short $bar_head_commit)
#   like "$foo_clone_commit_msg" \
#     "commit: $(git rev-parse --short $bar_head_commit)" \
#     'Subrepo clone commit contains bar head commit'
# 
#   like "$foo_merge_commit_msg" \
#     "Merge subrepo commit" \
#     'Subrepo clone commit msg is ok'
# }

# Make sure status is clean:
{
  git_status="$(
    cd $OWNER/foo
    git status -s
  )"

  is "$git_status" \
    "" \
    'status is clean'

  git_status_empty="$(
    cd $OWNER/empty
    git status -s
  )"

  is "$git_status_empty" \
    "" \
    'status is clean'
}

done_testing 22

teardown
