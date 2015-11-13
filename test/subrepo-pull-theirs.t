#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

subrepo-clone-bar-into-foo

note "Pull - Conflict - Use theirs - Push"

#
# When you perform rebase ours/theirs are reversed, so this test case will
# test using the subrepo change (theirs) although in the step below
# we actually use git checkout --ours to accomplish this
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
  git push
) &> /dev/null || die

(
  cd $OWNER/bar
  modify-files-ex Bar2
  git push
) &> /dev/null || die

(
  cd $OWNER/foo
  git subrepo pull bar || {
      git checkout --ours Bar2
      git rebase --skip
      git checkout master
      git subrepo commit bar
      git subrepo clean bar
  }
) &> /dev/null || die

test-exists \
  "$OWNER/foo/bar/Bar2" \
  "$OWNER/bar/Bar2" \

is "$(cat $OWNER/foo/bar/Bar2)" \
  "new file Bar2"$'\n'"Bar2" \
  "The readme file in the mainrepo is theirs"

(
  cd $OWNER/foo
  cat bar/Bar2
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
  "new file Bar2"$'\n'"Bar2" \
  "The readme file in the subrepo is theirs"

done_testing

teardown
