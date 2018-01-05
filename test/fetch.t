#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

subrepo-clone-bar-into-foo

(
  cd $OWNER/bar
  add-new-files Bar2
  git tag -a CoolTag -m "Should stay in subrepo"
  git push
) &> /dev/null || die


# Fetch information
{
  is "$(
    cd $OWNER/foo
    git subrepo fetch bar
  )" \
    "Fetched 'bar' from '../../../tmp/upstream/bar' (master)." \
    'subrepo fetch command output is correct'
}

# Check that there is no tags fetched
{
  is "$(
    cd $OWNER/foo
    git tag -l 'CoolTag'
  )" \
    "" \
    'No tag is available'
}

(
  cd $OWNER/foo
  mkdir fie
  add-new-files fie/bar
  git subrepo init fie
) &> /dev/null || die

{
  is "$(
    cd $OWNER/foo
    catch git subrepo fetch fie
  )" \
    "git-subrepo: Can't fetch subrepo. No remote specified. Use --remote" \
    'Empty remote should trigger error'
}

{
  is "$(
    cd $OWNER/foo
    catch git subrepo fetch fie --remote ../../../tmp/upstream/bar
  )" \
    "Fetched 'fie' from '../../../tmp/upstream/bar' ()." \
    'Specify remote'
}

{
  like "$(
    cd $OWNER/foo
    catch git subrepo fetch fie --remote ../../../tmp/upstream/bar --branch newbar
  )" \
    "Couldn't find remote ref newbar" \
    'Unknown remote ref'
}

done_testing

teardown
