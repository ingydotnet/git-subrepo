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
  touch bar/FooBar
  git add bar/FooBar
  git commit -m 'added FooBar'
) &> /dev/null || die

message="$(
  cd $OWNER/foo
  git subrepo push bar
)"

(
  cd $OWNER/bar
  git fetch
  git rebase -p
) &> /dev/null || die

is "$message" \
  "git subrepo 'bar' pushed to '../../../tmp/upstream/bar' (master)" \
  "push message is correct"

ok "`[ -f $OWNER/bar/FooBar ]`" \
  "subrepo push file made it upstream"

ok "`[ ! -f $OWNER/bar/.gitrepo ]`" \
  ".gitrepo file was not pushed"

done_testing 3

source test/teardown
