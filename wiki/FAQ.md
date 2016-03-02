# Create a subrepo from a folder in old/existing work, for use in other projects (i.e. split from git subtree)

First cd into your local copy of that work.

Now we create a subrepo of that work, then create a branch for that subrepo:
```<bash>
$ git subrepo init <subdir>
$ git subrepo branch <subdir>
$ git branch
* master
  subrepo/<subdir>    <--This is the branch containing <subdir> and all its history
```

That branch can be pushed/pulled wherever you need.

Instead of putting `<subdir>` into its own branch as shown above, you may put the `<subdir>` into a remote repo/branch:
```<bash>
$ git subrepo init <subdir> [-r <remote>] [-b <branch>]
$ git subrepo push <subdir>
```

Do whichever makes the most sense for your `<subdir>`.

To push changes you've made back to that old project, you may either use `git push`, `git subrepo push`, `git subrepo pull` depending on the context.