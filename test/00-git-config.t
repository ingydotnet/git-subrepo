#!/usr/bin/env bash

set -e

source test/setup

use Test::More

note "Define project-wide GIT setup for all tests"

# Get git-subrepo project top directory
PROJ_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )

if [ -z "${PROJ_DIR}" ] || [ "${HOME}" != "${PROJ_DIR}" ]; then
  is "${HOME}" "${PROJ_DIR}" \
  "To define project-wide GIT setup for all tests: HOME '${HOME}' should equal PROJ_DIR '${PROJ_DIR}'"
else

  # Real GIT configuration for tests is set here:
  rm -f "${PROJ_DIR}/.gitconfig"
  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"
  git config --global init.defaultBranch "master"
  git config --global --add safe.directory "${PROJ_DIR}"
  git config --global --add safe.directory "${PROJ_DIR}/.git"
  git config --list

  test-exists "${PROJ_DIR}/.gitconfig"

  # Running tests depends on the whole project being git initialized.
  # So, git initialize the project, if necessary.
  if [ ! -d "${PROJ_DIR}/.git" ]; then
    cd "${PROJ_DIR}"
    git init .
    git add .
    git commit -a -m"Initial commit"
    cd -
  fi

  test-exists "${PROJ_DIR}/.git/"

  # Running tests depends on the whole project not being in a GIT detached HEAD state.
  if ! git symbolic-ref --short --quiet HEAD &> /dev/null; then
    git checkout -b test
  fi

  ok "$(
    git symbolic-ref --short --quiet HEAD &> /dev/null
  )" "Whole project is not in a GIT detached HEAD state"

fi

done_testing

teardown
