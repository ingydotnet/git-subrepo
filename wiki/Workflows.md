## Git merge
To better understand the difference in between git and git-subrepo we start with describing a merge in git.

```
    D - E topic
  /      
A - B - C master
```
```
$ git checkout master
$ git merge topic
```
```
    D - E topic
  /       \
A - B - C - F master
```
The next time you merge you can rely on the previous parents created.
```
    D - E - G - H topic
  /       \
A - B - C - F - I master
```
```
$ git checkout master
$ git merge topic
```
```
    D - E - G - H topic
  /       \       \
A - B - C - F - I - J master
```
In the example above it will use E as the common ancestor between H and I.

## git-subrepo pull
As described in [Advanced](Advanced) git-subrepo depends on finding ancestry through content tree hashes. By using this the actual parent connections are not stored explicitly.
```
#10,a - #20,b - #30,c subrepo
#10,a - #20,b - #30,c subrepo/fetch
#41,a - #51,d - #61,e project/subrepo/branch
#40,A - #50,D - #60,E project
``` 
in the case above we find that #10 and #41 have equal tree hash and then it's used as common ancestor. We apply the changes on our project/subrepo/branch onto subrepo/fetch.
```
#10,a - #20,b - #30,c subrepo
#10,a - #20,b - #30,c - #52,d' - #62,e' subrepo/fetch
#41,a - #51,d - #61,e project/subrepo/branch
#40,A - #50,D - #60,E project
``` 
Then apply that onto our project branch again
```
#10,a - #20,b - #30,c subrepo
#10,a - #20,b - #30,c - #52,d' - #62,e' subrepo/fetch
#41,a - #51,d - #61,e project/subrepo/branch
#40,A - #50,D - #60,E - #63,E' project
```
As you see, the actual subrepo is still left intact. To "simplify" the next example we rename E' => F, in our project it's a new commit and we don't want to add extra ' in the example.
If we decide to move on without pushing our changes, the next pull will look like this
```
#10,a - #20,b - #30,c - #70,h subrepo
#10,a - #20,b - #30,c - #70,h  subrepo/fetch
#41,a - #51,d - #61,e - #64,f - #81,g project/subrepo/branch
#40,A - #50,D - #60,E - #63,F - #80,G project
```
As you see here the common ancestor is still a based (#10, #41), so when we rebase everything 


## Pull only
If you only intend to 

Describe the different workflows
* Pull only
* Pull-push
* Local changes