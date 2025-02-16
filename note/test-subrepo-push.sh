#!/bin/bash

set -ex

# Make a directory to work in:
{
  ROOT=${BASH_SOURCE%.sh}
  [ -n "$ROOT" ] || exit 1
  rm -fr "$ROOT"
  mkdir "$ROOT"
}

(
  cd "$ROOT"

  # Create "bare" repos to act as pushable upstreams
  git init --bare parent-upstream
  git init --bare child-upstream

  # Clone the upstreams into local repos
  git clone parent-upstream parent
  git clone child-upstream child

  (
    cd parent
    echo 'Initial parent commit' > parent.txt
    git add parent.txt
    git commit -m 'initial parent commit'
    git push
  )

  (
    cd child
    echo 'Initial child commit' > child.txt
    git add child.txt
    git commit -m 'Initial child commit'
    git push
  )

  (
    cd parent
    git subrepo clone ../child-upstream childrepo
  )

  (
    cd child
    echo 'Commit from child' >> child.txt
    git commit -a -m 'commit from child'
    git push
  )

  (
    cd parent
    git subrepo pull childrepo
  )

  (
    cd parent
    echo 'Commit from parent for pushing' >> childrepo/child.txt
    echo 'Commit from parent for pushing' >> parent.txt
    git commit -a -m 'Commit from parent for pushing'
    git push
  )

  (
    cd parent
    git subrepo push childrepo -d || bash -i
  )
)
