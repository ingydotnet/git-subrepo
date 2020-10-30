#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

subrepo-clone-bar-into-foo

(
  cd "$OWNER/bar"
  add-new-files Bar2
  git push
) &> /dev/null || die


# Do the pull and check output, use -m:
{
  is "$(
    cd "$OWNER/foo"
    git subrepo pull -m 'Hello World' bar
  )" \
    "Subrepo 'bar' pulled from '$UPSTREAM/bar' (master)." \
    'subrepo pull command output is correct'
}

# Check -m commit messages
{
  foo_new_commit_message=$(cd "$OWNER/foo"; git log --format=%B -n 1)
  like "$foo_new_commit_message" \
      "Hello World" \
      "subrepo pull commit message"
}

(
  cd "$OWNER/bar"
  add-new-files Bar3
  git push
) &> /dev/null || die

# Do the pull and check output, use -e:
{
  is "$(
    cd "$OWNER/foo"
    GIT_EDITOR='echo cowabunga >' git subrepo pull -e bar
  )" \
    "Subrepo 'bar' pulled from '$UPSTREAM/bar' (master)." \
    'subrepo pull command output is correct'
}

# Check -e commit messages
{
  foo_new_commit_message="$(cd "$OWNER/foo"; git log --format=%B -n 1)"
  like "$foo_new_commit_message" \
      "cowabunga" \
      "subrepo pull edit commit message"
}

(
  cd "$OWNER/bar"
  add-new-files Bar4
  git push
) &> /dev/null || die

# Do the pull and check output, use -e and -m:
{
  is "$(
    cd "$OWNER/foo"
    GIT_EDITOR=true git subrepo pull -e -m original bar
  )" \
    "Subrepo 'bar' pulled from '$UPSTREAM/bar' (master)." \
    'subrepo pull command output is correct'
}

# Check -e commit messages
{
  foo_new_commit_message="$(cd "$OWNER/foo"; git log --format=%B -n 1)"
  like "$foo_new_commit_message" \
      "original" \
      "subrepo pull edit and message commit message"
}

done_testing

teardown
