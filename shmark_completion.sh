#!/bin/bash __this-file-should-be-sourced-not-run__
##############################################################################
#
# shmark_completion.sh - Bash completions for shmark
#
# Copyright (c) 2014-2016 Steve Wheeler
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of shmark nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
##############################################################################
#
# @date    2016-03-15 Last modified
# @date    2014-01-27 First version
# @version @@VERSION@@
# @author  Steve Wheeler
#
##############################################################################

[ -n "$BASH_VERSION" ] || return    # bash required

_shmark() {
    local cur prev completions i

    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    local -r options="-f -h -V"

    # List of commands generated by running:
    #
    #   echo $(shmark -h | sed -En 's/^    ([^ ]+).*/\1/p' | sed 's/\|/ /g')
    #
    local -r commands="\
        add a append app cd go cd go chcat cc chcat cc del rm del rm \
        edit ed env help index idx insert ins list ls listall lsa \
        listcat lsc listdir lsd listunsort lsus move mv print shorthelp undo"

    # Total number of bookmarked directories:
    local -r list_total=$( shmark lsd | wc -l )
    # List position numbers for bookmarked directories:
    local -r indices=$(echo \
        $(for ((i=1; i<=$list_total; i++))
          do echo $i; done)
    )
    # Same as $indices, but with a leading dash, e.g., -2
    local -r index_flags=$(sed 's/[0-9]\{1,\}/-&/g' <<< "$indices")

    case ${prev} in
        cd|go|del|rm)
            # This COMPREPLY needs to be dynamically generated to
            # complete full directory paths for the current word:
            COMPREPLY=( $( shmark listdir | grep ".*${cur}.*" ) )
            return 0
            ;;
        add|a|append|app|chcat|cc)
            # These take a category as their first argument.
            completions=$( shmark listcat )
            COMPREPLY=( $( compgen -W "${completions}" -- ${cur} ) )
            return 0
            ;;
        insert|ins|move|mv)
            # 'insert' and 'move' take a list position number argument.
            COMPREPLY=( $( compgen -W "${indices}" -- ${cur} ) )
            return 0
            ;;
    esac

    if [ $COMP_CWORD -eq 1 ]; then  # this is the first arg
        if [[ ${cur} =~ ^-[1-9][0-9]*$ ]]; then  # number flags
            COMPREPLY=( $( compgen -W "${index_flags}" -- ${cur} ) )
        elif [[ ${cur} == -* ]]; then            # other flags
            COMPREPLY=( $( compgen -W "${options}" -- ${cur} ) )
        else                                     # all other args
            COMPREPLY=( $( compgen -W "${commands}" -- ${cur} ) )
        fi
    elif [ $COMP_CWORD -gt 2 ]; then
        case ${COMP_WORDS[COMP_CWORD-2]} in
            chcat|cc)
                # The second argument for 'chcat' (after a category
                # argument; actual third argument to shmark) is a
                # directory (or a list position) so the COMPREPLY needs to
                # be dynamically generated to complete full directory paths
                # for the current word:
                COMPREPLY=( $( shmark listdir | grep ".*${cur}.*" ) )
                ;;
            move|mv)
                # Both arguments for 'move' are list position numbers.
                COMPREPLY=( $( compgen -W "${indices}" -- ${cur} ) )
                ;;
        esac
    fi

    return 0
}

complete -F _shmark shmark  # main function

