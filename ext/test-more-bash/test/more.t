#!/usr/bin/env bash

source test/setup
use Test::More

plan tests 6

pass 'This test always passes'

is 'foo' "foo" 'foo is foo'

ok "`true`" 'true is true'

ok "`[ 123 -eq $((61+62)) ]`" 'Math works'

ok "`[[ ! team =~ I ]]`" "There's no I in team"

# diag "A msg for stderr"

note "A msg for stdout"

expected=(line1 line2)

command_output=(line1 line2 )
cmp-array command_output expected "command output more"
