git-subrepo(1) - Git Submodule Alternative
==========================================

[![Build Status](https://travis-ci.org/ingydotnet/git-subrepo.png?branch=master)](https://travis-ci.org/ingydotnet/git-subrepo)

## Synopsis

    git subrepo help

    git subrepo clone <repo-url> [<subdir>]
    git subrepo pull <subdir>
    git subrepo push <subdir>

    git subrepo status [<subdir>]
    git subrepo extract <subdir>
    git subrepo remove <subdir>

    git subrepo version

## Description

This git command clones an external git repo and merges it into a subdirectory
of your repo. Later on, upstream changes can be pulled in, and local changes
can be pushed back. Simple.

## Benefits

This command is an improvement on `git-submodule` and `git-subtree`; two other
git commands with similar goals, but various problems.

This command assumes there are 3 main roles of people interacting with a repo,
and attempts to serve them all well:

* owner - The person who authors/owns/maintains a repo.
* user - People who are just using/installing the repo.
* collaborator - People who commit code to the repo and subrepos.

The `git-subrepo` command benefits these roles in the following ways:

* Extremely simple and intuitive commandline usage.
* Users get your repo and all your subrepos just by cloning your repo.
* Collaborators know when a subdir is a subrepo (it has a .gitrepo file).
* Owners do not deal with the complications of keeping submodules in sync.
* Subrepos can contain other subrepos.
* Branching with subrepos just works.
* Moving/renaming a subrepo subdir just works.
* Your git history is kept squeaky clean.
* Every clone and pull is just one commit (plus a merge).
* Upstream history is condensed into one commit.
* A subrepo (and all related history) can be removed in one command.

## Installation

Get the source code from GitHub:

    git clone git@github.com:ingydotnet/git-subrepo

Then run:

    make test
    make install        # Possibly with 'sudo'

To use this without installing:

    export GIT_EXEC_PATH="/path/to/git-subrepo/lib:$(git --exec-path)"

## Commands

* `git subrepo clone <repository> [<subdir>] [-b <upstream-branch>]`

This command adds a repository as a subrepo in a subdir of your repository. It
is similar in feel to `git clone`. You just specify the remote repo url, and
optionally a sub-directory and/or branch name. The repo will be fetched and
merged into the subdir. The subrepo history is not added to your repo history,
but a commit is added that contains the reference information.  This
information is also stored in a special file called `<subdir>/.gitrepo`.  The
presence of this file indicates that the directory is a subrepo.

* `git subrepo pull <subdir> [-b <upstream-branch>]`

Update the subdir with the latest remote changes. The subdir must be a subrepo
(must contain a .gitrepo file). You can change the upstream branch to use with
the '-b' flag.

* `git subrepo push <subdir> [<extract-branch>] [-b <upstream-branch>]`

Extract out the commits made to the subdir, merge them with upstream, and push
them back upstream. If you specify an 'extract-branch', it means that you
already ran a 'git subrepo extract' (which created a branch) and you want to
push it upstream. See the 'extract' command below. Use the '-b' flag to push
to a remote branch that is different than the one the subrepo is tracking.

* `git subrepo extract <subdir> [<extract-branch>]`

This command will extract a subrepo into a branch (default branch name is
'subrepo'). This is useful when a 'git subrepo push' fails to merge properly.
You can merge things by hand, then run a 'git subrep push' command with the
same branch name.

* `git subrepo status [<subdir>]`

Get the status of a subrepo. If no subdir is provided, get the status of all
subrepos.

* `git subrepo remove <subdir>`

This command will remove your subrepo and all of its history, as though it
never existed. Please note that this will rewrite your entire history. If that
would cause you problems, then maybe you just want 'git rm' the subrepo
instead.

* `git subrepo version`

This command will display version information about git-subrepo and its
environment.

## Status

This software is very new. It has a test suite (run `make test`), but surely
has many bugs. If you have expertise in this area, please review the code, and
file issues on anything that seems wrong.

## Notes

This command currently only works on POSIX systems.

The `git-subrepo` repo itself has two subrepos. They are under the `./ext/`
subdir.

## Author

Written by Ingy döt Net <ingy@ingy.net>

## Copyright

Copyright 2013, 2014 Ingy döt Net
