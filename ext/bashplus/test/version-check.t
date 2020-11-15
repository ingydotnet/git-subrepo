#!/usr/bin/env bash

source test/setup

PATH=$PWD/bin:$PATH
source bash+ version-check

t1() (echo 0.1.2)
t2() (echo 0.1)

ok "$(version-check t1 0)" "0.1.2 >= 0"
ok "$(version-check t1 0.1)" "0.1.2 >= 0.1"
ok "$(version-check t1 0.1.1)" "0.1.2 >= 0.1.1"
ok "$(version-check t1 0.1.2)" "0.1.2 >= 0.1.2"
ok "$(! version-check t1 0.2)" "0.1.2 >= 0.2 fails"
ok "$(! version-check t1 0.1.3)" "0.1.2 >= 0.1.3 fails"

ok "$(version-check t2 0)" "0.1 >= 0"
ok "$(version-check t2 0.1)" "0.1 >= 0.1"
ok "$(! version-check t2 0.2)" "0.1 >= 0.2 fails"
ok "$(! version-check t2 0.1.1)" "0.1 >= 0.1.1"

done_testing 10
