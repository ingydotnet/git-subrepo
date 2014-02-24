Introducing Git Subrepos
========================
by: Ingy döt Net
on: February 20, 2014


There is a new git command called `subrepo` that is meant to be a solid
alternative to the `submodule` and `subtree` commands. All 3 of these commands
allow you to include external repositories (pinned to specific commits) in your
main repository. This is an often needed feature for project development under
a source control system like Git. Unfortunately, the `submodule` command is
severely lacking, and the `subtree` command (an attempt to make things better)
is also very flawed. Fortunately, the `subrepo` command is here to save the
day.

This article will discuss how the previous commands work, and where they go
wrong, while explaining how the new `subrepo` command fixes the issues.

It should be noted that there are 3 distinct roles (ways people use repos)
involved in discussing this topic:

* owner — The primary author and repo owner
* collaborators — Other developers who contribute to the repo
* users — People who simply use the repo software

## Introducing `subrepo`

While the main point is to show how subrepo addresses the shortcomings of
submodule and subtree, I'll start by giving a quick intro to the subrepo
command.

Let's say that you have a project repo called 'freebird' and you want to have
it include 2 other external repos, 'lynyrd' and 'skynyrd'. You would do the
following:

    git clone git@github.com/you/freebird
    cd freebird
    git subrepo clone git@github.com/you/lynyrd ext/lynyrd
    git subrepo clone git@github.com/you/skynyrd ext/skynyrd --branch=1975

What these commands do (at a high level) should be obvious. They "clone"
(add) the repos content into the subdirectories you told them to. The details
of what is happening to your repo will be discussed later, but adding new
subrepos is easy. If you need to update the subrepos later:

    git subrepo pull ext/lynyrd
    git subrepo pull ext/skynyrd --branch=1976

The lynyrd repo is tracking the upstream master branch, and you've changed the
skynyrd subrepo to the 1976 branch. Since these subrepos are owned by 'you',
you might want to change them in the context of your freebird repo. When things
are working, you can push the subrepo changes back:

    git subrepo push ext/lynyrd
    git subrepo push ext/skynyrd

Looks simple right? It's supposed to be. The intent of `git-subrepo` is to do
the right things, and don't cause problems.

Of course there's more to it under the hood, and that's what the rest of this
article is about.

## Git Submodules

Submodules tend to receive a lot of bad press. Here's some of it:

* http://ayende.com/blog/4746/the-problem-with-git-submodules
* http://somethingsinistral.net/blog/git-submodules-are-probably-not-the-answer/
* http://codingkilledthecat.wordpress.com/2012/04/28/why-your-company-shouldnt-use-git-submodules/

A quick recap of some of the good and bad things about submodules:

Good:

* Use an external repo in a dedicated subdir of your project.
* Pin the external repo to a specific commit.
* The `git-submodule` command is a core part of the Git project.

Bad:

* Users have to know a repo has submodules.
* Users have to get the subrepos manually.
* Pulling a repo with submodules won't pull in the new submodule changes.
* Can't use different submodules/commits per main project branch.
* Can't "try out" a submodule on alternate branch.
* Main repo can be pushed upstream pointing to unpushed submod commits.
* Command capability differs across Git versions.
* Often need to change remote url, to push submodule changes upstream.
* Removing or renaming a submodule requires many steps.

Internally, submodules are a real mess. They give the strong impression of
being bolted on, well after Git was designed. Some commands are aware of the
existence of submodules (although usually half-heartedly), and many commands
are oblivious. For instance the git-clone command has a `--recursive` option to
clone all subrepos, but it's not a default, so you still need to be aware of
the need. The git-checkout command does nothing with the submodules, even if
they are intended to differ across branches.

Let's talk a bit about how submodules are implemented in Git. Information about
them is stored in 3 different places (in the top level repo directory):

* `.gitmodules`
* `.git/config`
* `.git/modules` — The submodule repo's meta data (refs/objects)

So some of the information lives in the repo history (.gitmodules), but other
info (.git/) is only known to the local repo.

In addition, the submodule introduces a new low level concept, to the
commit/tree/blob graph. Normally a git tree object points to blob (file)
objects and more tree (directory) objects. Submodules have tree objects point
to *commit* objects. While this seems clever and somewhat reasonable, it also
means that every other git command (which was built on the super clean Git data
model) has to be aware of this new possibility (and deal with it
appropriately).

The point is that, while submodules are a real need, and a lot of work has gone
into making them work decently, they are essentially a kludge to the Git model,
and it is quite understandable why they haven't worked out as well as people
would expect.

NOTE: I do realize that submodules are getting better with each release of Git,
but it's still an endless catch up game.

## Git Subtrees

One day, someone decided to think different. Instead of pointing to external
repos, why not just include them into the main repo (but also allow them to be
pulled and pushed separately as needed)?

At first this may feel like a wasteful approach. Why keep other repos
physically inside your main one? But if you think about it abstractly, what's
the difference? You want your users and collaborators to have all this code
because your project needs it. So why worry about how it happens? In the end,
the choice is yours, but I've grown very comfortable with this concept and I'll
try to justify it well. I should note that the first paragraph of the
`submodule` doc, suggests considering this alternative.

The big win here, is that you can do this using the existing git model. Nothing
new is added. You are just adding commits to a history. You can do it different
on every branch. You can merge branches sensibly.

The git-subtree command seems to have been inspired by Git's subtree merge
strategy, which it uses internally, and possibly got its name from. A subtree
merge allows you to take a completely separate Git history and make it be a
subdirectory of your repo.

Adding a subtree was the easy part. All that needed to be done after that was
to figure out a way to pull upstream changes and push local ones back upstream.
And that's what the `git-subtree` command does.

So what's the problem with git-subtree then?

Well unfortunately, it drops a few balls. The main problems come down to an
overly complicated commandline UX, poor collaborator awareness, and a fragile
and messy implementation.

Good:
* Use an external repo in a dedicated subdir of your project.
* Pin the external repo to a specific commit.
* Users get everything with a normal clone command.
* Users don't need to know that subtrees are involved.
* Can use different submodules/commits per main project branch.
* Users don't need the subtree command. Only owners and collaborators.

Bad:
* The remote url and branch info is not saved (except in the history).
* Owners and collaborators have to enter the remote for every command.
* Collaborators aren't made aware that subtrees are involved.
* Pulled history is not squashed by default.
* Creates a messy historical view. (See below)
* Bash code is complicated.
* Only one test file. Currently is failing.

As you can see, subtree makes quite a few things better, but after trying it
for a while, the experience was more annoying than submodules. For example,
consider this usage:

    $ git subtree add --squash --prefix=foo git@github.com:my/thing mybranch
    # weeks go by…
    $ git subtree pull --squash --prefix=foo git@github.com:my/thing mybranch
    # time to push local subtree changes back upstream
    $ git subtree push --prefix=foo git@github.com:my/thing mybranch

The first thing you notice is the overly verbose syntax. It's justified in the
first command, but in the other 2 commands I really don't want to have to
remember what the remote and branch are that I'm using.

Moveover, my collaborators have no idea that subtrees are involved, let alone
where they came from.

Consider the equivalent subrepo commands:

    $ git subrepo clone foo git@github.com:my/thing -b mybranch
    $ git subrepo pull foo
    $ git subrepo push foo

Collaborators see a file called 'foo/.gitrepo', and know that the subdir is a
subrepo. The file contains all the information needed by future commands
applied to that subrepo.

## Git Subrepos

Now is a good time to dive into the techinical aspects of the `git-subrepo`
command, but first let me explain how it came about.

As you may have surmised by now, I am the author of git-subrepo. I'd used
submodules on and off for years, and when I became aware of subtree I gave it a
try, but I quickly realized its problems. I decided maybe it could be improved.
I decided to write down my expected commandline usage and my ideals of what it
would and would not do. Then I set off to implement it. It's been a long road,
but what I ended up with was even better than what I wanted from the start.

Let's review the Goods and Bads:

Good:
* Use an external repo in a dedicated subdir of your project.
* Pin the external repo to a specific commit.
* Users get everything with a normal clone command.
* Users don't need to know that subrepos are involved.
* Can use different submodules/commits per main project branch.
* Meta info is kept in obvious place.
* Everyone knows when a subdir is a subrepo.
* Commandline UX is minimal and intuitive.
* Pulled history is always squashed out locally.
* Pushed history is kept intact.
* Creates a clean historical view. (See below)
* Bash code is very simple and easy to follow.
* Comprehensive test suite. Currently passing on travis: [![Build Status](https://travis-ci.org/ingydotnet/git-subrepo.png?branch=master)](https://travis-ci.org/ingydotnet/git-subrepo)

Bad:
* Subrepo is very new.
* Not well tested in the wild.

This review may seem somewhat slanted, but I honestly am not aware of any
"bad" points that I'm not disclosing. That said, I am sure time will reveal
bugs and shortcomings. Those can usually be fixed. Hopefully the *model* is
correct, because that's harder to fix down the road.

OK. So how does it all work?

There are 3 main commands: clone/pull/push. Let's start with the clone command.
This is the easiest part. You give it a remote url, possibly a new subdir to
put it, and possibly a remote branch to use. I say possibly, because the
command can guess the subdir name (just like the git-clone command does), and
the branch can be the upstream default branch.

Given this we do the following steps internally:

* Fetch the remote content (for a specific refspec)
* Read the remote head tree into the index
* Checkout the index into the new subdir
* Create a new subrepo commit object for the tree
* Create a merge commit to combine the subrepo commit and the mainline HEAD
* Add a state file called .gitrepo to the new subrepo/subdir
* Amend the merge commit with this new file

This process adds something like this to the top of your history:

    *   29ce688 (HEAD, master) Merge subrepo commit '9b6ddc9'
    |\
    | * 9b6ddc9 subrepo clone: git@github.com:you/foo.git (master) -> foo/

The entire history has been squashed down into one commit, and that commit has
no parent. This is important as it keeps your history as clean as possible. You
don't need to have the subrepo history in your main project, since it is
immutably available elsewhere, and you have a pointer to that place.

The new foo/.gitrepo file looks like this:

    [subrepo]
            remote = git@github.com:you/foo.git
            branch = master
            commit = 14c96c6931b41257b2d42b2edc67ddc659325823
            former = 9b6ddc9429a4005289ed67134515f7c5cfd289fb
            cmdver = 0.1.0

It contains all the info needed now and later. Note that the repo url is the
generally pushable form, rather than the publically readable (https://…) form.
This is the best practice. Users of your repo don't need access to this url,
because the content is already in your repo. Only you and your collaborators
need this url to pull/push in the future.

The next command is the pull command. Normally you just give it the
subrepo/subdir path (although you can change the branch with -b), and it will
get the other info from the subdir/.gitrepo file.

The pull command does these steps:

* Fetch the remote content
* Check if anything needs pulling
* Create a "pull" commit for the new upstream tree
* Merge this commit into the repo with the subtree strategy
* Remove the parent pointer of the pull commit (clean history)
* Put the pull commit id into the merge commit
* Update/amend the .gitrepo file

### Clean History

I've talked a bit about clean history but let me show you a comparison between
subtree and subrepo. Let's say I run this command sequence using both methods:

    $ git subxxxx add tree1 <remote> <commit1>
    $ git subxxxx add tree2 <remote> <commit1>
    $ git subxxxx push tree1 <remote> <commit2>
    $ git subxxxx push tree2 <remote> <commit2>

The syntax above is pseudo, but you get the idea. The resulting history using
subrepo is:

    * 7aa5a63 (HEAD, master) Merge subrepo commit 'b1f60cc'
    |\
    | * b1f60cc subrepo pull: git@github.com:user/xyz (commit2) -> tree2/
    * 353f38f Merge subrepo commit '4fb0276'
    |\
    | * 4fb0276 subrepo pull: git@github.com:user/xyz (commit2) -> tree1/
    * 3f09025 Merge subrepo commit 'bcef2a0'
    |\
    | * bcef2a0 subrepo clone: git@github.com:user/xyz (commit1) -> tree2/
    * 6ec38a0 Merge subrepo commit 'bebf0db'
    |\
    | * bebf0db subrepo clone: git@github.com:user/xyz (commit1) -> tree1/
    * 64eeaa6 (origin/master, origin/HEAD) O HAI FREND

Compare that to this history using subtree:

    * 739e45a (HEAD, master) Merge commit '5f563469d886d53e19cb908b3a64e4229f88a2d1'
    |\
    | * 5f56346 Squashed 'tree2/' changes from 08c7421..365409f
    * | 641f5e5 Merge commit '8d88e90ce5f653ed2e7608a71b8693a2174ea62a'
    |\ \
    | * | 8d88e90 Squashed 'tree1/' changes from 08c7421..365409f
    * | | 1703ed2 Merge commit '0e091b672c4bbbbf6bc4f6694c475d127ffa21eb' as 'tree2'
    |\ \ \
    | | |/
    | |/|
    | * | 0e091b6 Squashed 'tree2/' content from commit 08c7421
    | /
    * | 07b77e7 Merge commit 'cd2b30a0229d931979ed4436b995875ec563faea' as 'tree1'
    |\ \
    | |/
    | * cd2b30a Squashed 'tree1/' content from commit 08c7421
    * 64eeaa6 (origin/master, origin/HEAD) O HAI FREND

This was from a minimal case. Subtree history (when viewed this way at least)
gets unreasonably ugly fast. Subrepo history, by contrast, always looks as
clean as shown. There is one clone/pull commit, and one merge per operation.
Both commits are needed because it the clone/pull commit is stored under the
'former' key in the .gitrepo file, which affects the SHA1 value of the commit.
By adding the file to the *merge* commit, this becomes possible.

The final command, push, is slightly more complicated. Effectively, it tries to
extract (checkout) the changes made to the subdirectory, rebase them with the
upstream, and push the resulting history back. It does not squash the commits
made locally, because it assumed that when you changed the local subrepo, you
made messages that were intended to eventually be published back upstream.

Here are the steps:

* Fetch the remote content.
* Filter out the local subdir changes into an "local subrepo branch".
* Remove the .gitrepo state file from the subrepo history.
* Graft the local subrepo history in the remote history.
* Rebase the local changes on top of the remote ones.
* Push the new history upstream.
* Reset local HEAD to the point before the command was run.
* Delete the subrepo branch.

Automatic pushing is a bit tricky because you need to account for merge
failures. That's why there is also an 'checkout' command that does everything
above except for the merge and push parts. I won't explain it here (read the
doc), but basically it lets you do the merge part by hand.

## Side-by-Side Comparison

Hopefully by now, you see that submodules are a painful choice with a dubious
future, and that subtree, while a solid idea has many usage issues. In this
final section I'll compare/contrast common usage of working with external
repos, using these commands.

To keep the lingo clear, I'll use the term "External" to mean the general
concept of an external repo that might e used as a submodule, subtree or
subrepo.

### Adding a new External

As an owner or collaborator, you have decided to add a new External to your
repo:

Submodule:
    git submodule add git@github.com/user/external

Subtree:
    git subtree --squash --prefix=external git@github.com/user/external

Subrepo:
    git subrepo clone git@github.com/user/external

### Updating from a changed External

### Pushing External changes upstream

### Moving/Renaming an External

### Making an External on a branch

### Changing the tracking branch of an External

### Removing an External

## Reference Links

* http://longair.net/blog/2010/06/02/git-submodules-explained/
* http://blogs.atlassian.com/2013/05/alternatives-to-git-submodule-git-subtree/
