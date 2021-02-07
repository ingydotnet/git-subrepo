#!/usr/bin/env bash

set -e

source test/setup

use Test::More

if ! command -v docker >/dev/null; then
  plan skip_all "The 'docker' utility is not installed"
fi

for zsh_version in 5.8 5.6 5.0.1 4.3.11; do
  error=$(
    docker run --rm -it \
      --volume="$PWD:/git-subrepo" \
      --entrypoint='' \
        "zshusers/zsh:$zsh_version" \
        zsh -c 'source /git-subrepo/.rc 2>&1'
  ) || true

  is "$error" "" "'source.rc' works for zsh-$zsh_version"
done

done_testing

# vim: set ft=sh:
