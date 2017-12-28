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
  git subrepo branch bar
) &> /dev/null || die


# There is already a worktree branch
{
  cd $OWNER/foo
  is "$(
    catch git subrepo pull bar
  )" \
    "git-subrepo: There is already a worktree with branch subrepo/bar.
Use the --clean flag to override this check or perform a subrepo clean
to remove the worktree." \
    "subrepo pull should fail due to already existing worktree"
}

# But using clean should make it work
{
  is "$(
    catch git subrepo pull bar --clean
  )" \
    "Subrepo 'bar' pulled from '../../../tmp/upstream/bar' (master)." \
    'subrepo pull works with --clean'
}

done_testing # 9

teardown
