#!/bin/bash
#
# from: https://unix.stackexchange.com/questions/573047/how-to-get-the-relative-path-between-two-directories
#
# Expects two parameters, source-dir and target-dir, both absolute canonicalized
# non-empty pathnames, either may be /-ended, neither need exist.
# Returns result in shell variable $REPLY as a relative path from source-dir
# to target-dir without trailing /, . if void.
#
# Algorithm is from a 2005 comp.unix.shell posting which has now ascended to
# archive.org.

pnrelpath() {
    set -- "${1%/}/" "${2%/}/" ''               ## '/'-end to avoid mismatch
    while [ "$1" ] && [ "$2" = "${2#"$1"}" ]    ## reduce $1 to shared path
    do  set -- "${1%/?*/}/"  "$2" "../$3"       ## source/.. target ../relpath
    done
    REPLY="${3}${2#"$1"}"                       ## build result
    # unless root chomp trailing '/', replace '' with '.'
    [ "${REPLY#/}" ] && REPLY="${REPLY%/}" || REPLY="${REPLY:-.}"
}

pnrelpath "$1" "$2"

echo $REPLY
