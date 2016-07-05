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


# Do the pull and check output, use -m:
{
  is "$(
    cd $OWNER/foo
    git subrepo pull -m 'Hello World' bar
  )" \
    "Subrepo 'bar' pulled from '../../../tmp/upstream/bar' (master)." \
    'subrepo pull command output is correct'
}

# Check commit messages
{
  foo_new_commit_message="$(cd $OWNER/foo; git log --format=%B -n 1)"
  like "$foo_new_commit_message" \
      "Hello World" \
      "subrepo pull commit message OK"
}

(
  cd $OWNER/bar
  add-new-files Bar3
  git push
) &> /dev/null || die

# Do the pull and check output, use -e:
{
  is "$(
    cd $OWNER/foo
    GIT_EDITOR='echo cowabunga >' git subrepo pull -e bar
  )" \
    "Subrepo 'bar' pulled from '../../../tmp/upstream/bar' (master)." \
    'subrepo pull command output is correct'
}

# Check commit messages
{
  foo_new_commit_message="$(cd $OWNER/foo; git log --format=%B -n 1)"
  like "$foo_new_commit_message" \
      "cowabunga" \
      "subrepo pull edited commit message OK"
}

done_testing

teardown
