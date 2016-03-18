#!bash

# Enable git-subrepo completion facilities
if [[ -n ${BASH_VERSION-} ]]; then
  # Bash
  if [[ $(type -t __gitcomp 2> /dev/null) != function ]]; then
    # The standard Git completion script for Bash does not seem to be
    # loaded, because its shell function `__gitcomp`, which our Bash
    # completion script uses, does not appear to exist.
    {
      # Look for the Git completion script at the file-paths whereat it
      # might be found, according to
      # <https://github.com/git/git/blob/4109c28/contrib/completion/git-completion.zsh#L34-L36>
      # and experimental and anecdotal evidence.
      for f in \
        /{usr,opt/local}/share/bash-completion/{completions/,}git \
        {,/usr/local,~/.homebrew}/etc/bash_completion.d/git
      do
        # If a file is found at the location being checked…
        if [[ -f $f ]]; then
          # …source it.
          source $f
          [[ $(type -t __gitcomp) != function ]] &&
            echo "WARNING: Git completion script '$f' does not provide a '__gitcomp' function"
          # Proceed to loading our Bash completion facilities.
          break
          # We could instead `break` only if `source $f` succeeds, or if
          # `$f` provides a `__gitcomp` function, but that would entail
          # plowing ahead to the next potential Git completion script if
          # this one errors partway through being sourced, possibly
          # resulting in an inconsistent mishmash of Git completion scripts.
        fi
      done
    } || {
      # If no file was found at any of the potential file-paths checked
      # above, source a bundled copy of
      # <https://github.com/git/git/blob/c285171/contrib/completion/git-completion.bash>.
      source "$GIT_SUBREPO_ROOT/share/git-completion.bash"
    }
  fi
  # Load our Bash completion facilities.
  source "$GIT_SUBREPO_ROOT/share/completion.bash"
elif [[ -n ${ZSH_VERSION-} ]]; then
  # Zsh
  #
  # Prepend to `fpath` the path of the directory containing our zsh
  # completion script, so that our completion script will be hooked into the
  # zsh completion system.
  fpath=($GIT_SUBREPO_ROOT/share/zsh-completion $fpath)
fi
