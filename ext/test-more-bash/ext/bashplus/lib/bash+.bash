# bash+ - Modern Bash Programming
#
# Copyright (c) 2013-2016 Ingy döt Net

{
  bash+:version-check() {
    test $1 -ge 4 && return
    test $1 -eq 3 -a $2 -ge 2 && return
    echo "Bash version 3.2 or higher required for 'git hub'" >&2
    exit 1
  }
  bash+:version-check "${BASH_VERSINFO[@]}"
  unset -f Bash:version-check
}

set -e

[ -z "$BASHPLUS_VERSION" ] || return 0

BASHPLUS_VERSION='0.0.7'

@() { echo "$@"; }
bash+:export:std() { @ use die warn; }

# Source a bash library call import on it:
bash+:use() {
  local library_name="${1:?bash+:use requires library name}"; shift
  local library_path=; library_path="$(bash+:findlib $library_name)"
  [[ -n $library_path ]] || {
    bash+:die "Can't find library '$library_name'." 1
  }
  source "$library_path"
  if bash+:can "$library_name:import"; then
    "$library_name:import" "$@"
  else
    bash+:import "$@"
  fi
}

# Copy bash+: functions to unprefixed functions
bash+:import() {
  local arg=
  for arg; do
    if [[ $arg =~ ^: ]]; then
      bash+:import `bash+:export$arg`
    else
      bash+:fcopy bash+:$arg $arg
    fi
  done
}

# Function copy
bash+:fcopy() {
  bash+:can "${1:?bash+:fcopy requires an input function name}" ||
    bash+:die "'$1' is not a function" 2
  local func=; func=$(type "$1" 3>/dev/null | tail -n+3)
  [[ -n $3 ]] && "$3"
  eval "${2:?bash+:fcopy requires an output function name}() $func"
}

# Find the path of a library
bash+:findlib() {
  local library_name=; library_name="$(tr 'A-Z' 'a-z' <<< "${1//:://}").bash"
  local lib="${BASHPLUSLIB:-${BASHLIB:-$PATH}}"
  library_name="${library_name//+/\\+}"
  find ${lib//:/ } -name ${library_name##*/} 2>/dev/null |
    grep -E "$library_name\$" |
    head -n1
}

bash+:die() {
  local msg="${1:-Died}"
  printf "${msg//\\n/$'\n'}" >&2
  local trailing_newline_re=$'\n''$'
  [[ $msg =~ $trailing_newline_re ]] && exit 1

  local c=($(caller ${DIE_STACK_LEVEL:-${2:-0}}))
  (( ${#c[@]} == 2 )) &&
    msg=" at line %d of %s" ||
    msg=" at line %d in %s of %s"
  printf "$msg\n" ${c[@]} >&2
  exit 1
}

bash+:warn() {
  local msg="${1:-Warning}"
  printf "${msg//\\n/$'\n'}\n" >&2
}

bash+:can() {
  [[ $(type -t "${1:?bash+:can requires a function name}") == function ]]
}
