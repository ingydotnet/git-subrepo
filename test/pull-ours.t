#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

subrepo-clone-bar-into-foo

note "Pull - Conflict - Use ours - Push"

#
# When you perform rebase ours/theirs are reversed, so this test case will
# test using local change (ours) although in the step below
# we actually use git checkout --theirs to accomplish this
#

(
  cd $OWNER/bar
  add-new-files Bar2
  git push
) &> /dev/null || die

(
  cd $OWNER/foo
  git subrepo pull bar
  modify-files-ex bar/Bar2
  cat bar/Bar2
  git push
) &> /dev/null || die

(
  cd $OWNER/bar
  modify-files-ex Bar2
  git push
) &> /dev/null || die

before="$(date -r $OWNER/foo/Foo '+%s')"

(
  cd $OWNER/foo
  git subrepo pull bar || {
      cd .git/tmp/subrepo/bar
      git checkout --ours Bar2
      git add Bar2
      git commit --file ../../../../.git/worktrees/bar/MERGE_MSG
      cd ../../../..
      git subrepo commit bar
      git subrepo clean bar
  }
) &> /dev/null || die

sleep 1
after="$(date -r $OWNER/foo/Foo '+%s')"

is "$before" "$after" \
  "No modification on Foo"

test-exists \
  "$OWNER/foo/bar/Bar2" \
  "$OWNER/bar/Bar2" \

is "$(cat $OWNER/foo/bar/Bar2)" \
  "new file Bar2"$'\n'"bar/Bar2" \
  "The readme file in the mainrepo is ours"

(
  cd $OWNER/foo
  git subrepo push bar
) &> /dev/null || die

(
  cd $OWNER/bar
  git pull
) &> /dev/null || die

test-exists \
  "$OWNER/foo/bar/Bar2" \
  "$OWNER/bar/Bar2" \

is "$(cat $OWNER/bar/Bar2)" \
  "new file Bar2"$'\n'"bar/Bar2" \
  "The readme file in the subrepo is ours"

done_testing

teardown
