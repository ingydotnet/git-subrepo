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
    "git-subrepo: 'main' is not a command. See 'git subrepo help'." \
    "test error for unknown command"
}

{
  error="$(
    cd $OWNER/bar
    catch git subrepo clone foo bar baz quux
    echo "$error"
  )"
  is "$error" \
    "git-subrepo: Unknown argument(s) 'baz quux' for 'clone' command." \
    "extra arguments for clone"
}

{
  error="$(
    cd $OWNER/bar
    catch git subrepo clone dummy bard
    echo "$error"
  )"
  is "$error" \
    "git-subrepo: subdir 'bard' exists and is not empty" \
    "test error non-empty subdir target"
}

{
  error="$(
    cd $OWNER/bar
    catch git subrepo clone dummy-repo
    echo "$error"
  )"
  is "$error" \
    "git-subrepo: command failed: git ls-remote dummy-repo" \
    "test error for cloning non-repo"
}

# TODO test rest of errors

done_testing

source test/teardown
