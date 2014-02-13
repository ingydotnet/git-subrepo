#!/bin/bash

set -x

# Take some random github repo
repo=${1:-ingydotnet/boolean-pm}

# Delete test dir
rm -fr test-repo

# Clone repo into test dir
git clone "git@github.com:$repo" test-repo

(
  # cd into test-repo
  cd test-repo
  # Tag original head
  git tag o
  # Pick a commit in the middle of the commit history
  S=$(git rev-parse HEAD^^^^)
  # Reset to the middle commit
  git reset --hard $S
  # Tag that history as 'a'
  git tag a
  # Reset to original
  git reset --hard o
  # Take the tail of the history.
  git filter-branch -f --parent-filter "sed 's/-p $S//'" $S..HEAD
  # Mark that sequence as 'b'
  git tag b
  # Reset to a
  git reset --hard a
  # Add a commit
  echo foobar >> README
  git commit README -m 'a change'
  # Tag as a2
  git tag a2
  # Find commits for top of 'a' and root of 'b'
  A=$(git rev-parse a)
  RB=$(git rev-list --max-parents=0 b)
  # Graft them together
  echo "$RB $A" >> .git/info/grafts

  git rebase --abort; git rebase -s recursive -X patience a2 b
#   # Make the graft permanent. ie join head+tail
#   # The commits should rewrite to match original history
#   git filter-branch -f $RB^..b
#   # Get commits for new 'b' and original
#   B=$(git rev-parse b)
#   O=$(git rev-parse o)
#   # Check to see if it works
#   if [ "$B" == "$O" ]; then
#     echo "It worked: $B"
#   else
#     echo "If failed: $B, $O"
#   fi
  bash
)
