#!/usr/bin/env bash

set -e

source test/setup

use Test::More

    cd "$TMP"

    # Make two new repos
    (
        mkdir host sub
        git init host
        git init sub
    ) > /dev/null

    # Initialize host repo
    (
        cd host
        touch host
        git add host
        git commit -m "host initial commit"
    ) > /dev/null

    # Initialize sub repo
    (
        cd sub
        git init
        touch subrepo
        git add subrepo
        git commit -m "subrepo initial commit"
    ) > /dev/null

    # Make sub a subrepo of host
    (
        cd host
        git subrepo clone ../sub sub
    ) > /dev/null

    # Commit some changes to the host repo
    (
        cd host
        touch feature
        git add feature
        git commit -m "feature added"
    ) &> /dev/null

    # Commit directly to subrepo
    (
        cd sub
        echo "direct change in sub" >> subrepo
        git commit -a -m "direct change in sub"
    ) > /dev/null

    # Pull subrepo changes
    (
        cd host
        git subrepo pull sub
    ) > /dev/null

    # Commit directly to subrepo
    (
        cd sub
        echo "another direct change in sub" >> subrepo
        git commit -a -m "another direct change in sub"
        git checkout -b temp # otherwise push to master will fail
    ) &> /dev/null

    # Commit to host/sub
    (
        cd host
        echo "change from host" >> sub/subrepo-host
        git add sub/subrepo-host
        git commit -m "change from host"
    ) > /dev/null

    # Pull subrepo changes
    # expected: successful pull without conflicts
    is "$(
            cd host
            git subrepo pull sub
    )" \
        "Subrepo 'sub' pulled from '../sub' (master)."

    # Push subrepo changes
    # expected: successful push without conflicts
    is "$(
            cd host
            git subrepo push sub -b master -u
    )" \
       "Subrepo 'sub' pushed to '../sub' (master)."

done_testing 2

teardown
