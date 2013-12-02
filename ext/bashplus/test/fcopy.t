#!/bin/bash -e

source test/test.bash

PATH=$PWD/bin:$PATH
source bash+

foo() {
  echo O HAI
}

like "$(type bar 2>&1)" 'bar: not found' \
  'bar is not yet a function'

bash+:fcopy foo bar

type -t bar &>/dev/null
ok $? 'bar is now a function'
is "$(type foo | tail -n+3)" "$(type bar | tail -n+3)" \
  'Copy matches original'

done_testing 3
