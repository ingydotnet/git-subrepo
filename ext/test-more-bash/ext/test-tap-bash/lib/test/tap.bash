# test/tap.bash - TAP Testing Foundation for Bash
#
# Copyright (c) 2013-2016. Ingy döt Net.

#------------------------------------------------------------------------------
Test::Tap:die() { echo "$@" >&2; trap EXIT; exit 1; }
#------------------------------------------------------------------------------

Test__Tap_VERSION=0.0.4

Test::Tap:init() {
  [ -n "$BASH_SOURCE" ] ||
    Test::Tap:die "Error: test-tap-bash must be run under Bash only"
  Test__Tap_plan=0
  Test__Tap_run=0
  Test__Tap_failed=0
  Test__Tap_pid=$BASHPID

  if [ $# -gt 0 ]; then
    [[ $# -eq 2 ]] ||
      Test::Tap:die 'Usage: test/tap.bash tests <number>'
    Test::Tap:plan "$@"
  fi

  trap Test::Tap:END EXIT
}

Test::Tap:plan() {
  Test::Tap:_check-pid
  [ $# -eq 2 ] ||
    Test::Tap:die 'Usage: plan tests <number>'
  if [ "$1" = tests ]; then
    [[ "$2" =~ ^-?[0-9]+$ ]] ||
      Test::Tap:die 'Plan must be a number'
    [[ $2 -gt 0 ]] ||
      Test::Tap:die 'Plan must greater then 0'
    Test__Tap_plan=$2
    printf "1..%d\n" $Test__Tap_plan
  elif [ "$1" == skip_all ]; then
    printf "1..0 # SKIP $2\n"
    exit 0
  else
    Test::Tap:die 'Usage: plan tests <number>'
  fi
}

Test::Tap:pass() {
  Test::Tap:_check-pid
  let Test__Tap_run=Test__Tap_run+1
  local label="$1"
  if [ -n "$label" ]; then
    echo "ok $Test__Tap_run - $label"
  else
    echo "ok $Test__Tap_run"
  fi
}

Test__Tap_CALL_STACK_LEVEL=1
Test::Tap:fail() {
  Test::Tap:_check-pid
  let Test__Tap_run=Test__Tap_run+1
  local c=( $(caller $Test__Tap_CALL_STACK_LEVEL) )
  local file=${c[2]}
  local line=${c[0]}
  local label="$1" callback="$2"
  if [ -n "$label" ]; then
    echo "not ok $Test__Tap_run - $label"
  else
    echo "not ok $Test__Tap_run"
  fi
  label=${label:+"'$label'\n#   at $file line $line."}
  label=${label:-"at $file line $line."}
  echo -e "#   Failed test $label" >&2

  [ -n "$callback" ] && $callback

  local rc=${TEST_TAP_BAIL_ON_FAIL:-0}
  [[ $TEST_TAP_BAIL_ON_FAIL -eq 0 ]] || exit $rc
}

Test::Tap:done_testing() {
  Test::Tap:_check-pid
  Test__Tap_plan=$Test__Tap_run
  echo 1..${1:-$Test__Tap_run}
}

Test::Tap:diag() {
  Test::Tap:_check-pid
  local msg="$@"
  msg="# ${msg//$'\n'/$'\n'# }"
  echo "$msg" >&2
}

Test::Tap:note() {
  Test::Tap:_check-pid
  local msg="$@"
  msg="# ${msg//$'\n'/$'\n'# }"
  echo "$msg"
}

Test::Tap:BAIL_OUT() {
  Test::Tap:_check-pid
  Test__Tap_bail_msg="$@"
  : "${Test__Tap_bail_msg:=No reason given.}"
  exit 255
}

Test::Tap:BAIL_ON_FAIL() {
  Test::Tap:_check-pid
  TEST_TAP_BAIL_ON_FAIL=1
}

Test::Tap:END() {
  local rc=$?
  Test::Tap:_check-pid
  if [ $rc -ne 0 ]; then
    if [ -n "$Test__Tap_bail_msg" -o -n "$TEST_TAP_BAIL_ON_FAIL" ]; then
      local bail="${Test__Tap_bail_msg:-"Bailing out on status=$rc"}"
      echo "Bail out!  $bail"
      exit $rc
    fi
  fi

  for v in plan run failed; do eval local $v=\$Test__Tap_$v; done
  if [ $plan -eq 0 ]; then
    if [ $run -gt 0 ]; then
      echo "# Tests were run but no plan was declared." >&2
    fi
  else
    if [ $run -eq 0 ]; then
      echo "# No tests run!" >&2
    elif [ $run -ne $plan ]; then
      local msg="# Looks like you planned $plan tests but ran $run."
      [ $plan -eq 1 ] && msg=${msg/tests/test}
      echo "$msg" >&2
    fi
  fi
  local exit_code=0
  if [ $Test__Tap_failed -gt 0 ]; then
    exit_code=$Test__Tap_failed
    [ $exit_code -gt 254 ] && exit_code=254
    local msg="# Looks like you failed $failed tests of $run run."
    [ $Test__Tap_failed -eq 1 ] && msg=${msg/tests/test}
    echo "$msg" >&2
  fi
  exit $exit_code
}

Test::Tap:_check-pid() {
  if [ ${BASHPID:-0} -ne ${Test__Tap_pid:-0} ]; then
    die "Error: Called Test::Tap method from a subprocess" 3
  fi
}
