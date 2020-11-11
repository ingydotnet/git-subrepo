# test/tap.bash - TAP Testing Foundation for Bash
#
# Copyright (c) 2013-2020. Ingy döt Net.

#------------------------------------------------------------------------------
Test::Tap:die() { echo "$@" >&2; trap EXIT; exit 1; }
#------------------------------------------------------------------------------

set -e -u -o pipefail
[[ ${BASH_VERSION-} == 4.0* ]] && set +u

# shellcheck disable=2034
Test__Tap_VERSION=0.0.6

Test::Tap:init() {
  [[ ${BASH_SOURCE[0]} ]] ||
    Test::Tap:die "Error: test-tap-bash must be run under Bash only"
  Test__Tap_plan=0
  Test__Tap_run=0
  Test__Tap_failed=0
  Test__Tap_pid=${BASHPID:-0}

  if [[ $# -gt 0 ]]; then
    [[ $# -eq 2 ]] ||
      Test::Tap:die 'Usage: test/tap.bash tests <number>'
    Test::Tap:plan "$@"
  fi

  trap Test::Tap:END EXIT
}

Test::Tap:plan() {
  Test::Tap:_check-pid
  [[ $# -eq 2 ]] ||
    Test::Tap:die 'Usage: plan tests <number>'
  if [[ $1 = tests ]]; then
    [[ $2 =~ ^-?[0-9]+$ ]] ||
      Test::Tap:die 'Plan must be a number'
    [[ $2 -gt 0 ]] ||
      Test::Tap:die 'Plan must greater then 0'
    Test__Tap_plan=$2
    printf "1..%d\n" "$Test__Tap_plan"
  elif [[ $1 == skip_all ]]; then
    printf "1..0 # SKIP %s\n" "$2"
    exit 0
  else
    Test::Tap:die 'Usage: plan tests <number>'
  fi
}

Test::Tap:pass() {
  Test::Tap:_check-pid
  ((++Test__Tap_run))
  local label=${1-}
  if [[ $label ]]; then
    echo "ok $Test__Tap_run - $label"
  else
    echo "ok $Test__Tap_run"
  fi
}

Test__Tap_CALL_STACK_LEVEL=1
Test::Tap:fail() {
  Test::Tap:_check-pid
  ((++Test__Tap_run))
  IFS=' ' read -r -a c <<<"$(caller $Test__Tap_CALL_STACK_LEVEL)"
  local file=${c[2]-}
  local line=${c[0]-}
  local label=${1-} callback=${2-}
  if [[ $label ]]; then
    echo "not ok $Test__Tap_run - $label"
  else
    echo "not ok $Test__Tap_run"
  fi
  label=${label:+"'$label'\n#   at $file line $line."}
  label=${label:-"at $file line $line."}
  echo -e "#   Failed test $label" >&2

  [[ $callback ]] && $callback

  local rc=${TEST_TAP_BAIL_ON_FAIL:-0}
  [[ $rc -eq 0 ]] || exit "$rc"
}

Test::Tap:done_testing() {
  Test::Tap:_check-pid
  Test__Tap_plan=$Test__Tap_run
  echo 1.."${1:-$Test__Tap_run}"
}

Test::Tap:diag() {
  Test::Tap:_check-pid
  local msg=$*
  msg="# ${msg//$'\n'/$'\n'# }"
  echo "$msg" >&2
}

Test::Tap:note() {
  Test::Tap:_check-pid
  local msg=$*
  msg="# ${msg//$'\n'/$'\n'# }"
  echo "$msg"
}

Test::Tap:BAIL_OUT() {
  Test::Tap:_check-pid
  Test__Tap_bail_msg=$*
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
  if [[ $rc -ne 0 ]]; then
    if [[ ${Test__Tap_bail_msg-} ]] ||
       [[ ${TEST_TAP_BAIL_ON_FAIL-} ]]; then
      local bail=${Test__Tap_bail_msg:-"Bailing out on status=$rc"}
      echo "Bail out!  $bail"
      exit $rc
    fi
  fi

  if [[ $Test__Tap_plan -eq 0 ]]; then
    if [[ $Test__Tap_run -gt 0 ]]; then
      echo "# Tests were run but no plan was declared." >&2
    fi
  else
    if [[ $Test__Tap_run -eq 0 ]]; then
      echo "# No tests run!" >&2
    elif [[ $Test__Tap_run -ne $Test__Tap_plan ]]; then
      local msg="# Looks like you planned $Test__Tap_plan tests but ran $Test__Tap_run."
      [[ $Test__Tap_plan -eq 1 ]] && msg=${msg/tests/test}
      echo "$msg" >&2
    fi
  fi
  local exit_code=0
  if [[ $Test__Tap_failed -gt 0 ]]; then
    exit_code=$Test__Tap_failed
    [[ $exit_code -gt 254 ]] && exit_code=254
    local msg="# Looks like you failed $Test__Tap_failed tests of $Test__Tap_run run."
    [[ $Test__Tap_failed -eq 1 ]] && msg=${msg/tests/test}
    echo "$msg" >&2
  fi
  exit $exit_code
}

Test::Tap:_check-pid() {
  if [[ ${BASHPID:-0} -ne ${Test__Tap_pid:-0} ]]; then
    Test::Tap:die "Error: Called Test::Tap method from a subprocess" 3
  fi
}
