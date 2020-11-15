#!/usr/bin/env bash

source test/setup

source bash+

if ! command -v shellcheck >/dev/null; then
  plan skip_all "The 'shellcheck' utility is not installed"
fi
if [[ ! $(shellcheck --version) =~ 0\.7\.1 ]]; then
  plan skip_all "This test wants shellcheck version 0.7.1"
fi

IFS=$'\n' read -d '' -r -a shell_files <<< "$(
  find bin -type f
  find lib -type f
  echo test/setup
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
  is "$(shellcheck -e "$skip" "$file")" "" \
    "The shell file '$file' passes shellcheck"
done

done_testing

# vim: set ft=sh:
