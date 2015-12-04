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
  remove-files Bar2
  git push
) &> /dev/null || die

(
  cd $OWNER/foo
  git subrepo clean bar
  git subrepo fetch bar
  git subrepo branch bar
) &> /dev/null || die

# We have reverted on bar, detect this and ignore ancestor
{
  fetch_head_commit="$(cd $OWNER/foo; git rev-parse subrepo/bar/fetch^)"
  bar_head_commit="$(cd $OWNER/foo; git rev-parse subrepo/bar)"
  is "$(
    cd $OWNER/foo
    git subrepo merge-base subrepo/bar/fetch subrepo/bar
  )" \
    "No common ancestor found between 'subrepo/bar/fetch' and 'subrepo/bar'."
}

done_testing

teardown
