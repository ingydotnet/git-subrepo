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
  add-new-files bar/Foo2
  git push
  git subrepo pull bar
) &> /dev/null || die

(
  cd $OWNER/bar
  add-new-files Bar3
  git push
) &> /dev/null || die

(
  cd $OWNER/foo
  git subrepo pull bar
) &> /dev/null || die

test-exists \
  "$OWNER/foo/bar/Bar2" \
  "$OWNER/foo/bar/Bar3" \
  "$OWNER/foo/bar/Foo2" \

done_testing

teardown
