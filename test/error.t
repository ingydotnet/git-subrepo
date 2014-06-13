#!/usr/bin/env bash

set -e

source test/setup

use Test::More

source lib/git-subrepo

(
  git clone $UPSTREAM/foo $OWNER/foo
  git clone $UPSTREAM/bar $OWNER/bar
) &> /dev/null

catch() { error="$("$@" 2>&1 || true)"; }

{
  catch git subrepo main 1 2 3
  is "$error" \
    "Error: unknown 'git subrepo' command: 'main'" \
    "test error for unknown command"
}

{
  error="$(
    cd $OWNER/bar
    catch git subrepo clone dummy bard
    echo "$error"
  )"
  is "$error" \
    "Error: subdir 'bard' exists and is not empty" \
    "test error non-empty subdir target"
}

{
  error="$(
    cd $OWNER/bar
    catch git subrepo clone dummy-repo
    echo "$error"
  )"
  is "$error" \
    "Error: failed to 'git ls-remote dummy-repo'" \
    "test error for cloning non-repo"
}

# TODO test rest of errors

done_testing 3

source test/teardown
