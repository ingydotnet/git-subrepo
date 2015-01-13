#!/usr/bin/env bash

set -e

source test/setup

use Test::More

source lib/git-subrepo

(
  git clone $UPSTREAM/foo $OWNER/foo
  git clone $UPSTREAM/bar $OWNER/bar
) &> /dev/null

catch() {
  local error="$("$@" 2>&1 || true)"
  echo "$error"
}

{
  error="$(
    cd $OWNER/bar
    git subrepo --quiet clone ../../upstream/foo
    git subrepo --quiet branch foo
    catch git subrepo branch foo
  )"
  is "$error" \
    "git-subrepo: Branch 'subrepo/foo' already exists." \
    "Error OK: can't create a branch that exists"
  # Get back to way we were:
  (
    cd $OWNER/bar
    git subrepo --quiet clean foo
    git reset --quiet --hard HEAD^
  )
}

{
  error="$(
    cd $OWNER/bar
    catch git subrepo reset
  )"
  is "$error" \
    "git-subrepo: Can't 'subrepo reset'. Subrepo branch not checked out." \
    "Error OK: can't reset unless subrepo checked out"
}

{
  error="$(
    cd $OWNER/bar
    git subrepo --quiet clone ../../upstream/foo
    git subrepo --quiet clean foo
    catch git subrepo log foo
  )"
  is "$error" \
    "git-subrepo: No ref 'subrepo/remote/foo'. Try fetch first." \
    "Error OK: log command needs a ref fetched"
  # Get back to way we were:
  (
    cd $OWNER/bar
    git reset --quiet --hard HEAD^
  )
}

{
  error="$(
    catch git subrepo clone --foo
  )"
  like "$error" \
    "error: unknown option \`foo" \
    "Error OK: unknown command option"
}

{
  error="$(
    catch git subrepo main 1 2 3
  )"
  is "$error" \
    "git-subrepo: 'main' is not a command. See 'git subrepo help'." \
    "Error OK: unknown command"
}

{
  error="$(
    catch git subrepo pull --update
  )"
  is "$error" \
    "git-subrepo: Can't use '--update' without '--branch' or '--remote'." \
    "Error OK: --update requires --branch or --remote options"
}

{
  error="$(
    catch git subrepo clone --all
  )"
  is "$error" \
    "git-subrepo: Invalid option '--all' for 'clone'." \
    "Error OK: Invalid option '--all' for 'clone'"
}

{
  error="$(
    catch git subrepo pull --strategy=octopus
  )"
  is "$error" \
    "git-subrepo: Invalid merge strategy: 'octopus'." \
    "Error OK: test invalid merge strategy"
}

{
  error="$(
    cd $OWNER/bar
    catch git subrepo pull /home/user/bar/foo
  )"
  is "$error" \
    "git-subrepo: The subdir '/home/user/bar/foo' should not be absolute path." \
    "Error OK: check subdir is not absolute path"
}

{
  # XXX add 'commit' to cmds here when implemented:
  for cmd in pull push fetch branch checkout log clean; do
    error="$(
      cd $OWNER/bar
      catch git subrepo $cmd
    )"
    is "$error" \
      "git-subrepo: Command '$cmd' requires arg 'subdir'." \
      "Error OK: check that '$cmd' requires subdir"
  done
}

{
  error="$(
    cd $OWNER/bar
    catch git subrepo clone foo bar baz quux
  )"
  is "$error" \
    "git-subrepo: Unknown argument(s) 'baz quux' for 'clone' command." \
    "Error OK: extra arguments for clone"
}

{
  error="$(
    cd $OWNER/bar
    catch git subrepo clone .git
  )"
  is "$error" \
    "git-subrepo: Can't determine subdir from '.git'." \
    "Error OK: check error in subdir guess"
}

{
  error="$(
    cd $OWNER/bar
    git subrepo --quiet clone ../../upstream/foo
    git subrepo --quiet checkout foo
    rm -fr .git/refs/subrepo/mainline
    catch git subrepo reset
  )"
  is "$error" \
    "git-subrepo: Can't determine mainline branch." \
    "Error OK: reset fails if no mainline ref"

  # Get back to way we were:
  (
    cd $OWNER/bar
    git subrepo --quiet reset master
    git subrepo --quiet clean foo
    git reset --quiet --hard HEAD^
  )
}

{
  error="$(
    cd $OWNER/bar
    catch git subrepo pull lala
  )"
  is "$error" \
    "git-subrepo: 'lala' is not a subrepo." \
    "Error OK: check for valid subrepo subdir"
}

# Test errors while subrepo branch checked out:
{
  # Clone a subrepo and check it out:
  (
    cd $OWNER/bar
    git subrepo --quiet clone ../../upstream/foo
    git subrepo --quiet checkout foo
  )

  # Test that certain commands don't run inside a subrepo branch:
  for cmd in clone pull push branch checkout clean; do
    error="$(
      cd $OWNER/bar
      catch git subrepo $cmd
    )"
    is "$error" \
      "git-subrepo: Can't '$cmd' while subrepo branch is checked out." \
      "Error OK: '$cmd' fails when subrepo checked out"
  done

  # Test that certain commands don't accept args inside a subrepo branch:
  for cmd in fetch commit status log; do
    error="$(
      cd $OWNER/bar
      catch git subrepo $cmd arg1
    )"
    is "$error" \
      "git-subrepo: Arguments to '$cmd' are invalid while subrepo checked out." \
      "Error OK: '$cmd' accepts no args when subrepo checked out"
  done

  # Get back to way we were:
  (
    cd $OWNER/bar
    git subrepo --quiet reset
    git subrepo --quiet clean foo
    git reset --quiet --hard HEAD^
  )
}

{
  error="$(
    cd $OWNER/bar
    git checkout --quiet $(git rev-parse master)
    catch git subrepo status
  )"
  is "$error" \
    "git-subrepo: Must be on a branch to run this command." \
    "Error OK: check repo is on a branch"
  (
    cd $OWNER/bar
    git checkout --quiet master
  )
}

{
  error="$(
    cd .git
    catch git subrepo status
  )"
  is "$error" \
    "git-subrepo: Can't 'subrepo status' outside a working tree." \
    "Error OK: check inside working tree"
}

{
  error="$(
    cd $OWNER/bar
    touch me
    git add me
    catch git subrepo clone ../../upstream/foo
  )"
  is "$error" \
    "git-subrepo: Can't clone subrepo. Working tree has changes." \
    "Error OK: check no working tree changes"
  (
    cd $OWNER/bar
    git reset --quiet --hard
  )
}

{
  error="$(
    cd lib
    catch git subrepo status
  )"
  is "$error" \
    "git-subrepo: Need to run subrepo command from top level directory of the repo." \
    "Error OK: check cwd is at top level"
}

{
  error="$(
    cd $OWNER/bar
    catch git subrepo clone dummy bard
  )"
  is "$error" \
    "git-subrepo: The subdir 'bard' exists and is not empty." \
    "Error OK: non-empty clone subdir target"
}

{
  error="$(
    cd $OWNER/bar
    catch git subrepo clone dummy-repo
  )"
  is "$error" \
    "git-subrepo: Command failed: 'git ls-remote dummy-repo'." \
    "Error OK: clone non-repo"
}

done_testing

source test/teardown
