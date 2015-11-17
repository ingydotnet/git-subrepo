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
  add-new-files bar/Foo1
  git subrepo push bar --force --debug
) &> /dev/null || die

(
  cd $OWNER/foo
  git subrepo pull bar
)
# &> /dev/null || die

test-exists \
  "$OWNER/foo/bar/Foo1" \
  !"$OWNER/foo/bar/Bar2" \

# Pull here will actually merge the old master with the new one
(
  set +x
  cd $OWNER/bar
  git pull
) &> /dev/null || die

test-exists \
  "$OWNER/bar/Bar2" \
  "$OWNER/bar/Foo1" \

# Test that a fresh repo is not contaminated
(
  git clone $UPSTREAM/bar $OWNER/newbar
) &> /dev/null || die

test-exists \
  "$OWNER/newbar/Foo1" \
  !"$OWNER/foo/bar/Bar2" \

done_testing

teardown
