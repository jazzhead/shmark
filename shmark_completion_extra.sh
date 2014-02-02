#!/bin/bash __this-file-should-be-sourced-not-run__
##############################################################################
#
# Optional extra completions for shmark
#
# @date    2014-02-01 Last modified
# @date    2014-01-28 First version
# @version @@VERSION@@
# @author  Steve Wheeler
#
# This file includes examples of custom completions that can be defined for
# shmark() and its helper functions.
#
# To use, source this file after sourcing shmark.sh, shmark_extra.sh and
# shmark_completion.sh. Or, you can write your own custom completions and
# aliases. Both the shmark_extra.sh and shmark_completion_extra.sh files
# were split into separate files so that they could be easily customized or
# replaced without affecting the main shmark.sh and shmark_completion.sh
# files.
#
##############################################################################

[ -n "$BASH_VERSION" ] || return    # bash required

# === ALIASES ===

# Enable completions for any custom aliases or functions that call shmark().
# This example enables completions for the 'bm' alias defined in
# 'shmark_extra.sh.

# 'bm' alias to 'shmark()' defined in 'shmark_extra.sh.'
complete -F _shmark bm


# === ACTION COMPLETIONS ===

# All of the shmark commands (actions) can be accessed from the main
# shmark() function and completions are enabled for all of them with the
# main _shmark() completion function. Additionally, the individual action
# functions can be accessed directly so that short aliases can be defined
# for commonly used shmark actions.
#
# This example creates a completion function for the 'shmark cd' action. A
# completion is then defined for a 'go' command which is an alias to
# _shmark_cd() defined in the optional shmark_extra.sh file. To set up
# completions for other individual shmark actions, refer to the main
# _shmark() completion function to extract the completion code for that
# action.

_shmark_complete_cd() {
    local cur

    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"

    if [ $COMP_CWORD -eq 1 ]; then  # this is the first arg
        # This COMPREPLY needs to be dynamically generated to
        # complete full directory paths for the current word:
        COMPREPLY=( $( shmark listdir | grep ".*${cur}.*" ) )
    fi
    return 0
}

# 'go' alias to '_shmark_cd()' defined in 'shmark_extra.sh.'
complete -F _shmark_complete_cd go
