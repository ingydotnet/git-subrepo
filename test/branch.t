#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

subrepo-clone-bar-into-foo

is "$(
  cd $OWNER/foo
  add-new-files bar/file
  git subrepo branch bar
)" \
  "Created branch 'subrepo/bar'." \
  "subrepo branch command output is correct"

# is "$(
#   cd $OWNER/foo
#   git rev-list subrepo/bar | wc -l
# )" \
#   "1" \
#   "subrepo branch has one commit"

done_testing

teardown

#### Note: 'clone' no longer makes branches and remotes. But these tests
#### should be applied to branch tests.
# remote="$(
#   cd $OWNER/foo
#   git remote -v | grep 'subrepo/bar'
#   true
# )"
# 
# ok "`[ -n "$remote" ]`" \
#   'subrepo/bar remote exists'
# 
# remote_branch="$(
#   cd $OWNER/foo
#   git branch -a | grep 'subrepo/remote/bar'
#   true
# )"
# 
# ok "`[ -n "$remote" ]`" \
#   'subrepo/remote/bar branch exists'

