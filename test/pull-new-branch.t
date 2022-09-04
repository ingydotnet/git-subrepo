#!/usr/bin/env bash

source test/setup

use Test::More

clone-foo-and-bar

subrepo-clone-bar-into-foo

(
  cd "$OWNER/bar"
  git checkout -b branch1
  git push --set-upstream origin branch1
) &> /dev/null || die

# Test subrepo file content:
# shellcheck disable=2034
gitrepo=$OWNER/foo/bar/.gitrepo

{
  foo_pull_commit=$(cd "$OWNER/foo" || exit; git rev-parse HEAD^)
  bar_head_commit=$(cd "$OWNER/bar" || exit; git rev-parse HEAD)
  test-gitrepo-comment-block
  test-gitrepo-field remote "$UPSTREAM/bar"
  test-gitrepo-field branch master
  test-gitrepo-field commit "$bar_head_commit"
  test-gitrepo-field parent "$foo_pull_commit"
  test-gitrepo-field cmdver "$(git subrepo --version)"
}

# pull without update - keep the previous branch and remote in .gitrepo

(
  cd "$OWNER/foo"
  git subrepo pull bar -b branch1
) &> /dev/null || die

{
  foo_pull_commit=$(cd "$OWNER/foo" || exit; git rev-parse HEAD^)
  bar_head_commit=$(cd "$OWNER/bar" || exit; git rev-parse HEAD)
  test-gitrepo-comment-block
  test-gitrepo-field remote "$UPSTREAM/bar"
  test-gitrepo-field branch master
  test-gitrepo-field commit "$bar_head_commit"
  test-gitrepo-field parent "$foo_pull_commit"
  test-gitrepo-field cmdver "$(git subrepo --version)"
}

# pull with update - use new branch and remote

(
  cd "$OWNER/foo"
  git subrepo pull bar -b branch1 -r "$UPSTREAM/bar/./" -u
) &> /dev/null || die

{
  foo_pull_commit=$(cd "$OWNER/foo" || exit; git rev-parse HEAD^)
  bar_head_commit=$(cd "$OWNER/bar" || exit; git rev-parse HEAD)
  test-gitrepo-comment-block
  test-gitrepo-field remote "$UPSTREAM/bar/./"
  test-gitrepo-field branch branch1
  test-gitrepo-field commit "$bar_head_commit"
  test-gitrepo-field parent "$foo_pull_commit"
  test-gitrepo-field cmdver "$(git subrepo --version)"
}

{
  is "$(
    cd "$OWNER/foo" || exit
    git subrepo pull bar
  )" \
    "Subrepo 'bar' is up to date." \
    'subrepo detects that we dont need to pull'
}

done_testing

teardown
