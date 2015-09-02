#!/usr/bin/env bash

set -e

source test/setup

use Test::More

{
    cd "$TMP"

    # Make two new repos:
    (
        mkdir A S
        git init A
        git init S
    ) > /dev/null

    # Add an empty file to S
    (
        cd S
        touch S.txt
        git add S.txt
        git commit -a -m "Initial commit to S"
        cd ..
    ) > /dev/null

    # Add an empty file to A
    (
        cd A
        touch A.txt
        git add A.txt
        git commit -a -m "Initial commit to A"
        cd ..
    ) > /dev/null

    # Make S a subrepo of A
    (
        cd A
        git subrepo clone ../S S
        cd ..
    ) > /dev/null

    # Add three commits to A that don't touch S code
    (
        cd A
        echo "commit 1" >> A.txt
        git commit -a -m "commit 1"
        echo "commit 2" >> A.txt
        git commit -a -m "commit 2"
        echo "commit 3" >> A.txt
        git commit -a -m "commit 3"
        cd ..
    ) > /dev/null

    # Push changes to S
    # Expected: no new commits to push message
    (
        cd A
        output=`git subrepo push S -b master -u`
        like "$output" "Subrepo 'S' has no new commits to push." \
        "issue-89 no new commits to push"
    )
}

done_testing 1

teardown