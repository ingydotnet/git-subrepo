#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

(
  cd "$OWNER"/foo
  git subrepo clone "$UPSTREAM"/bar
  git subrepo clone "$UPSTREAM"/foo bar/foo
  mkdir lib
  git subrepo clone "$UPSTREAM"/bar lib/bar
  git subrepo clone "$UPSTREAM"/foo lib/bar/foo
) &> /dev/null || die

{
  output=$(
    cd "$OWNER"/foo
    git subrepo status --all
  )

  like "$output" "2 subrepos:" \
    "'status' intro ok"

  like "$output" "Git subrepo 'bar':" \
    "bar is in 'status'"

  like "$output" "Git subrepo 'lib/bar':" \
    "lib/bar is in 'status'"

  unlike "$output" "Git subrepo 'bar/foo':" \
    "bar/foo is not in 'status'"

  unlike "$output" "Git subrepo 'lib/bar/foo':" \
    "lib/bar/foo is not in 'status'"
}

{
  output=$(
    cd "$OWNER"/foo
    git subrepo status --ALL
  )

  like "$output" "4 subrepos:" \
    "'status --ALL' intro ok"

  like "$output" "Git subrepo 'bar':" \
    "bar is in 'status --ALL'"

  like "$output" "Git subrepo 'lib/bar':" \
    "lib/bar is in 'status --ALL'"

  like "$output" "Git subrepo 'bar/foo':" \
    "bar/foo is in 'status --ALL'"

  like "$output" "Git subrepo 'lib/bar/foo':" \
    "lib/bar/foo is in 'status --ALL'"
}

{
  output=$(
    cd "$OWNER"/foo
    git subrepo status --all
  )

  like "$output" "2 subrepos:" \
    "'status --all' intro ok"

  like "$output" "Git subrepo 'bar':" \
    "bar is in 'status --all'"

  like "$output" "Git subrepo 'lib/bar':" \
    "lib/bar is in 'status --all'"

  unlike "$output" "Git subrepo 'bar/foo':" \
    "bar/foo is not in 'status --all'"

  unlike "$output" "Git subrepo 'lib/bar/foo':" \
    "lib/bar/foo is not in 'status --all'"
}

done_testing 15

teardown
