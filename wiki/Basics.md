# Basics

This will guide you through a simple example of how to use git-subrepo.

Start with installing git subrepo and make sure that you can run
```
$ git subrepo
usage: git subrepo <command> <arguments> <options>
...
```

Let us start with creating a new repository in the shared directory where we have our common files bar and foo.

```
$ cd /tmp/shared
$ git init
$ git add .
$ git commit -m "Initial revision of our shared code"
[master (root-commit) 58e908c] Initial revision of our shared code
 2 files changed, 0 insertions(+), 0 deletions(-)
 create mode 100644 bar
 create mode 100644 foo
```

Then we clone our project repository.

```
$ git clone /tmp/project_bare/ project
Cloning into 'project'...
done.
```

To use the shared repository as a subrepo inside the project.

```
$ cd /tmp/project
$ git subrepo clone /tmp/shared/ shared
Subrepo '../shared' (master) cloned into 'shared'.
$ git ls-files
alpha
beta
shared/.gitrepo
shared/bar
shared/foo
$ git log --pretty=oneline
0a6dceb7f0d97b690db5338d5a4d6016ca9548f6 git subrepo clone ../shared shared
b228b44453645162664ccaea8a4ab210ec33df66 Initial project commit
```

As you can see shared has been a part of the project repository, the only thing that tells us that there is a subrepo is the .gitrepo file. This file is used to store some subrepo essential information.

```
$ cat shared/.gitrepo 
[subrepo]
        remote = ../shared
        branch = master
        commit = 58e908c601bfb346fad0bd639d78415474db0ffd
        parent = b228b44453645162664ccaea8a4ab210ec33df66
        cmdver = 0.3.0
```

Now you can start to work on your project. 
```
$ touch delta
$ echo "123" >> shared/foo
$ git add .
$ git commit -m "Add delta, edit shared/foo"
[master c9b9003] Add delta, edit shared/foo
 2 files changed, 1 insertion(+)
 create mode 100644 delta
$ echo "abc" >> alpha
$ echo "def" >> beta
$ git add .
$ git commit -m "Edit alpha, beta"
[master e589068] Edit alpha, beta
 2 files changed, 2 insertions(+)
$ touch shared/fie
$ git add .
$ git commit -m "Add shared/fie"
[master 0468d40] Add shared/fie
 1 file changed, 0 insertions(+), 0 deletions(-)
 create mode 100644 shared/fie
$ git log --pretty=oneline
0468d4081300b8c2bce657c8145c7a353decbc85 Add shared/fie
e58906879f85bee65b7e448a4034b60ef789e428 Edit alpha, beta
c9b9003621c75dca6636a1ed5c8ad5663b255016 Add delta, edit shared/foo
0a6dceb7f0d97b690db5338d5a4d6016ca9548f6 git subrepo clone ../shared shared
b228b44453645162664ccaea8a4ab210ec33df66 Initial project commit
```

Some changes and new files. So far we have only worked in our local repository. To share our changes to others we perform a regular push.

```
$ git push
Counting objects: 11, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (8/8), done.
Writing objects: 100% (11/11), 890 bytes | 0 bytes/s, done.
Total 11 (delta 4), reused 0 (delta 0)
To /tmp/project_bare/
   0a6dceb..0468d40  master -> master
```

Now the changes are available to everyone working on the project repository. But if we look at our shared subrepo we will see that nothing has happened there.
```
$ cd /tmp/shared
$ git log --pretty=oneline
58e908c601bfb346fad0bd639d78415474db0ffd Initial revision of our shared code
```

Why? Because the subrepo will not update unless we specifically tell it to. Lets say that we add another file in the subrepo.
```
$ cd /tmp/shared
$ touch idle
$ git add .
$ git commit -m "Add idle"
[master d8246fa] Add idle
 1 file changed, 0 insertions(+), 0 deletions(-)
 create mode 100644 idle
$ echo "abde" >> bar
$ git add .
$ git commit -m "Edit bar"
[other 4b4ed1f] Edit bar
 1 file changed, 1 insertion(+)

$ git log --pretty=oneline
4b4ed1f3963771f6becf7a035e2917208457cf7e Edit bar
d8246fa3d1df2f9a0fef2b2b486003a41c2d6de4 Add idle
58e908c601bfb346fad0bd639d78415474db0ffd Initial revision of our shared code
$ git checkout -b other       # We need to step away from master if we want others to push changes here
Switched to a new branch 'other'
```

If we want to use this in our project, we need to update the subrepo.

```
$ cd /tmp/project
$ git subrepo pull shared
Subrepo 'shared' pulled from '../shared' (master).
$ git log --pretty=oneline
8eab0448436729de89d659f413ebedcdf34f2b84 git subrepo pull shared
0468d4081300b8c2bce657c8145c7a353decbc85 Add shared/fie
...
$ git ls-files
alpha
beta
delta
shared/.gitrepo
shared/bar
shared/fie
shared/foo
shared/idle
```

But wait, we have changes in our project repository that we want to get back into shared subrepo. As with regular git, you use push for this.

```
$ cd /tmp/project
$ git subrepo push shared
Subrepo 'shared' pushed to '../shared' (master).
$ cd /tmp/shared
$ git checkout master
$ git log --pretty=oneline
d7721ef4afad14e549b5714b49c18a8576b3f03e Add shared/fie
76edeecc13cf16bdb3fbe09225c8fd48452dd3fd Add delta, edit shared/foo
4b4ed1f3963771f6becf7a035e2917208457cf7e Edit bar
d8246fa3d1df2f9a0fef2b2b486003a41c2d6de4 Add idle
58e908c601bfb346fad0bd639d78415474db0ffd Initial revision of our shared code
```

Now lets compare the project and shared to see what has actually happened here. We start with a diff. 
```
$ diff /tmp/project/shared/ /tmp/shared/
Only in /tmp/shared/: .git
Only in /tmp/project/shared/: .gitrepo
```

It tells us that .git is only available in the shared, it will not be present in the project. The .gitrepo file is only present in the /tmp/project/shared/, as it stores data specific for the project usage of shared. 

If we use log and compare project and shared

```
$ cd /tmp/project
$ git log --pretty=oneline
8eab0448436729de89d659f413ebedcdf34f2b84 git subrepo pull shared             #1.1 includes 2.3, 2.4
0468d4081300b8c2bce657c8145c7a353decbc85 Add shared/fie                      #1.2 same as 2.1
e58906879f85bee65b7e448a4034b60ef789e428 Edit alpha, beta                    #1.3 no change in shared, ignored in 2
c9b9003621c75dca6636a1ed5c8ad5663b255016 Add delta, edit shared/foo          #1.4 same as 2.2
0a6dceb7f0d97b690db5338d5a4d6016ca9548f6 git subrepo clone ../shared shared
b228b44453645162664ccaea8a4ab210ec33df66 Initial project commit

$ cd /tmp/shared
$ git log --pretty=oneline
d7721ef4afad14e549b5714b49c18a8576b3f03e Add shared/fie                      #2.1 same as 1.2
76edeecc13cf16bdb3fbe09225c8fd48452dd3fd Add delta, edit shared/foo          #2.2 same as 1.4
4b4ed1f3963771f6becf7a035e2917208457cf7e Edit bar                            #2.3 included in 1.1
d8246fa3d1df2f9a0fef2b2b486003a41c2d6de4 Add idle                            #2.4 included in 1.1
58e908c601bfb346fad0bd639d78415474db0ffd Initial revision of our shared code
```
When you pull changes from a subrepo, changes will be squashed together into a single commit (2.3, 2.4 => 1.1)
When you push changes to a subrepo, relevant changes will transfer and appear in the subrepo (2.1, 2.2)
Commits that doesn't change things in a subrepo will be ignored (1.3)

If you want to know more how it actually works please read the [Advanced] section.