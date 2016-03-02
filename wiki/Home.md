## Content
If you want a simple example of how git-subrepo is used, start with the [Basics](Basics).

To dig deeper into git-subrepo, you can check out [Advanced](Advanced). Note that the [Advanced](Advanced) page is based in operations performed in [Basics](Basics) so you can go back there for further information.

## Notations
In the examples the following things can be found:
Regular git flows are described with capital letters as commits (as in the git documentation).
For git-subrepo operations we use groups #10,A and #10,a where the first digit group is the commit hash. The second letter is the tree hash. Capital letters are project tree hash, lower case are subrepo tree hash. During the examples the first commit hash will change a lot, keeping the first digit indicates that it's rewritten.
An extra ' shows that the change has been rebased onto something else.
```
#10,A => #11,a   // subrepo branch command
#11,a => #12,a'  // internal subrepo rebase
```
In the example above, #12,a' is the rebased subrepo version of #10,A.