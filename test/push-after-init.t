
#!/usr/bin/env bash

set -e

source test/setup

use Test::More

git clone $UPSTREAM/init $OWNER/init &>/dev/null || die

(
  cd "$OWNER/init"
  git subrepo init doc || die
  mkdir ../upstream
  git init --bare ../upstream || die
) &>/dev/null

# output="$(
  cd "$OWNER/init"
  git subrepo push doc --remote=../upstream --update
  bash -i; exit
# )"

is "$output" "Subrepo 'doc' pushed to '../upstream' (master)." \
  'Command output is correct'

# Test init/doc/.gitrepo file contents:
gitrepo=$OWNER/init/doc/.gitrepo
{
  init_clone_commit="$(cd $OWNER/init; git rev-parse HEAD^)"
  test-gitrepo-comment-block
  test-gitrepo-field "remote" "../upstream"
  test-gitrepo-field "branch" "master"
}

done_testing

teardown
