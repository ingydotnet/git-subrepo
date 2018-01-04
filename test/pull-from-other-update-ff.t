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
  git checkout master
) &> /dev/null || die

gitrepo=$OWNER/foo/bar/.gitrepo
# Test values before pull
{
  foo_parent=$(cd "$OWNER/foo"; git rev-parse HEAD^)
  bar_master_commit=$(cd "$OWNER/bar"; git rev-parse master)
  test-gitrepo-field remote "../../../$UPSTREAM/bar"
  test-gitrepo-field branch master
  test-gitrepo-field commit "$bar_master_commit"
  test-gitrepo-field merged ""
  test-gitrepo-field parent "$foo_parent"
  test-gitrepo-field cmdver "$(git subrepo --version)"
}

# Test to take changes from another branch and update
{
  is "$(
    cd $OWNER/foo
    catch git subrepo pull bar -b other -u
  )" \
    "Subrepo 'bar' pulled from '../../../tmp/upstream/bar' (other)." \
    "subrepo pull should work as there are no conflicting changes"
}

# Test subrepo file content:
{
  foo_parent=$(cd "$OWNER/foo"; git rev-parse HEAD^)
  bar_master_commit=$(cd "$OWNER/bar"; git rev-parse master)
  bar_other_commit=$(cd "$OWNER/bar"; git rev-parse other)
  test-gitrepo-field remote "../../../$UPSTREAM/bar"
  test-gitrepo-field branch other
  test-gitrepo-field commit "$bar_other_commit"
  test-gitrepo-field merged ""
  test-gitrepo-field parent "$foo_parent"
  test-gitrepo-field cmdver "$(git subrepo --version)"
}

# No changes to push back
{
  is "$(
    cd $OWNER/foo
    catch git subrepo push bar
  )" \
    "Subrepo 'bar' has no new commits to push." \
    'subrepo push should detect no changes'
}

done_testing # 9

teardown
