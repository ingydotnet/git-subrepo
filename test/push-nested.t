#!/usr/bin/env bash

set -e

source test/setup

nested_fix=1

use Test::More

clone-foo-and-bar

# Add subrepo twice; of which one nested in a subrepo subdir (it's bar but could be any other)
(
  # In the main repo:
  cd "$OWNER/foo"

  # Clone a subrepo into a subdir
  git subrepo clone "$UPSTREAM/bar"

  # Clone another subrepo into a nested subdir (here it's bar -- no e.g. baz in current fixture)
  git subrepo clone "$UPSTREAM/bar" "bar/bar"

  # Make a commit in a subrepo:
  add-new-files bar/FooBar

  # Make a commit in a subrepo nested in a subrepo:
  add-new-files bar/bar/FooBaz
) &> /dev/null || die

# Do the subrepo push to another branch:
{
  message=$(
    cd "$OWNER/foo"
    git subrepo push bar/bar --branch newbar
    git subrepo pull bar --branch newbar # FooBaz
  )

  message=$(
    cd "$OWNER/foo"
    git subrepo push bar --branch newbar # FooBar only or bar/FooBaz, too ?
  )

  # Test the output:
  is "$message" \
    "Subrepo 'bar' pushed to '$UPSTREAM/bar' (newbar)." \
    'First push message is correct '
}

# Pull the changes from UPSTREAM/bar in OWNER/bar
(
  cd "$OWNER/bar"
  git fetch
  git checkout newbar
) &> /dev/null || die

test-exists \
  "$OWNER/bar/FooBar"

test-exists \
  "$OWNER/bar/FooBaz"

if [[ $nested_fix == 1 ]] ; then
  # nested subrepo skipped at push: no bar/bar
  [[ ! -f "$OWNER/bar/bar/FooBaz" ]]
else
  # nested subrepo (in subdir bar/bar) added as well
  test-exists \
    "$OWNER/bar/bar/FooBaz"
fi

done_testing

teardown
