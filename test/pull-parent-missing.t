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

(
  cd $OWNER/foo
  git checkout -b alpha
  add-new-files Foo1
  git subrepo pull bar
  git checkout master
  add-new-files Foo2
  git checkout alpha
  git rebase master
) &> /dev/null || die

(
  cd $OWNER/bar
  add-new-files Bar3
  git push
) &> /dev/null || die

# Parent should be missing in history and cause the pull to fail
{
  cd $OWNER/foo
  parent_commit=$(git config --file=bar/.gitrepo subrepo.parent)
  is "$(
    git subrepo pull bar
  )" \
    "Parent: $parent_commit is not part of current history
You can use --squash ignore the subrepo.parent from .gitrepo" \
    'subrepo pull should fail due to missing parent'
}

# But using squash should make it work
{
  is "$(
    git subrepo pull bar --squash
  )" \
    "Subrepo 'bar' pulled from '../../../tmp/upstream/bar' (master)." \
    'subrepo pull works with --squash'
}

done_testing # 9

teardown
