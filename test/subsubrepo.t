#!/usr/bin/env bash

set -e

source test/setup

use Test::More


prepare-repos() {
    rm -rf "$UPSTREAM" "$OWNER"
    mkdir "$UPSTREAM" "$OWNER"
    cp -r "$TEMPLATES"/{foo,bar,doak,init} "$UPSTREAM/"

    cd "$OWNER"
    git clone "$UPSTREAM/foo" 

    cd "$OWNER/foo"
    git subrepo clone "$UPSTREAM/bar" "bar"
    git subrepo clone "$UPSTREAM/doak" "bar/doak"
}

check() {
    if eval "$1"; then
        pass "${2:-}"
    else
        fail "${2:-}"
    fi
}


# Push subrepo - outer first.
{
    prepare-repos
    ok

    check 'git subrepo push "bar"'          "push outer"
    check 'git subrepo push "bar/doak"'     "push inner"
}

# Push subrepo - inner first.
{
    prepare-repos
    ok

    check 'git subrepo push "bar/doak"'     "push inner"
    check 'git subrepo push "bar"'          "push outer"
}


done_testing

teardown
