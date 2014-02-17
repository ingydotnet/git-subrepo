#!/usr/bin/env bash

#------------------------------------------------------------------------------
# This is a tiny version of test-more-bash that I use here. test-more-bash uses
# bash+, so I want to avoid the circular dependency. This little guy does
# 80-90% what test-more-bash does, with minimal code. It's a good example of
# how nice Bash can be.
#------------------------------------------------------------------------------

plan() {
  echo "1..$1"
}

pass() {
  let run=run+1
  echo "ok $run${1:+ - $1}"
}

fail() {
  let run=run+1
  echo "not ok $run${1:+ - $1}"
}

is() {
  if [ "$1" == "$2" ]; then
    pass "$3"
  else
    fail "$3"
    diag "Got:  $1"
    diag "Want: $2"
  fi
}

ok() {
  (exit ${1:-$?}) &&
    pass "$2" ||
    fail "$2"
}

like() {
  if [[ "$1" =~ "$2" ]]; then
    pass "$3"
  else
    fail "$3"
    diag "Got:  $1"
    diag "Like: $2"
  fi
}

unlike() {
  if [[ ! "$1" =~ "$2" ]]; then
    pass "$3"
  else
    fail "$3"
    diag "Got:  $1"
    diag "Dont: $2"
  fi
}

done_testing() {
  echo "1..${1:-$run}"
}

diag() {
  echo "# ${1//$'\n'/$'\n'# }" >&2
}

note() {
  echo "# ${1//$'\n'/$'\n'# }"
}
