#!/bin/bash

source test/setup

use Test::More

source lib/git-subrepo

(
  git clone $UPSTREAM/foo $OWNER/foo
  git clone $UPSTREAM/bar $OWNER/bar
) &> /dev/null || die

(
  cd $OWNER/foo
  git subrepo clone ../../../$UPSTREAM/bar
) &> /dev/null || die

(
  cd $OWNER/bar
  touch Bar2
  git add Bar2
  git commit -m Bar2
  git push
) &> /dev/null || die

(
  cd $OWNER/foo
  git subrepo pull bar
) &> /dev/null || die

ok "`[ -f $OWNER/foo/bar/Bar2 ]`" \
  "git subrepo pull works"

done_testing 1

source test/teardown
