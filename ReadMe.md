git-subrepo(1) - Git Submodule Alternative
==========================================

[![Build Status](https://travis-ci.org/ingydotnet/git-subrepo.png?branch=master)](https://travis-ci.org/ingydotnet/git-subrepo)

## Synopsis

    git subrepo help

    git subrepo clone <repo-url> [<subdir>]
    git subrepo pull <subdir> [--<merge-strategy>]
    git subrepo push <subdir> [--<merge-strategy>]
    git subrepo checkout <subdir>
    git subrepo status [<subdir>]

    git subrepo version

## Description

This git command "clones" an external git repo and merges it into a
subdirectory of your repo. Later on, upstream changes can be pulled in, and
local changes can be pushed back. Simple.

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
* Users don't need to install git-subrepo, ever.
* Collaborators don't need to install unless they want to push/pull.
* Collaborators know when a subdir is a subrepo (it has a `.gitrepo` file).
* A project with subrepos also has branches like `subrepo/remote/foo`.
* And it also has remotes for each subrepo, like `subrepo/foo`.
* Owners do not deal with the complications of keeping submodules in sync.
* Subrepos can contain other subrepos.
* Branching with subrepos just works.
* Moving/renaming a subrepo subdir just works.
* Your git history is kept squeaky clean.
* Upstream history is condensed into single commits.
* Every clone and pull is just one commit (plus a merge).
* A subrepo (and all related history) can be removed in one command.

## Installation

Get the source code from GitHub:

    git clone git@github.com:ingydotnet/git-subrepo

Then run:

    make test
    make install        # Possibly with 'sudo'

This will install the `git-subrepo` command next to your other Git subcommands.
It will also install the manpage (for `git help subrepo`).

To use git-subrepo WITHOUT installing:

    export GIT_EXEC_PATH="/path/to/git-subrepo/lib:$(git --exec-path)"

## Commands

* `git subrepo clone <repository> [<subdir>] [-b <upstream-branch>]`

This command adds a repository as a subrepo in a subdir of your repository. It
is similar in feel to `git clone`. You just specify the remote repo url, and
optionally a sub-directory and/or branch name. The repo will be fetched and
merged into the subdir. The subrepo history is not added to your repo history,
but a commit is added that contains the reference information.  This
information is also stored in a special file called `<subdir>/.gitrepo`.  The
presence of this file indicates that the directory is a subrepo. The `clone`
command also adds a new remote called `subrepo/<subdir>` and a remote branch
called `subrepo/remote/<subdir>`.

* `git subrepo pull <subdir> [--<merge-strategy>] [-b <upstream-branch>]`

Update the subdir with the latest remote changes. The subdir must be a subrepo
(must contain a .gitrepo file). You can change the upstream branch to use with
the '-b' flag. If you specify a merge-strategy like `--rebase` or `--ours`, the
command will attempt to fetch, merge and integrate all in one step. If you want
to merge yourself, run a `git subrepo checkout` first, merge yourself, then run
`git subrepo pull <subdir>` (with no merge flag), and your branch will be
integrated (pulled) into the mainline repo.

* `git subrepo push <subdir> [--<merge-strategy>]`

Extract out the recent subrepo commits into to a branch called
subrepo/<subdir>, merge them with upstream, and push them back upstream. Use
the '-b' flag to push to a remote branch that is different than the one the
subrepo is tracking. If you specify a merge-strategy like `--rebase` or
`--ours`, the command will attempt to fetch, merge and push back all in one
step. If you want to merge yourself, run a `git subrepo checkout` first, merge
yourself, then run `git subrepo pull <subdir>` (with no merge flag), and your
branch will be integrated (pulled) into the mainline repo.

* `git subrepo checkout <subdir>`

This command create a local branch called subrepo/<subrepo>, that contains all
the subdir commit since the last pull. This is useful when a subrepo push or
pull has failed.  You can merge things by hand, then run a 'git subrepo push'
(or pull) command with the same branch name.

* `git subrepo status [<subdir>]`

Get the status of a subrepo. If no subdir is provided, get the status of all
subrepos.

* `git subrepo help`

Same as `git help subrepo`. Will launch the manpage. For the shorter usage, use
`git subrepo -h`.

* `git subrepo version`

This command will display version information about git-subrepo and its
environment.

## Status

The git-subrepo command is at version 0.1.0. I consider it ready to use in
anger for my personal projects, but will wait a bit before promoting it widely.
Use your best judgement.

It has a test suite (run `make test`), but surely has many bugs. If you have
expertise in this area, please review the code, and file issues on anything
that seems wrong.

I am 'ingy' on irc.freenode.net. Find me if you want to chat about subrepo.

## Notes

* This command currently only works on POSIX systems.
* The `git-subrepo` repo itself has 2 subrepos under the `ext/` subdirectory.
* Written in (very modern) Bash, with full test suite. Take a look.

## Author

Written by Ingy döt Net <ingy@ingy.net>

## License and Copyright

The MIT License (MIT)

Copyright (c) 2013-2014 Ingy döt Net
