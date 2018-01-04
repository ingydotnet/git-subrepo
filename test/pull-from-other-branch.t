#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar
subrepo-clone-bar-into-foo

(
  cd $OWNER/bar
  git checkout -b other
  add-new-files Bar2
  git push --set-upstream origin other
) &> /dev/null || die

(
  cd $OWNER/bar
  git checkout master
  add-new-files Bar3
  git push
) &> /dev/null || die

(
  cd $OWNER/foo
  git subrepo pull bar
) &> /dev/null || die

# Test subrepo file content:
gitrepo=$OWNER/foo/bar/.gitrepo
{
  foo_parent=$(cd "$OWNER/foo"; git rev-parse HEAD^)
  bar_master_commit=$(cd "$OWNER/bar"; git rev-parse master)
  test-gitrepo-comment-block
  test-gitrepo-field remote "../../../$UPSTREAM/bar"
  test-gitrepo-field branch master
  test-gitrepo-field commit "$bar_master_commit"
  test-gitrepo-field merged ""
  test-gitrepo-field parent "$foo_parent"
  test-gitrepo-field cmdver "$(git subrepo --version)"
}

# Test to take changes from another branch
{
  is "$(
    cd $OWNER/foo
    catch git subrepo pull bar -b other
  )" \
    "Subrepo 'bar' pulled from '../../../tmp/upstream/bar' (other)." \
    "subrepo pull should fail due to upstream rebase"
}

# Test subrepo file content:
{
  bar_master_commit=$(cd "$OWNER/bar"; git rev-parse master)
  bar_other_commit=$(cd "$OWNER/bar"; git rev-parse other)
  test-gitrepo-comment-block
  test-gitrepo-field remote "../../../$UPSTREAM/bar"
  test-gitrepo-field branch master
  test-gitrepo-field commit "$bar_master_commit"
  test-gitrepo-field merged "$bar_other_commit"
  test-gitrepo-field parent "$foo_parent"
  test-gitrepo-field cmdver "$(git subrepo --version)"
}

(
  cd $OWNER/foo
  git subrepo push bar
) &> /dev/null || die

(
  cd $OWNER/bar
  git pull
) &> /dev/null || die

# Check that we have two parents for the latest commit
{
  like "$(
    cd $OWNER/bar
    git log --pretty=%P -n 1 HEAD
  )" \
    "[a-z0-9]{40} [a-z0-9]{40}" \
    'There is a merge commit in the subrepo'
}

done_testing # 9

teardown
