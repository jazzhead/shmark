#!/bin/bash __this-file-should-be-sourced-not-run__
##############################################################################
#
# Optional aliases for 'shmark()' and individual shmark actions.
#
# @date    2014-01-28 Last modified
# @date    2014-01-27 First version
# @version @@VERSION@@
# @author  Steve Wheeler
#
# Completions will need to be defined for these as well. Completions are
# already defined for these two examples in the 'shmark_extra_completion.sh'
# file.
#
# To use, source this file after sourcing shmark.sh. To enable completions,
# after sourcing this file, source shmark_completion.sh and
# shmark_extra_completion.sh. Both the shmark_extra.sh and
# shmark_extra_completion.sh files were split into separate files so that
# they could be easily customized or replaced without affecting the main
# shmark.sh and shmark_completion.sh files.
#
# Instead of using this file, you could just define your own aliases in your
# .bash_profile or .bashrc file, or in another file like this that you source.
# Completions will need to be defined for any of your custom aliases. See the
# shmark_extra_completion.sh file for examples.
#
##############################################################################

# Shortcut for use with all shmark actions and options.
alias bm='shmark'

# Shortcut to the shmark 'cd' (or 'go') action:
alias go='_shmark_cd'
