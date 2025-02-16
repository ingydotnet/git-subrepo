#!/bin/bash

set -e
set -x

# Make a directory to work in:
{
  ROOT=${BASH_SOURCE%.sh}
  [ -n "$ROOT" ] || exit 1
  rm -fr "$ROOT"
  mkdir "$ROOT"
}

(
  cd "$ROOT"

  # Start a new repo:
  git init

  # Make an empty file called `file`:
  touch file
  git add file

  # Make 3 commits to `file`:
  for n in {1..3}; do
    echo "Line $n" >> file
    git commit -a -m "Commit #$n"
  done

  # Now `file` has 3 lines.

  # Make a new branch with one commit where the file has 3 lines:
  git checkout --orphan subrepo-fake
  git commit -a -m 'Initial commit on subrepo-fake branch'

  # Return to master and lop off the last commit, so that the `file` has 2
  # lines (and 2 commits):
  git checkout master
  git reset --hard HEAD^

  # Now we rebase like `git subrepo push` does where master is the upstream
  # with 2 commits, and `subrepo-fake` is our fake subrepo branch with one
  # commit:
  git rebase master subrepo-fake || true

  # Command fails on conflict but `|| true` prevents `set -e` from stopping
  # here.

  # Show the current branch status:
  git status

  # Show the rebase conflict:
  cat file

  # This is exactly what is happening with a `git subrepo push`.
)
