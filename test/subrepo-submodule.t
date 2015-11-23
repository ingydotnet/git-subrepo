#!/usr/bin/env bash

# Test that a subrepo that contains a submodule retains the submodule reference
# so that the tree hash stays the same. (However, the subrepo's submodule won't
# be directly usable since the .gitmodules file isn't in the top level.)

set -e

source test/setup

use Test::More

clone-foo-and-bar

# Add submodule reference along with a new file to the bar repo:
(
  cd $OWNER/bar
  git clone ../foo submodule
  add-new-files file
  git add submodule file
  git commit --amend -C HEAD
) &> /dev/null || die

(
  cd $OWNER/foo
  git subrepo clone ../bar
) &> /dev/null || die

(
  cd $OWNER/bar
  modify-files file
) &> /dev/null || die

{
  is "$(
   cd $OWNER/foo
    git subrepo pull bar
  )" \
    "Subrepo 'bar' pulled from '../bar' (master)." \
    'subrepo pull command output is correct'
}

done_testing

teardown
