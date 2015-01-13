#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

{
  is "$(
      cd $OWNER/bar
      git subrepo --quiet clone ../../../$UPSTREAM/foo
      git subrepo --quiet branch foo
      catch git subrepo branch foo
    )" \
    "git-subrepo: Branch 'subrepo/foo' already exists." \
    "Error OK: can't create a branch that exists"

  (
    cd $OWNER/bar
    git subrepo --quiet clean foo
    git reset --quiet --hard HEAD^
  )
}

{
  is "$(
      cd $OWNER/bar
      catch git subrepo reset
    )" \
    "git-subrepo: Can't 'subrepo reset'. Subrepo branch not checked out." \
    "Error OK: can't reset unless subrepo checked out"
}

{
  is "$(
      cd $OWNER/bar
      git subrepo --quiet clone ../../../$UPSTREAM/foo
      git subrepo --quiet clean foo
      catch git subrepo log foo
    )" \
    "git-subrepo: No ref 'subrepo/remote/foo'. Try fetch first." \
    "Error OK: log command needs a ref fetched"

  (
    cd $OWNER/bar
    git reset --quiet --hard HEAD^
  )
}

{
  like "$(catch git subrepo clone --foo)" \
    "error: unknown option \`foo" \
    "Error OK: unknown command option"
}

{
  is "$(catch git subrepo main 1 2 3)" \
    "git-subrepo: 'main' is not a command. See 'git subrepo help'." \
    "Error OK: unknown command"
}

{
  is "$(catch git subrepo pull --update)" \
    "git-subrepo: Can't use '--update' without '--branch' or '--remote'." \
    "Error OK: --update requires --branch or --remote options"
}

{
  is "$(catch git subrepo clone --all)" \
    "git-subrepo: Invalid option '--all' for 'clone'." \
    "Error OK: Invalid option '--all' for 'clone'"
}

{
  is "$(catch git subrepo pull --strategy=octopus)" \
    "git-subrepo: Invalid merge strategy: 'octopus'." \
    "Error OK: test invalid merge strategy"
}

{
  is "$(
      cd $OWNER/bar
      catch git subrepo pull /home/user/bar/foo
    )" \
    "git-subrepo: The subdir '/home/user/bar/foo' should not be absolute path." \
    "Error OK: check subdir is not absolute path"
}

{
  # XXX add 'commit' to cmds here when implemented:
  for cmd in pull push fetch branch checkout log clean; do
    is "$(
        cd $OWNER/bar
        catch git subrepo $cmd
      )" \
      "git-subrepo: Command '$cmd' requires arg 'subdir'." \
      "Error OK: check that '$cmd' requires subdir"
  done
}

{
  is "$(
      cd $OWNER/bar
      catch git subrepo clone foo bar baz quux
    )" \
    "git-subrepo: Unknown argument(s) 'baz quux' for 'clone' command." \
    "Error OK: extra arguments for clone"
}

{
  is "$(
      cd $OWNER/bar
      catch git subrepo clone .git
    )" \
    "git-subrepo: Can't determine subdir from '.git'." \
    "Error OK: check error in subdir guess"
}

{
  is "$(
      cd $OWNER/bar
      git subrepo --quiet clone ../../../$UPSTREAM/foo
      git subrepo --quiet checkout foo
      rm -fr .git/refs/subrepo/mainline
      catch git subrepo reset
    )" \
    "git-subrepo: Can't determine mainline branch." \
    "Error OK: reset fails if no mainline ref"

  (
    cd $OWNER/bar
    git subrepo --quiet reset master
    git subrepo --quiet clean foo
    git reset --quiet --hard HEAD^
  )
}

{
  is "$(
      cd $OWNER/bar
      catch git subrepo pull lala
    )" \
    "git-subrepo: 'lala' is not a subrepo." \
    "Error OK: check for valid subrepo subdir"
}

# Test errors while subrepo branch checked out:
{
  # Clone a subrepo and check it out:
  (
    cd $OWNER/bar
    git subrepo --quiet clone ../../../$UPSTREAM/foo
    git subrepo --quiet checkout foo
  )

  # Test that certain commands don't run inside a subrepo branch:
  for cmd in clone pull push branch checkout clean; do
    is "$(
        cd $OWNER/bar
        catch git subrepo $cmd
      )" \
      "git-subrepo: Can't '$cmd' while subrepo branch is checked out." \
      "Error OK: '$cmd' fails when subrepo checked out"
  done

  # Test that certain commands don't accept args inside a subrepo branch:
  for cmd in fetch commit status log; do
    is "$(
        cd $OWNER/bar
        catch git subrepo $cmd arg1
      )" \
      "git-subrepo: Arguments to '$cmd' are invalid while subrepo checked out." \
      "Error OK: '$cmd' accepts no args when subrepo checked out"
  done

  (
    cd $OWNER/bar
    git subrepo --quiet reset
    git subrepo --quiet clean foo
    git reset --quiet --hard HEAD^
  )
}

{
  is "$(
      cd $OWNER/bar
      git checkout --quiet $(git rev-parse master)
      catch git subrepo status
    )" \
    "git-subrepo: Must be on a branch to run this command." \
    "Error OK: check repo is on a branch"
  (
    cd $OWNER/bar
    git checkout --quiet master
  )
}

{
  is "$(
      cd .git
      catch git subrepo status
    )" \
    "git-subrepo: Can't 'subrepo status' outside a working tree." \
    "Error OK: check inside working tree"
}

{
  is "$(
      cd $OWNER/bar
      touch me
      git add me
      catch git subrepo clone ../../../$UPSTREAM/foo
    )" \
    "git-subrepo: Can't clone subrepo. Working tree has changes." \
    "Error OK: check no working tree changes"
  (
    cd $OWNER/bar
    git reset --quiet --hard
  )
}

{
  is "$(
      cd lib
      catch git subrepo status
    )" \
    "git-subrepo: Need to run subrepo command from top level directory of the repo." \
    "Error OK: check cwd is at top level"
}

{
  is "$(
      cd $OWNER/bar
      catch git subrepo clone dummy bard
    )" \
    "git-subrepo: The subdir 'bard' exists and is not empty." \
    "Error OK: non-empty clone subdir target"
}

{
  is "$(
      cd $OWNER/bar
      catch git subrepo clone dummy-repo
    )" \
    "git-subrepo: Command failed: 'git ls-remote dummy-repo'." \
    "Error OK: clone non-repo"
}

done_testing 36

teardown
