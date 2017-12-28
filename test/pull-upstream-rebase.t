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
  cd $OWNER/foo
  current_commit=$(git rev-parse HEAD)
  gitrepo_commit=$(git config --file=bar/.gitrepo subrepo.commit)
  like "$(
    catch git subrepo pull bar
  )" \
    "$current_commit.+$gitrepo_commit.+--force.+--squash.+" \
    "subrepo pull should fail due to upstream rebase"
}

# But using force should make it work
{
  is "$(
    git subrepo pull bar --force
  )" \
    "Subrepo 'bar' pulled from '../../../tmp/upstream/bar' (master)." \
    'subrepo pull works with --force'
}

done_testing # 9

teardown
