#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

subrepo-clone-bar-into-foo

is "$(
  cd $OWNER/foo
  git subrepo checkout bar
)" \
  "Switched to branch 'subrepo/bar'" \
  "subrepo checkout command output is correct"

done_testing

teardown
