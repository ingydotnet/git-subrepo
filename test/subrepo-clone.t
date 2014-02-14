#!/usr/bin/env bash

set -e

source test/setup

use Test::More

source lib/git-subrepo

(
  git clone $UPSTREAM/foo $OWNER/foo
  git clone $UPSTREAM/bar $OWNER/bar
) &> /dev/null

ok "`[ -d $OWNER/foo/.git ]`" \
  "OWNER/foo/ is a cloned git repo"
ok "`[ -f $OWNER/foo/Foo ]`" \
  "OWNER/foo/Foo is a file"

(
  cd $OWNER/foo
  git subrepo clone ../../../$UPSTREAM/bar
) > /dev/null

foo_clone_commit_msg="$(cd $OWNER/foo; git log --skip=1 --max-count=1)"
foo_clone_commit="$(cd $OWNER/foo; git log --skip=1 --max-count=1 --format=%H)"
foo_merge_commit_msg="$(cd $OWNER/foo; git log --max-count=1)"
foo_head_commit="$(cd $OWNER/foo; git rev-parse HEAD)"
bar_head_commit="$(cd $OWNER/bar; git rev-parse HEAD)"

ok "`[ -d $OWNER/foo/bar ]`" \
  "OWNER/foo/bar/ is a subdir"
ok "`[ -f $OWNER/foo/bar/Bar ]`" \
  "OWNER/foo/bar/Bar is a file"

like "$foo_merge_commit_msg" \
  "$foo_head_commit" \
  'subrepo clone merge commit is head'

gitrepo=$OWNER/foo/bar/.gitrepo
ok "`[ -f $gitrepo ]`" "OWNER/foo/bar is a subrepo"

is "`git config -f $gitrepo subrepo.remote`" \
   ../../../$UPSTREAM/bar \
   "subrepo remote is correct"

is "`git config -f $gitrepo subrepo.branch`" \
   master \
   "subrepo branch is correct"

is "`git config -f $gitrepo subrepo.commit`" \
   $bar_head_commit \
   "subrepo commit is correct"

is "`git config -f $gitrepo subrepo.former`" \
   $foo_clone_commit \
   "subrepo former is correct"

like "$foo_clone_commit_msg" \
  "subrepo cloned into 'bar/'" \
  "Subrepo clone commit msg is ok"

like "$foo_merge_commit_msg" \
  "Merge subrepo commit" \
  "Subrepo clone commit msg is ok"

like "$foo_clone_commit_msg" \
  "subrepo commit: $bar_head_commit" \
  "Subrepo clone commit contains bar head commit"

git_status="$(
  cd $OWNER/foo
  git status -s
)"

is "$git_status" \
  "" \
  "status is clean"

done_testing 14

source test/teardown
