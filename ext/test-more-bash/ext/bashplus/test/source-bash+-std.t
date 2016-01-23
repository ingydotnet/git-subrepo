#!/bin/bash -e

source test/test.bash

PATH=$PWD/bin:$PATH
source bash+ :std

ok "`bash+:can use`"         'use is imported'
ok "`bash+:can die`"         'die is imported'
ok "`bash+:can warn`"        'warn is imported'

ok "`! bash+:can import`"    'import is not imported'
ok "`! bash+:can main`"      'main is not imported'
ok "`! bash+:can fcopy`"     'fcopy is not imported'
ok "`! bash+:can findlib`"   'findlib is not imported'
ok "`! bash+:can can`"       'can is not imported'

done_testing 8
