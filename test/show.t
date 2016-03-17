#!/usr/bin/env bash

set -e

source test/setup

use Test::More

{
  output="$(git subrepo show)"

  like "$output" "2 subrepos:" \
    "'show' intro ok"

  like "$output" "Git subrepo 'ext/bashplus':" \
    "ext/bashplus is in 'show'"

  like "$output" "Git subrepo 'ext/test-more-bash':" \
    "ext/test-more-bash is in 'show'"

  unlike "$output" "Git subrepo 'ext/test-more-bash/ext/bashplus':" \
    "ext/test-more-bash/ext/bashplus is not in 'show'"

  unlike "$output" "Git subrepo 'ext/test-more-bash/ext/test-tap-bash':" \
    "ext/test-more-bash/ext/test-tap-bash is not in 'show'"
}

{
  output="$(git subrepo show --ALL)"

  like "$output" "4 subrepos:" \
    "'show --ALL' intro ok"

  like "$output" "Git subrepo 'ext/bashplus':" \
    "ext/bashplus is in 'show --ALL'"

  like "$output" "Git subrepo 'ext/test-more-bash':" \
    "ext/test-more-bash is in 'show --ALL'"

  like "$output" "Git subrepo 'ext/test-more-bash/ext/bashplus':" \
    "ext/test-more-bash/ext/bashplus is in 'show --ALL'"

  like "$output" "Git subrepo 'ext/test-more-bash/ext/test-tap-bash':" \
    "ext/test-more-bash/ext/test-tap-bash is in 'show --ALL'"
}

{
  output="$(git subrepo show --all)"

  like "$output" "2 subrepos:" \
    "'show --all' intro ok"

  like "$output" "Git subrepo 'ext/bashplus':" \
    "ext/bashplus is in 'show --all'"

  like "$output" "Git subrepo 'ext/test-more-bash':" \
    "ext/test-more-bash is in 'show --all'"

  unlike "$output" "Git subrepo 'ext/test-more-bash/ext/bashplus':" \
    "ext/test-more-bash/ext/bashplus is not in 'show --all'"

  unlike "$output" "Git subrepo 'ext/test-more-bash/ext/test-tap-bash':" \
    "ext/test-more-bash/ext/test-tap-bash is not in 'show --all'"
}

done_testing 15

teardown
