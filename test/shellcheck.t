#!/usr/bin/env bash

source test/setup

use Test::More

# TODO Should probably check the `shellcheck --version` here too.
if ! command -v shellcheck >/dev/null; then
  plan skip_all "The 'shellcheck' utility is not installed"
fi

IFS=$'\n' read -d '' -r -a shell_files <<< "$(
  echo .rc
  find lib -type f
  echo test/setup
  find test -name '*.t'
  echo share/enable-completion.sh
)" || true

skips=(
  # We want to keep these 2 here always:
  SC1090  # Can't follow non-constant source. Use a directive to specify location.
  SC1091  # Not following: bash+ was not specified as input (see shellcheck -x).

  # These are errors/warnings we can fix one at a time:
  SC2034  # ____ appears unused. Verify use (or export if used externally).
  SC2059  # Don't use variables in the printf format string. Use printf "..%s.." "$foo".

  SC2119  # Use subrepo:clone "$@" if function's $1 should mean script's $1.
  SC2120  # ____ references arguments, but none are ever passed.

  SC2154  # ____ is referenced but not assigned.

  SC2155  # Declare and assign separately to avoid masking return values.
  SC2164  # Use 'cd ... || exit' or 'cd ... || return' in case cd fails.
)
skip=$(IFS=,; echo "${skips[*]}")

for file in "${shell_files[@]}"; do
  [[ $file == *swp ]] && continue
  is "$(shellcheck -e "$skip" "$file")" "" \
    "The shell file '$file' passes shellcheck"
done

done_testing

# vim: set ft=sh:
