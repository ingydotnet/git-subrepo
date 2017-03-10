#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

subrepo-clone-bar-into-foo

(
  cd $OWNER/bar
  add-new-files Bar2
  git push
) &> /dev/null || die


# Do the pull and check output:
{
  is "$(
    cd $OWNER/foo
    git subrepo pull bar
  )" \
    "Subrepo 'bar' pulled from '../../../tmp/upstream/bar' (master)." \
    'subrepo pull command output is correct'
}

# Test subrepo file content:
gitrepo=$OWNER/foo/bar/.gitrepo
{
  test-exists \
    "$OWNER/foo/bar/Bar2" \
    "$gitrepo"
}

# Test foo/bar/.gitrepo file contents:
{
  foo_pull_commit="$(cd $OWNER/foo; git rev-parse HEAD^)"
  bar_head_commit="$(cd $OWNER/bar; git rev-parse HEAD)"
  test-gitrepo-comment-block
  test-gitrepo-field "remote" "../../../$UPSTREAM/bar"
  test-gitrepo-field "branch" "master"
  test-gitrepo-field "commit" "$bar_head_commit"
  test-gitrepo-field "parent" "$foo_pull_commit"
  test-gitrepo-field "cmdver" "`git subrepo --version`"
}

# Check commit messages
{
  foo_new_commit_message="$(cd $OWNER/foo; git log --format=%B -n 1)"
  like "$foo_new_commit_message" \
      "git subrepo pull bar" \
      "Subrepo pull commit message OK"
  bar_commit_short="$(git rev-parse --short $bar_head_commit)"
  like "$foo_new_commit_message" \
      'merged:   \"'$bar_commit_short \
      "Pull commit contains merged"
}

# Check that we detect that we don't need to pull
{
  is "$(
    cd $OWNER/foo
    git subrepo pull bar 
  )" \
    "Subrepo 'bar' is up to date." \
    'subrepo detects that we dont need to pull'
}

# Test pull if we have rebased the original subrepo so that our clone
# commit is no longer present in the history
(
  cd $OWNER/bar
  git reset --hard master^^
  add-new-files Bar3
  git push --force
) &> /dev/null || die

{
  test-exists \
    !"$OWNER/foo/pull_failed"
}

(
  cd $OWNER/foo
  git subrepo pull bar || touch pull_failed
) &> /dev/null || die

# We check that the control file was created
{
  test-exists \
    "$OWNER/foo/pull_failed"
}

done_testing # 9

teardown
