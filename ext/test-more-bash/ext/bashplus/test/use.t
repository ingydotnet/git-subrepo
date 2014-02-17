#!/bin/bash -e

source test/test.bash

PATH=$PWD/bin:$PATH
source bash+ :std can

BASHLIB=test/lib

use Foo::Bar
ok $?                         'use Foo::Bar - works'
ok "`can Foo::Bar:baz`"       'Function Foo::Bar:baz exists'
is "$Foo__Bar_VERSION" 1.2.3  '$Foo__Bar_VERSION == 1.2.3'

output=`use Foo::Foo Boo Booo`
ok $?                         'use Foo::Foo Boo Booo - works'
is "$output" Boo---Booo       'Correct import called'

done_testing 5
