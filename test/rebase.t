#!/usr/bin/env bash

set -e

source test/setup

use Test::More

# Setup foo with 2 branches, one before the subrepo
# is added and one after so that we can rebase
# thus destroying the parent in two ways. The first
# destroys the second parent, but leave a reference to
# a merge point. The second such that no history of
# a merge point exists.

clone-foo-and-bar

(
    cd "$OWNER/foo"
    git switch -c branch1
    add-new-files foo1
    subrepo-clone-bar-into-foo
    git branch branch2
    add-new-files foo2
) &> /dev/null || die

(
    cd "$OWNER/bar"
    add-new-files bar2
    git push
) &> /dev/null || die

(
    cd "$OWNER/foo"
    # Rebasing onto this merge point will still
    # be able to find the merge point at branch1
    git subrepo pull bar
)

(
    cd "$OWNER/foo"
    git switch branch2
    add-new-files foo-branch2
    git switch branch1
    git rebase branch2
) &> /dev/null || die

# Force subrepo to search of the parent SHA,
# validate it found the prevous merge point
{
    output=$(
      cd "$OWNER/foo"
      git subrepo clean --force --all
      catch git subrepo branch bar
    )

    like "$output" "caused by a rebase" \
      "subrepo detected merge point"
}

done_testing 1

teardown
