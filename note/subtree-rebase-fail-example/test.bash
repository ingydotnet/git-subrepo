#!/bin/bash

set -ex

rm -fr repo{1,2,3}
mkdir repo{1,2}
(
  cd repo1/
  git init
  touch foo
  git add foo
  git commit -m "First commit"
)
(
  cd repo2
  git init
  touch bar
  git add bar
  git commit -m "add bar"
)
git clone repo1 repo3
(
  cd repo3/
  git subrepo clone ../repo2 subrepo
  bash
  git rebase -i HEAD^
  git log -p 
  ls
)
