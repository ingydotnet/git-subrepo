#!/usr/bin/env bash

set -e

source test/setup

use Test::More

{
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

    # Create a branch in host and make some changes in it
    (
        cd host
        git checkout -b feature
        touch feature
        git add feature
        git commit -m "feature added"
        git checkout master
    ) &> /dev/null

    # Commit directly to subrepo
    (
        cd sub
        echo "direct change in sub" >> subrepo
        git commit -a -m "direct change in sub"
    ) > /dev/null

    # pull subrepo changes
    (
        cd host
        git subrepo pull sub
    ) > /dev/null

    # commit directly to subrepo
    (
        cd sub
        echo "another direct change in sub" >> subrepo
        git commit -a -m "another direct change in sub"
    ) > /dev/null

    # commit to host/sub
    (
        cd host
        echo "change from host" >> sub/subrepo-host
        git add sub/subrepo-host
        git commit -m "change from host"
    ) > /dev/null

    # merge previously created feature branch
    (
        cd host
        git merge --no-ff --no-edit feature
    ) > /dev/null

    # pull subrepo changes
    # expected: successful pull without conflicts
    is "$(
            cd host
            git subrepo pull sub
    )" \
        "Subrepo 'sub' pulled from '../sub' (master)."

}

done_testing 1

teardown
