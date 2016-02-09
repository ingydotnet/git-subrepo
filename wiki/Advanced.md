On this page we will try to explain a little more in detail how git-subrepo works. The examples here are based on what we created in the [Basics](Basics) page.

## Note
The descriptions below does not include all implementation details. If you want the full monty, you need to open the source code. This is just to describe the concepts and give you a good understanding of the main parts of git-subrepo.

## Internals
In regular git you have a graph where every node in the graph knows of its parents. Based on the graph you can find out common ancestors and use this for merging and rebasing. Read more about this on [Git documentation](https://git-scm.com/docs/)

The main problem that git-subrepo tries to solve is to compare a subrepo repository with a partial repository. As all commit hashes are based on both content and parents they can't be used in this case to find ancestors. 

In git there is also a tree hash that is based on content only. This can be used to find out if two commits are at least similar in content. If we print out the hash and the corresponding tree hash for our /tmp/shared/
```
$ cd /tmp/shared
$ git log --pretty=format:%H:%T
d7721ef4afad14e549b5714b49c18a8576b3f03e:6115f88b566c079a4934fcbb1893ba6ea46d3760
76edeecc13cf16bdb3fbe09225c8fd48452dd3fd:a6ed13d8eee5f96a6f00b8f390dff09759c50188
4b4ed1f3963771f6becf7a035e2917208457cf7e:3d087d282c29528e1aa8fe9dffee65142845f903
d8246fa3d1df2f9a0fef2b2b486003a41c2d6de4:20d0cce11701bcab9a3ab4baf8e1ab6b845a2b34
58e908c601bfb346fad0bd639d78415474db0ffd:ea41dba10b54a794284e0be009a11f0ff3716a28
```

And also for our /tmp/project
```
$ cd /tmp/project
$  git log --pretty=format:%H:%T
8eab0448436729de89d659f413ebedcdf34f2b84:6206c803d1e110f75fd3352b288b2c34f46fe78a
0468d4081300b8c2bce657c8145c7a353decbc85:0924d8450f172023e4ebb9f85d46f04511e26201
e58906879f85bee65b7e448a4034b60ef789e428:910c1535c0503ce3165e45361ff756485ecaadf9
c9b9003621c75dca6636a1ed5c8ad5663b255016:a592bd78e25317811ed8f178c5f85b2fa241da07
0a6dceb7f0d97b690db5338d5a4d6016ca9548f6:1b36e06119b7378629cb947431d2fa279ec9a314
b228b44453645162664ccaea8a4ab210ec33df66:c8b86188bde90614f60f3953679026fe651300ab
```

We see that none of the commit hashes or tree hashes are equals. That is because our subrepo is only part of the project repository and the tree hash is based on the entire content. To get to a state where you can compare tree hashes we use `git filter-branch --subdirectory-filter` to create a temporary version. We also remove the .gitrepo file as it will not be present in the subrepo.

```
$ cd /tmp/project
$ git filter-branch -f --subdirectory-filter shared
Rewrite 8eab0448436729de89d659f413ebedcdf34f2b84 (4/4) (0 seconds passed, remaining 0 predicted)    
Ref 'refs/heads/master' was rewritten
$ git filter-branch -f --prune-empty --tree-filter "rm -f .gitrepo"
Rewrite 943e80c38174e56ee6018b0e9a9df4c3e2b06484 (4/4) (0 seconds passed, remaining 0 predicted)    
Ref 'refs/heads/master' was rewritten
```

So now we can check at the tree hashes again.

```
$ cd /tmp/shared
$ git log --pretty=format:%H:%T
d7721ef4afad14e549b5714b49c18a8576b3f03e:6115f88b566c079a4934fcbb1893ba6ea46d3760   #1.1 = 2.1
76edeecc13cf16bdb3fbe09225c8fd48452dd3fd:a6ed13d8eee5f96a6f00b8f390dff09759c50188
4b4ed1f3963771f6becf7a035e2917208457cf7e:3d087d282c29528e1aa8fe9dffee65142845f903
d8246fa3d1df2f9a0fef2b2b486003a41c2d6de4:20d0cce11701bcab9a3ab4baf8e1ab6b845a2b34
58e908c601bfb346fad0bd639d78415474db0ffd:ea41dba10b54a794284e0be009a11f0ff3716a28   #1.2 = 2.2

$ cd /tmp/project
$ git log --pretty=format:%H:%T
c8dc7cbbeb5819ff8ab9876578267ff82da01769:6115f88b566c079a4934fcbb1893ba6ea46d3760   #2.1 = 1.1
fbc118f495e6142373028b9f11e5205cc9faebf0:36bf4b39b551393d28a9cceb2a018ff1879e4019
83ccd589cee354f475c863ec1a6bd61efed58305:b46188214de22570d0edee2a053970f5f3179caf
4acbf09e997c600b13b8436a2436dfc595d35981:ea41dba10b54a794284e0be009a11f0ff3716a28   #2.2 = 1.2
```

Based on this fact we can use this to our advantage and create virtual graphs between separate repositories.

## Tools
git-subrepo have a number of low level commands to help out with the operations described above.

### git subrepo merge-base
Takes two branches and compare tree hashes. Returns first common ancestor based on tree hashes. Due to duplicates in tree hashes, it will always return the first unique tree hash found on both branches.

### git subrepo fetch
Fetch the subrepo repository into the current repository

### git subrepo branch
Perform the filter-branch operations on the local repository and create a new branch with the outcome. This new branch is the local version of the subrepo.

### git subrepo commit
Commit the content of a branch to the local repository. Update .gitrepo file.

## git subrepo pull
So to perform a `git subrepo pull` we use the tools above with some regular git commands. 
```
#Commit hash,Tree hash
Capital letters are project tree hash, letters are shared tree hash
shared:   #1,a - #2,b - #3,c      
project:  #4,A - #5,D

git subrepo fetch => shared/fetch
# shared/fetch: #1,a - #2,b - #3,c
git subrepo branch => shared/branch
# shared/branch: #41,a - #51,d
git subrepo mergebase shared/fetch shared/branch => new_parent: #1, old_parent: #41
git rebase --onto new_parent old_parent shared/branch
# shared/fetch: #1,a - #2,b - #3,c
# shared/branch: #1,a - #51,d
git rebase shared/fetch shared/branch
# shared/fetch: #1,a - #2,b - #3,c - #52,d'
git subrepo commit
# project: #4,A - #5,D - #6,D'
```

As with any merging/rebasing there can be conflicts in these steps that you need to solve.

## git subrepo push
The push is essentially the same steps as in pull but you can't push a repository unless you have recently pulled in the latest changes. And the final commit step is replaced with a `git push` to push up the changes to the subrepo.