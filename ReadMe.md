git-subrepo(1) - Git Submodule Alternative
==========================================

[![Build Status](https://travis-ci.org/ingydotnet/git-subrepo.png?branch=master)](https://travis-ci.org/ingydotnet/git-subrepo)

## Synopsis

    git subrepo clone <repo-url> [<subdir>]
    git subrepo pull <subdir>
    git subrepo push <subdir>
    git subrepo status [<subdir>]

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
* users - People who are just using/installing the repo.
* collaborators - Other people who commit code to the repo and subrepos.

The `git-subrepo` command benefits these roles in the following ways:

* Extremely simple and intuitive commandline usage.
* Users get the repo and all subrepos just by cloning the repo.
* Collaborators know when a subdir is a subrepo.
* Owners are warned about commits with files in both the repo and subrepo.
* Owners do not deal with any of the usual complications of keeping submodules
  in sync.
* Subrepos can contain other subrepos.
* Moving/renaming a subrepo subdir just works.

## Installation

Get the source code from GitHub:

    git clone git@github.com:ingydotnet/git-subrepo

Then run:

    make test
    make install        # Possibly with 'sudo'

## Commands

* `git subrepo clone <repository> [<subdir>] [-b <branch>]`

This command adds a repository as a subrepo in a subdir of your repository. It
is similar in feel to `git clone`. You just specify the remote repo url, and
optionally a sub-directory and/or branch name. The repo will be fetched and
merged into the subdir. The subrepo history is not added to your repo history,
but a commit is added that contains the reference information.  This
information is also stored in a special file called `<subdir>/.gitrepo`.  The
presence of this file indicates that the directory is a subrepo.

* `git subrepo pull <subdir>`

Update the subdir with the latest remote changes. The subdir must be a subrepo
(must contain a .gitrepo file).

* `git subrepo push <subdir>`

Split out the commits made to the subdir, and push them upstream.

* `git subrepo status [<subdir>]`

Get the status of a subrepo. If no subdir is provided, get the status of all
subrepos.

## Status

This software is very new (as of 1 Dec 2013). It has a test suite (run `make
test`), but surely has many bugs. If you have expertise in this area, please
review the code, and file issues on anything that seems wrong.

## Notes

The `git-subrepo` repo itself has two subrepos. They are under the `./ext/`
subdir.

The `pull` command currently rebases the remote changes. This behavior may
change.

## Author

Written by Ingy döt Net <ingy@ingy.net>

## Copyright

Copyright 2013 Ingy döt Net
