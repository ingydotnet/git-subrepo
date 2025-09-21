#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

# Test that the repos look ok:
{
  test-exists \
    "$OWNER/foo/.git/" \
    "$OWNER/foo/Foo" \
    "!$OWNER/foo/bar/" \
    "$OWNER/bar/.git/" \
    "$OWNER/bar/Bar"
}

# Make a new branch bar1 in bar 
(
  cd $OWNER/bar
  git checkout -b bar1
) &> /dev/null || die

# check the new bar1 branch:
{
  is "$(
    cd "$OWNER/bar"
    git branch | grep "^*"
    )" \
    "* bar1" \
    'bar: The repo branch is correct'
}

# Make a few new commits in a new branch bar1
(
  cd $OWNER/bar
  echo "Added first change to Bar" >> Bar
  git add Bar
  git commit -m"Added first commit to Bar"
) &> /dev/null || die

{
  cd $OWNER/bar
  bar_commit1=$(git rev-parse HEAD)
  is "$(
    cd "$OWNER/bar"
    git log -1 --oneline | sed -e 's/ .*//g'
    )" \
    "${bar_commit1:0:7}" \
    'bar: The first added commit is correct'
}

(
  cd $OWNER/bar
  echo "Added second change to Bar" >> Bar
  git add Bar
  git commit -m"Added second commit to Bar"
) &> /dev/null || die

{
  cd $OWNER/bar
  bar_commit2=$(git rev-parse HEAD)
  is "$(
    cd "$OWNER/bar"
    git log -1 --oneline | sed -e 's/ .*//g'
    )" \
    "${bar_commit2:0:7}" \
    'bar: The second added commit is correct'
}

(
  cd $OWNER/bar
  echo "Added third change to Bar" >> Bar
  git add Bar
  git commit -m"Added third commit to Bar"
) &> /dev/null || die

{
  cd $OWNER/bar
  bar_commit3=$(git rev-parse HEAD)
  is "$(
    cd "$OWNER/bar"
    git log -1 --oneline | sed -e 's/ .*//g'
    )" \
    "${bar_commit3:0:7}" \
    'bar: The third added commit is correct'
}

# Checkout default branch in bar 
(
  cd $OWNER/bar
  git checkout ${DEFAULTBRANCH}
) &> /dev/null || die

# check the default branch:
{
  is "$(
    cd "$OWNER/bar"
    git branch | grep "^*"
    )" \
    "* ${DEFAULTBRANCH}" \
    'bar: The repo branch is correct'
}

# Do the subrepo clone branch@commit1 and test the output:
{
  clone_output=$(
    cd "$OWNER/foo"
    git subrepo clone -b bar1@${bar_commit1:0:8} "$OWNER/bar"
  )

  # Check output is correct:
  is "$clone_output" \
    "Subrepo '$OWNER/bar' (bar1@${bar_commit1}) cloned into 'bar'." \
    'subrepo clone command output is correct'

  is "$(
    cd "$OWNER/foo"
    git remote -v | grep subrepo/bar
  )" \
    "" \
    'No remotes created'
}

# Check that subrepo files look ok:
gitrepo=$OWNER/foo/bar/.gitrepo
{
  test-exists \
    "$OWNER/foo/bar/" \
    "$OWNER/foo/bar/Bar" \
    "$gitrepo"
}

# Test foo/bar/.gitrepo file contents:
{
  foo_clone_commit=$(cd "$OWNER/foo"; git rev-parse HEAD^)
  test-gitrepo-comment-block
  test-gitrepo-field "remote" "$OWNER/bar"
  test-gitrepo-field "branch" "bar1"
  test-gitrepo-field "commit" "$bar_commit1"
  test-gitrepo-field "parent" "$foo_clone_commit"
  test-gitrepo-field "cmdver" "$(git subrepo --version)"
}

# Make sure status is clean:
{
  git_status=$(
    cd "$OWNER/foo"
    git status -s
  )

  is "$git_status" \
    "" \
    'status is clean'
}

# Do the subrepo pull branch@commit2 and test the output:
{
  pull_output=$(
    cd "$OWNER/foo"
    git subrepo pull -b bar1@${bar_commit2:0:8} bar
  )

  # Check output is correct:
  is "$pull_output" \
    "Subrepo 'bar' pulled from '$OWNER/bar' (bar1@${bar_commit2})." \
    'subrepo pull command output is correct'

  is "$(
    cd "$OWNER/foo"
    git remote -v | grep subrepo/bar
  )" \
    "" \
    'No remotes created'
}

# Check that subrepo files look ok:
gitrepo=$OWNER/foo/bar/.gitrepo
{
  test-exists \
    "$OWNER/foo/bar/" \
    "$OWNER/foo/bar/Bar" \
    "$gitrepo"
}

# Test foo/bar/.gitrepo file contents:
{
  foo_clone_commit=$(cd "$OWNER/foo"; git rev-parse HEAD^)
  test-gitrepo-comment-block
  test-gitrepo-field "remote" "$OWNER/bar"
  test-gitrepo-field "branch" "bar1"
  test-gitrepo-field "commit" "$bar_commit2"
  test-gitrepo-field "parent" "$foo_clone_commit"
  test-gitrepo-field "cmdver" "$(git subrepo --version)"
}

# Make sure status is clean:
{
  git_status=$(
    cd "$OWNER/foo"
    git status -s
  )

  is "$git_status" \
    "" \
    'status is clean'
}

# Make additional change in foo/bar
(
  cd $OWNER/foo
  echo "Added first change to foo/bar/Bar" >> bar/Bar
  git add bar/Bar
  git commit -m"Added first commit to foo/bar/Bar"
  #foo_commit1=$(git rev-parse HEAD)
) &> /dev/null || die

{
  cd $OWNER/foo
  foo_commit1=$(git rev-parse HEAD)
  is "$(
    cd "$OWNER/foo"
    git log -1 --oneline | sed -e 's/ .*//g'
    )" \
    "${foo_commit1:0:7}" \
    'foo: The first added commit is correct'
}

# Do the subrepo push and test output
{
  message=$(
    cd "$OWNER/foo"
    git subrepo push bar 2>&1 || true
  )

  is "$message" "git-subrepo: There are new changes upstream, you need to pull first." \
    'Subrepo push command output is correct'
}

# Do the subrepo forced clone branch@commit3and test the output:
{
  clone_output=$(
    cd "$OWNER/foo"
    git subrepo clone -f -b bar1@${bar_commit3:0:8} "$OWNER/bar"
  )

  # Check output is correct:
  is "$clone_output" \
    "Subrepo '$OWNER/bar' (bar1@${bar_commit3}) recloned into 'bar'." \
    'subrepo clone command output is correct'

  is "$(
    cd "$OWNER/foo"
    git remote -v | grep subrepo/bar
  )" \
    "" \
    'No remotes created'
}

# Check that subrepo files look ok:
gitrepo=$OWNER/foo/bar/.gitrepo
{
  test-exists \
    "$OWNER/foo/bar/" \
    "$OWNER/foo/bar/Bar" \
    "$gitrepo"
}

# Test foo/bar/.gitrepo file contents:
{
  foo_clone_commit=$(cd "$OWNER/foo"; git rev-parse HEAD^)
  test-gitrepo-comment-block
  test-gitrepo-field "remote" "$OWNER/bar"
  test-gitrepo-field "branch" "bar1"
  test-gitrepo-field "commit" "$bar_commit3"
  test-gitrepo-field "parent" "$foo_clone_commit"
  test-gitrepo-field "cmdver" "$(git subrepo --version)"
}

# Make sure status is clean:
{
  git_status=$(
    cd "$OWNER/foo"
    git status -s
  )

  is "$git_status" \
    "" \
    'status is clean'
}

# Make additional change in foo/bar
(
  cd $OWNER/foo
  echo "Added first change to foo/bar/Bar" >> bar/Bar
  git add bar/Bar
  git commit -m"Added first commit to foo/bar/Bar"
  #foo_commit1=$(git rev-parse HEAD)
) &> /dev/null || die

{
  cd $OWNER/foo
  foo_commit1=$(git rev-parse HEAD)
  is "$(
    cd "$OWNER/foo"
    git log -1 --oneline | sed -e 's/ .*//g'
    )" \
    "${foo_commit1:0:7}" \
    'foo: The first added commit is correct'
}

# Do the subrepo push and test output
{
  message=$(
    cd "$OWNER/foo"
    git subrepo push bar 2>&1 || true
  )

  is "$message" \
    "Subrepo 'bar' pushed to '$OWNER/bar' (bar1)." \
    'Subrepo push command output is correct'
}

# Do the subrepo pull branch and test the output:
{
  pull_output=$(
    cd "$OWNER/foo"
    git subrepo pull -b bar1 bar
  )

  # Check output is correct:
  is "$pull_output" \
    "Subrepo 'bar' is up to date." \
    'subrepo pull command output is correct'
}

# Do the subrepo pull branch@commit2 and test the output:
{
  pull_output=$(
    cd "$OWNER/foo"
    git subrepo pull -b bar1@${bar_commit2:0:8} bar 2>&1 | sed -e 's/not contain.*/not contain/' || true
  )

  # Check output is correct:
  is "$pull_output" \
    "git-subrepo: Local repository does not contain" \
    'subrepo pull command output is correct'
}

# Do the subrepo clone branch@commit2 and test the output:
{
  clone_output=$(
    cd "$OWNER/foo"
    git subrepo clone -b bar1@${bar_commit2:0:8} "$OWNER/bar" 2>&1 || true
  )

  # Check output is correct:
  is "$clone_output" \
    "git-subrepo: The subdir 'bar' exists and is not empty." \
    'subrepo clone command output is correct'
}

done_testing

teardown
