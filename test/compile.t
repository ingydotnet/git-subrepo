#!/usr/bin/env bash

set -e

source test/setup

use Test::More

{
  source lib/git-subrepo
  pass 'source lib/git-subrepo'

  source ext/bashplus/lib/bash+.bash
  pass 'source ext/bashplus/lib/bash+.bash'
}

done_testing 2

teardown
