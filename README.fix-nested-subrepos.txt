Background:
==========
	Have a tree of ~270 nested subrepos of various levels

                 top
				  |
				 subrepo0 -- top
				      |
					import
				 /       |         \
              subreop1 subreop2 .. subrepo140
		          |
		        import    ...
				 /    \
			sibreopo141 ..


		checkout time for all files of the 'top' subrepo is about 20 min

Issues found:
============

   1. 'subrepo branch' for the top of the nested subrepos creates a tree which includes nested subrepos and pushes them tot he
   	  origin

   2. 'subrepo bfanch' created nested references which just do not work in case of the multiple branches in existence.
      e.g.: error: cannot lock ref 'refs/heads/subrepo/s1': 'refs/heads/subrepo/s1/s5/s6' exists; cannot create 'refs/heads/subrepo/s1'

   3. '--tree-filter' used int the branch filtering is veeeery slow. My initial experinent of creating a branch for 'subrepo0' took
   	  52 hours.

   4. 'multiple commands are missing the --ALL' qualifier


Bugs found:
==========

    1. Worktree was not cleaned at subrepo:branch. It was causing issues in push --ALL if some branches already existed.

	2. test/branch-rev-list-one-path.t failed internittently

	3. encoding did not catch single '@' correclty, causing worktree creation to fail, at least in git 2.22

Features change:
===============

    1. git 2.22 message letter casing was changed from 'Couldn't find remote ref' to 'couldn't find remote ref'.


Added changes:
=============
	1. Added feature to clean nested subrepo in the filter-branch

	2. flattened names of nested branches by replaceing '/' with '-'

	3. Added extra checking for the updates done to the nested subrepos only. It checks updated files against the nested subrepo regex
	   -- found a code which created EMPTY commits, which looked like a leftower from debugging. It stayed in the way and I
	      commented it out. Did not affect any test.
	   -- it reduced number of revisions needed for subrepo0 in my initial case from 268 to 4 :-) 

	4. Replaced --tree-filter with --index-filter in soc:branch. For different subrepos performance was improved 2x to 10x.
	   -- found a git issue, probably related to the tree size. It crashed in filter-branch with `xrealloc(-1ULL)`. I did not
	   	investigate it further. This happened to the top subrepo with 268 revisions. It worked with 4 (from above) and took onlly 7
		min to finish (vs 52 hours initially)

		-- aded the '--use_tree_filter' qualifier to allow old --tree-filter in case of git issues.

    5. added the --squash_branch (-S) feature to the branch, push, pull, and fetch commands. It causes subrepo:branch to squash all commits into
       one with combined log. This was initially done for performance reasons
		
	6. fixed found bugs and updated features.

	   -- added --ALL to 'branch', 'clean', 'fetch', 'pull', and 'push'
	   -- added --topo-order to 'rev-list' in subrepo:branch. This makes git reporting consistent and it looks like
	      branch-rev-list-one-path.t  passes consistently now
	   -- claned 'wortree' in subrepo:branch before checking for existense fo the branch
	   -- added checking of non-prefixed branch names to the encoding. It was ok for branches but not ok for worktrees. Now
	      worktree seems to work.
	   -- fixed message regex to handle both, capitalized and non-capitalized veresion of the '[Cc]ouldn't'

    7. added nested.t test to check both regular and squashed branches.


		
