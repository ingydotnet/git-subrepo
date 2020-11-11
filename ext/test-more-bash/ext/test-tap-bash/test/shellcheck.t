#!/usr/bin/env bash

source lib/test/tap.bash

if ! command -v shellcheck >/dev/null; then
  Test::Tap:init skip_all "The 'shellcheck' utility is not installed"
fi
if [[ ! $(shellcheck --version) =~ 0\.7\.1 ]]; then
  Test::Tap:init skip_all "This test wants shellcheck version 0.7.1"
fi

Test::Tap:init

IFS=$'\n' read -d '' -r -a shell_files <<< "$(
  find lib -type f
  echo test/helper.bash
  find test -name '*.t'
)" || true

skips=(
  # We want to keep these 2 here always:
  SC1090  # Can't follow non-constant source. Use a directive to specify location.
  SC1091  # Not following: bash+ was not specified as input (see shellcheck -x).
)

skip=$(IFS=,; echo "${skips[*]}")

for file in "${shell_files[@]}"; do
  [[ $file == *swp ]] && continue
  label="The shell file '$file' passes shellcheck"
  got=$(shellcheck -e "$skip" "$file" 2>&1) || true
  if [[ -z $got ]]; then
    Test::Tap:pass "$label"
  else
    Test::Tap:fail "$label"
    Test::Tap:diag "$got"
  fi
done

Test::Tap:done_testing

# vim: set ft=sh:
