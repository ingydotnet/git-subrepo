#!/usr/bin/env bash

set -e

source test/setup

use Test::More

{
  source lib/git-subrepo
  pass 'source lib/git-subrepo'

  source lib/git-subrepo.d/bash+.bash
  pass 'source lib/git-subrepo.d/bash+.bash'
}

done_testing 2

teardown
