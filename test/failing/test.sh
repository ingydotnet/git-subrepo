#!/usr/bin/env bash
set -e

if [ "$1" == 'ReRun' ]; then
  set -x
else
  $0 ReRun 2>&1 | tee log
  exit 0
fi

home="$(dirname $0)"
home="${home:-.}"
cd "$home"
rm -fr p1 p2 lib

(
  mkdir lib p1 p2
  git init lib
  git init p1
  git init p2
)

(
  cd lib
  touch readme
  git add readme
  git commit -m "Initial lib"
  git checkout -b temp #To push to lib later we must not have working copy on master branch.
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
  git branch -D subrepo/lib
)

(
  cd p2
  git subrepo pull lib
  echo "p2 initial add to subrepo" >> lib/readme
  git add lib/readme
  git commit -m "p2 initial add to subrepo"
  git subrepo push --all
)

(
  cd p1
  git subrepo pull --all
)
