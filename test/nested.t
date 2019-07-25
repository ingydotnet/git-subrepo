#!/usr/bin/env bash

set -e

source test/setup

use Test::More


#clone-foo-and-bar

#subrepo-clone-bar-into-foo

curdir=$PWD

export GIT_AUTHOR_DATE="Wed Feb 16 14:00 2037 +0100"
export GIT_AUTHOR_NAME="John Doe"
export GIT_AUTHOR_EMAIL="jain@doe.com"

setup-nested-repo() {
	workdir="$OWNER/nested"
	if [ -e $workdir ]; then rm -rf $workdir; fi
	
	mkdir -p $workdir
	cd $workdir
	workdir=$PWD

	for n in {1..6}; do
		cd $workdir
		
		mkdir -p s$n.ws
		cd s$n.ws
		git init
		date > f$n.txt
		git add f$n.txt
		git commit -m "added f$n.txt to s$n.ws"
		cd -
		git clone -q --bare s$n.ws s$n.git
	done
	
	cd $workdir
	mkdir -p subrepos
	cd subrepos
	git init
	date > top.txt
	git add top.txt
	git commit -m "added top.txt to top"

	for n in {1..3}; do
		git subrepo clone ../s$n.git s$n
	done
	for n in {4..5}; do
		git subrepo clone ../s$n.git s1/s$n
	done

	git subrepo clone ../s6.git s1/s5/s6

	echo "workdir: $PWD"
}

setup-nested-repo

#before="$(date -r $workdir/subrepos '+%s')"

  cd $workdir/subrepos/s2
  add-new-files s2.txt
  cd $workdir/subrepos/s1
  add-new-files s1.txt
  cd $workdir/subrepos/s1/s4
  add-new-files s4.txt
  cd $workdir/subrepos/s1/s5/s6
  add-new-files s6.txt


is "$(
  cd $workdir/subrepos
  git subrepo branch --ALL
 )"\
  "Created branch 'subrepo/s1' and worktree '.git/tmp/subrepo/s1'.
Created branch 'subrepo/s1-s4' and worktree '.git/tmp/subrepo/s1-s4'.
Created branch 'subrepo/s1-s5' and worktree '.git/tmp/subrepo/s1-s5'.
Created branch 'subrepo/s1-s5-s6' and worktree '.git/tmp/subrepo/s1-s5-s6'.
Created branch 'subrepo/s2' and worktree '.git/tmp/subrepo/s2'.
Created branch 'subrepo/s3' and worktree '.git/tmp/subrepo/s3'."\
  "branches created correctly"

# Make sure that time stamps differ
#sleep 1

# is "$(
#   cd $workdir/subrepos
#   git push s2
# )" \
#   "Created branch 'subrepo/bar' and worktree '.git/tmp/subrepo/bar'." \
#   "subrepo branch command output is correct"


#after="$(date -r $OWNER/foo/Foo '+%s')"
#assert-original-state $OWNER/foo bar

# Check that we haven't checked out any temporary files
#is "$before" "$after" \
#  "No modification on Foo"

test-exists "$workdir/subrepos/.git/tmp/subrepo/s1/"
test-exists "$workdir/subrepos/.git/tmp/subrepo/s2/"
test-exists "$workdir/subrepos/.git/tmp/subrepo/s3/"
test-exists "$workdir/subrepos/.git/tmp/subrepo/s1-s4/"
test-exists "!$workdir/subrepos/.git/tmp/subrepo/s1/s4/"
test-exists "$workdir/subrepos/.git/tmp/subrepo/s1-s5-s6/"

test-exists "$workdir/subrepos/.git/refs/heads/subrepo/s1"
test-exists "$workdir/subrepos/.git/refs/heads/subrepo/s2"
test-exists "$workdir/subrepos/.git/refs/heads/subrepo/s3"
test-exists "$workdir/subrepos/.git/refs/heads/subrepo/s1-s4"
test-exists "!$workdir/subrepos/.git/refs/heads/subrepo/s1/s4"
test-exists "$workdir/subrepos/.git/refs/heads/subrepo/s1-s5-s6"

cd $workdir/subrepos
git subrepo clean --ALL
is "$(cd $workdir/subrepos; git subrepo push --ALL)" \
    "Subrepo 's1' pushed to '../s1.git' (master).
Subrepo 's1/s4' pushed to '../s4.git' (master).
Subrepo 's1/s5' has no new commits to push.
Subrepo 's1/s5/s6' pushed to '../s6.git' (master).
Subrepo 's2' pushed to '../s2.git' (master).
Subrepo 's3' has no new commits to push." \
	"subrepo push is done correctly"

cd $workdir/s1.ws
git pull -q ../s1.git
test-exists "s1.txt"
test-exists "f1.txt"
test-exists "!.gitrepo"
test-exists "!s3/"

cd $workdir/s2.ws
git pull -q ../s2.git
test-exists s2.txt

cd $workdir/s4.ws
git pull -q ../s4.git
test-exists "s4.txt"
test-exists "f4.txt"

cd $workdir/s6.ws
git pull -q ../s6.git
test-exists "s6.txt"


#########################
## check branch squasning
#########################
subrepos=$workdir/subrepos

cd $subrepos/s1/s5
add-new-files sq5-1.txt
add-new-files sq5-2.txt
add-new-files sq5-3.txt

cd $subrepos/s1
add-new-files sq1-1.txt

cd $subrepos

is "$(git subrepo branch -S -F -f s1)" \
   "Created branch 'subrepo/s1' and worktree '.git/tmp/subrepo/s1'." \
   "Squashed subrepo branch s1 created"


is "$(git log --format="%b" subrepo/s1 | grep -v -P '===|merged:|commit:|version:')" \
   'Author: John Doe
Email:  jain@doe.com
Date:   Mon Feb 16 14:00:00 2037 +0100

git subrepo push s1

subrepo:
  subdir:   "s1"
upstream:
  origin:   "../s1.git"
  branch:   "master"
git-subrepo:
  origin:   "https://github.com/ingydotnet/git-subrepo.git"

Author: John Doe
Email:  jain@doe.com
Date:   Mon Feb 16 14:00:00 2037 +0100

add new file: sq1-1.txt' \
   "squashed branch s1 created correctly"


is "$(git subrepo branch -S -F -f s1/s5)" \
      "Created branch 'subrepo/s1-s5' and worktree '.git/tmp/subrepo/s1-s5'." \
   "Squashed subrepo branch s1/s5 created"

is "$(git log --format="%b" subrepo/s1-s5 | grep -v -P '===|merged:|commit:|version:')" \
   'Author: John Doe
Email:  jain@doe.com
Date:   Mon Feb 16 14:00:00 2037 +0100

git subrepo clone ../s5.git s1/s5

subrepo:
  subdir:   "s1/s5"
upstream:
  origin:   "../s5.git"
  branch:   "master"
git-subrepo:
  origin:   "https://github.com/ingydotnet/git-subrepo.git"

Author: John Doe
Email:  jain@doe.com
Date:   Mon Feb 16 14:00:00 2037 +0100

add new file: sq5-1.txt

Author: John Doe
Email:  jain@doe.com
Date:   Mon Feb 16 14:00:00 2037 +0100

add new file: sq5-2.txt

Author: John Doe
Email:  jain@doe.com
Date:   Mon Feb 16 14:00:00 2037 +0100

add new file: sq5-3.txt' \
 	"branch s1/s5 created correctly"


git subrepo clean s1
#do not clean s5

is "$(git subrepo push --ALL -S)" \
   "Subrepo 's1' pushed to '../s1.git' (master).
Subrepo 's1/s4' has no new commits to push.
Subrepo 's1/s5' pushed to '../s5.git' (master).
Subrepo 's1/s5/s6' has no new commits to push.
Subrepo 's2' has no new commits to push.
Subrepo 's3' has no new commits to push." \
   "Push -ALL with branch squashig was done correctly"


done_testing

teardown


