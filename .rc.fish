#!fish

#------------------------------------------------------------------------------
#
# This is the `git-subrepo` initialization script.
#
# This script turns on the `git-subrepo` Git subcommand and its manpages for the
# *Fish* shell.
#
# It does not currently offer TAB completion.
#
# Just add a line like this to your shell startup configuration.
# Usually found in: ~/.config/fish/config.fish
#
#   source /path/to/git-subrepo/.rc.fish
#
#------------------------------------------------------------------------------

set GIT_SUBREPO_ROOT (cd (dirname (status -f)); and pwd)

# TODO: Consider using the `--universal` flag, might get rid of the need for sourcing this file on every start.
set -gx PATH $GIT_SUBREPO_ROOT/lib $PATH
set -gx MANPATH $GIT_SUBREPO_ROOT/man $MANPATH
