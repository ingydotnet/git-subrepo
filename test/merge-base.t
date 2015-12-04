#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

subrepo-clone-bar-into-foo

(
  cd $OWNER/foo
  git subrepo fetch bar
  git subrepo branch bar
) &> /dev/null || die

# Test no common tree hash,
# We actually test this by supplying unconnected branch
{
  is "$(
    cd $OWNER/foo
    git subrepo merge-base subrepo/bar/fetch master
  )" \
    "No common ancestor found between 'subrepo/bar/fetch' and 'master'." \
    'subrepo merge-base find no common commits'
}

# Both on same tree hash
{
  fetch_head_commit="$(cd $OWNER/foo; git rev-parse subrepo/bar/fetch)"
  bar_head_commit="$(cd $OWNER/foo; git rev-parse subrepo/bar)"

  is "$(
    cd $OWNER/foo
    git subrepo merge-base subrepo/bar/fetch subrepo/bar
  )" \
    "\
Found common ancestor between these commits:
  'subrepo/bar/fetch':HEAD '$fetch_head_commit'
  'subrepo/bar':HEAD '$bar_head_commit'" \
    'subrepo merge-base finds a common node and both are HEADs'
}

(
  cd $OWNER/bar
  add-new-files Bar2
  git push
) &> /dev/null || die

(
  cd $OWNER/foo
  git subrepo clean bar
  git subrepo fetch bar
  git subrepo branch bar
) &> /dev/null || die

# One step ahead on fetch_head
{
  fetch_head_commit="$(cd $OWNER/foo; git rev-parse subrepo/bar/fetch^)"
  bar_head_commit="$(cd $OWNER/foo; git rev-parse subrepo/bar)"
  is "$(
    cd $OWNER/foo
    git subrepo merge-base subrepo/bar/fetch subrepo/bar
  )" \
    "\
Found common ancestor between these commits:
  'subrepo/bar/fetch': '$fetch_head_commit'
  'subrepo/bar':HEAD '$bar_head_commit'" \
    'subrepo merge-base finds a common node and fetch is HEAD'
}

(
  cd $OWNER/foo
  add-new-files bar/Foo2
  git push
  git subrepo clean bar
  git subrepo fetch bar
  git subrepo branch bar
) &> /dev/null || die


# Found a common tree hash
{
  fetch_head_commit="$(cd $OWNER/foo; git rev-parse subrepo/bar/fetch^)"
  bar_head_commit="$(cd $OWNER/foo; git rev-parse subrepo/bar^)"

  is "$(
    cd $OWNER/foo
    git subrepo merge-base subrepo/bar/fetch subrepo/bar
  )" \
    "\
Found common ancestor between these commits:
  'subrepo/bar/fetch': '$fetch_head_commit'
  'subrepo/bar': '$bar_head_commit'" \
    'subrepo merge-base finds a common node'
}

(
  cd $OWNER/foo
  git subrepo pull bar
  git subrepo clean bar
  git subrepo push bar
  git subrepo fetch bar
  git subrepo branch bar
) &> /dev/null || die

# Update and check that we detect that we have equal HEADs
{
  fetch_head_commit="$(cd $OWNER/foo; git rev-parse subrepo/bar/fetch)"
  bar_head_commit="$(cd $OWNER/foo; git rev-parse subrepo/bar)"

  is "$(
    cd $OWNER/foo
    git subrepo merge-base subrepo/bar/fetch subrepo/bar
  )" \
    "\
Found common ancestor between these commits:
  'subrepo/bar/fetch':HEAD '$fetch_head_commit'
  'subrepo/bar':HEAD '$bar_head_commit'" \
    'subrepo merge-base finds a common node after push'
}

done_testing

teardown
