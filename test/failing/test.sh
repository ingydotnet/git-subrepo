#!/usr/bin/env bash
set -ex

rm -fr p1 p2 lib lib.git

(
  mkdir lib p1 p2
  git init --bare lib
  git init p1
  git init p2
)

(
  git clone lib lib.git
  cd lib.git
  touch readme
  git add readme
  git commit -m "Initial lib"
  git push
)

(
  cd p1
  touch p1
  git add p1
  git commit -m "Initial"
  git subrepo clone ../lib lib -b master
)

(
  cd p2
  touch p2
  git add p2
  git commit -m "Initial"
  git subrepo clone ../lib lib -b master
)

(
  cd p1
  echo "p1 initial add to subrepo" >> lib/readme
  git add lib/readme
  git commit -m "p1 initial add to subrepo"
  git subrepo push --all
)

(
  cd p2
  git subrepo pull --rebase lib -v
  echo "p2 initial add to subrepo" >> lib/readme
  git add lib/readme
  git commit -m "p2 initial add to subrepo"
  git subrepo push --all
)

(
  cd p1
  git subrepo pull --all -v
)
