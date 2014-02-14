#!/usr/bin/env bash

set -e

source test/setup

use Test::More

source lib/git-subrepo

pass 'source lib/git-subrepo'

done_testing 1
