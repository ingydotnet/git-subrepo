#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

(
  cd $OWNER/bar
  add-new-files Bar2
  git push
) &> /dev/null || die

subrepo-clone-bar-into-foo

(
  cd $OWNER/bar
  git reset --hard HEAD^
  add-new-files Bar3
  git push --force
) &> /dev/null || die


# Parent should be missing in history and cause the pull to fail
{
  like "$(
    cd $OWNER/foo
    current_commit=$(git rev-parse HEAD)
    gitrepo_commit=$(git config --file=bar/.gitrepo subrepo.commit)
    catch git subrepo pull bar
  )" \
    "$current_commit.+$gitrepo_commit.+--force.+--squash.+" \
    "subrepo pull should fail due to upstream rebase"
}

# But using force should make it work
{
  is "$(
    cd $OWNER/foo
    git subrepo pull bar --force
  )" \
    "Subrepo 'bar' pulled from '../../../tmp/upstream/bar' (master)." \
    'subrepo pull works with --force'
}

(
  cd $OWNER/foo
  git subrepo push bar --force
) &> /dev/null || die

(
  cd $OWNER/bar
  git pull
) &> /dev/null || die

{
  like "$(
    cd $OWNER/bar
    git log --pretty=%P -n 1 HEAD
  )" \
    "[a-z0-9]{40} [a-z0-9]{40}" \
    'There is a merge commit in the subrepo'
}

done_testing # 9

teardown
