git-subrepo(1) - Git Submodule Alternative
==========================================

[![Build Status](https://travis-ci.org/ingydotnet/git-subrepo.png?branch=master)](https://travis-ci.org/ingydotnet/git-subrepo)

## Synopsis

    git subrepo help

    git subrepo clone <remote-url>
    git subrepo pull <subdir> --rebase
    git subrepo push <subdir>
    git subrepo checkout <subdir>

    git subrepo status <subdir>
    git subrepo fetch --all
    git subrepo clean --all

    git subrepo version

## Description

This git command "clones" an external git repo and merges it into a
subdirectory of your repo. Later on, upstream changes can be pulled in, and
local changes can be pushed back. Simple.

## Benefits

This command is an improvement on `git-submodule` and `git-subtree`; two other
git commands with similar goals, but various problems.

It assumes there are 3 main roles of people interacting with a repo, and
attempts to serve them all well:

* owner - The person who authors/owns/maintains a repo.
* users - People who are just using/installing the repo.
* collaborators - People who commit code to the repo and subrepos.

The `git-subrepo` command benefits these roles in the following ways:

* Simple and intuitive commandline usage.
* Users get your repo and all your subrepos just by cloning your repo.
* Users do not need to install git-subrepo, ever.
* Collaborators do not need to install unless they want to push/pull.
* Collaborators know when a subdir is a subrepo (it has a `.gitrepo` file).
* Well named branches and remotes are generated for manual operations.
* Owners do not deal with the complications of keeping submodules in sync.
* Subrepos can contain other subrepos.
* Branching with subrepos just works.
* Different branches can have different subrepos in different states, etc.
* Moving/renaming a subrepo subdir just works.
* Your git history is kept squeaky clean.
* Upstream history (clone/pull) is condensed into a single commit.
* You can see the complete subrepo history by using a subrepo remote branch.
* Commits pushed back upstream are NOT condensed.
* Easy to play around with subrepos and then reset back.
* Does not introduce history that messes up other git commands.
* Fixes known rebase failures with `git-subtree`.

## Installation

Get the source code from GitHub:

    git clone git@github.com:git-commands/git-subrepo

Then run:

    make test
    make install        # Possibly with 'sudo'

This will install the `git-subrepo` command next to your other Git
subcommands.  It will also install the manpage (for `git help subrepo`).

To use git-subrepo WITHOUT installing:

    export GIT_EXEC_PATH="/path/to/git-subrepo/lib:$(git --exec-path)"

## Command Options

* `-h`

Short help.

* `--help`

Long help.

* `--all`

If you have multiple subrepos, issue the command to all of them (if
applicable).

* `--branch=<branch-name>` (`-b <branch-name>`)

Use a different branch-name than the remote HEAD or the one saved in
`.gitrepo` locally.

* `--remote=<remote-url>` (`-r <remote-url>`)

Use a different remote-url than the one saved in `.gitrepo` locally.

* `--update` (`-u`)

If `-b` or `-r` are used, and the command updates the `.gitrepo` file, include
these values to the update.

* `--continue`

On a pull or push, you often want to do things by hand. This involves a
`subrepo checkout`, merging and testing, etc. When the subrepo branch is ready
to be integrated (pulled) or pushed back upstream, use this flag on the
relevant pull or push command.

### Merge Options

When doing a `pull` command (or doing a `checkout` for manual merge/pull) you
can specify a 'merge strategy' to be tried:

* `--reclone`

Use this option when you have no local changes to the subrepo, and you simply
want to replace the old content with the new upstream content. If you use
`--branch` or `--remote` options with this option, the `--update` option is
turned on automatically. (new remote and branch are stored in .gitrepo file)

* `--rebase`

Attempt a rebase on top off the remote head.

* `--merge`

Use the default (recursive) merge strategy.

* `--ours`

Use recursive + `-X ours` option.

* `--theirs`

Use recursive + `-X theirs` option.

* `--graft`

This option creates a graft between your local detached subrepo branch and the
fetched upstream branch, so that you can try a hand merge. Some commands like
`git rebase` seem to need this.

* --fetch

When you specify a merge strategy, the command will do a remote fetch
automatically. If no merge strategy option is supplied for a checkout command,
the fetch is not done. This flag says to fetch anyway.

## Commands

* `git subrepo clone <repository> [<subdir>] [-b <upstream-branch>]`

This command adds a repository as a subrepo in a subdir of your repository. It
is similar in feel to `git clone`. You just specify the remote repo url, and
optionally a sub-directory and/or branch name. The repo will be fetched and
merged into the subdir. The subrepo history is not added to your repo history,
but a commit is added that contains the reference information.  This
information is also stored in a special file called `<subdir>/.gitrepo`.  The
presence of this file indicates that the directory is a subrepo.

* `git subrepo pull <subdir>|--all [--<strategy> | --continue] [-r <remote>] [-b <branch>] [-u]`

Update the subdir with the latest remote changes. The subdir must be a subrepo
(must contain a .gitrepo file). If you specify a merge-strategy like
`--rebase` or `--ours`, the command will attempt to fetch, merge and integrate
all in one step. If you want to merge yourself, run a `git subrepo checkout`
first, merge yourself, then run `git subrepo pull <subdir> --continue` and
your branch will be integrated (pulled) into the mainline repo.

* `git subrepo push <subdir>|--all [--continue] [-r <remote>] [-b <branch>]`

This command will make sure that you have already pulled (merged) the upstream
head. Then it will create a branch of the local history involving the subrepo,
and push that back to the remote.

* `git subrepo checkout <subdir>|--all [--<strategy> [-r <remote>] [-b <branch>]]`

This command creates a local branch called subrepo/<subrepo>, that contains
all the subdir commits since the last pull. This is useful when a subrepo pull
has failed. You can merge things by hand, then run a 'git subrepo push'
command. If you specify a merge-strategy, then it will be applied using the
remote head (which is automatically fetched) and this new branch. With no
merge-strategy, just make the branch. After all this, the `checkout` command
will actually checkout the new branch. This command is normally used for hand
merging, but can also be used to see what the local subrepo changes look like,
by themselves. Note: the `.gitrepo` file will be deleted in this subrepo
branch.

* `git subrepo status <subdir>|--all [--quiet]`

Get the status of a subrepo. If `--all` provided, get the status of all
subrepos.  If the `--quiet` flag is used, print less info, and on 1 line per
subrepo.

* `git subrepo fetch <subdir>|--all`

This command will fetch the remote content for a subrepo. It will create a
branch pointing at the FETCH_HEAD called `subrepo/remote/<subdir>` and a
remote called `subrepo/<subdir>`.

* `git subrepo clean <subdir>|--all`

When you run a subrepo command that does a remote fetch, extra branches,
remotes and grafts are created for you. This command will remove them.

* `git subrepo help`

Same as `git help subrepo`. Will launch the manpage. For the shorter usage, use
`git subrepo -h`.

* `git subrepo version [--verbose] [--quiet]`

This command will display version information about git-subrepo and its
environment. For just the version number, use `git subrepo --version`. Use
`--verbose` for more version info, and `--quiet` for less.

## Status

The git-subrepo command is coming together nicely, but some details are still
being ironed out. I would not use it for important things yet, but playing
around with it is cheap (this is not `git submodule`) , and not permanent (if
you do not push to public remotes). ie You can always play around and reset
back to the beginning without pain.

This command has a test suite (run `make test`), but surely has many bugs. If
you have expertise with Git and subcommands, please review the code, and file
issues on anything that seems wrong.

If you want to chat about the `git-subrepo` command, join `#git-commands` on
`irc.freenode.net`.

## Notes

* This command currently only works on POSIX systems.
* The `git-subrepo` repo itself has 2 subrepos under the `ext/` subdirectory.
* Written in (very modern) Bash, with full test suite. Take a look.

## Author

Written by Ingy döt Net <ingy@ingy.net>

## License and Copyright

The MIT License (MIT)

Copyright (c) 2013-2014 Ingy döt Net
