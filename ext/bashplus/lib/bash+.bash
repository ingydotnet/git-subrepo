# bash+ - Modern Bash Programming
#
# Copyright (c) 2013-2020 Ingy döt Net

set -e

[[ ${BASHPLUS_VERSION-} ]] && return 0

BASHPLUS_VERSION=0.0.9

bash+:version-check() {
  local cmd want got out

  IFS=' ' read -r -a cmd <<< "${1:?}"
  IFS=. read -r -a want <<< "${2:?}"
  : "${want[2]:=0}"

  if [[ ${cmd[*]} == bash ]]; then
    got=("${BASH_VERSINFO[@]}")
    BASHPLUS_VERSION_CHECK=${BASH_VERSION-}
  else
    [[ ${#cmd[*]} -gt 1 ]] || cmd+=(--version)
    out=$("${cmd[@]}") ||
      { echo "Failed to run '${cmd[*]}'" >&2; exit 1; }
    [[ $out =~ ([0-9]+\.[0-9]+(\.[0-9]+)?) ]] ||
      { echo "Can't determine version number from '${cmd[*]}'" >&2; exit 1; }
    BASHPLUS_VERSION_CHECK=${BASH_REMATCH[1]}
    IFS=. read -r -a got <<< "$BASHPLUS_VERSION_CHECK"
  fi
  : "${got[2]:=0}"

  ((
    got[0] > want[0] ||
    got[0] == want[0] && got[1] > want[1] ||
    got[0] == want[0] && got[1] == want[1] && got[2] >= want[2]
  )) || return 1

  return 0
}

bash+:version-check bash 3.2 ||
  { echo "The 'bashplus' library requires 'Bash 3.2+'." >&2; exit 1; }

@() (echo "$@")  # XXX do we want to keep this?

bash+:export:std() {
  set -o pipefail

  if bash+:version-check bash 4.4; then
    set -o nounset
    shopt -s inherit_errexit
  fi

  echo use die warn
}

# Source a bash library call import on it:
bash+:use() {
  local library_name=${1:?bash+:use requires library name}; shift
  local library_path=; library_path=$(bash+:findlib "$library_name") || true
  [[ $library_path ]] ||
    bash+:die "Can't find library '$library_name'." 1

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
      # Word splitting required here
      # shellcheck disable=2046
      bash+:import $(bash+:export"$arg")
    else
      bash+:fcopy "bash+:$arg" "$arg"
    fi
  done
}

# Function copy
bash+:fcopy() {
  bash+:can "${1:?bash+:fcopy requires an input function name}" ||
    bash+:die "'$1' is not a function" 2
  local func
  func=$(type "$1" 3>/dev/null | tail -n+3)
  [[ ${3-} ]] && "$3"
  eval "${2:?bash+:fcopy requires an output function name}() $func"
}

# Find the path of a library
bash+:findlib() {
  local library_name
  library_name=$(tr '[:upper:]' '[:lower:]' <<< "${1//:://}").bash
  local lib=${BASHPLUSLIB:-${BASHLIB:-$PATH}}
  library_name=${library_name//+/\\+}
  IFS=':' read -r -a libs <<< "$lib"
  find "${libs[@]}" -name "${library_name##*/}" 2>/dev/null |
    grep -E "$library_name\$" |
    head -n1
}

bash+:die() {
  local msg=${1:-Died}
  msg=${msg//\\n/$'\n'}

  printf "%s" "$msg" >&2
  if [[ $msg == *$'\n' ]]; then
    exit 1
  else
    printf "\n"
  fi

  local c
  IFS=' ' read -r -a c <<< "$(caller "${DIE_STACK_LEVEL:-${2:-0}}")"
  if (( ${#c[@]} == 2 )); then
    msg=" at line %d of %s"
  else
    msg=" at line %d in %s of %s"
  fi

  # shellcheck disable=2059
  printf "$msg\n" "${c[@]}" >&2
  exit 1
}

bash+:warn() {
  local msg=${1:-Warning}
  printf "%s" "${msg//\\n/$'\n'}\n" >&2
}

bash+:can() {
  [[ $(type -t "${1:?bash+:can requires a function name}") == function ]]
}
