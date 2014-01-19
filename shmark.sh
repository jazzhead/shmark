#!/bin/bash
##############################################################################
#
# shmark - Categorized shell directory bookmarking for Bash
#
# Copyright (c) 2014 Steve Wheeler
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
# @date    2014-01-18 First version
# @author  Steve Wheeler
#
# TODO: A script can't change an interactive shell's directory. So this entire
#       script will need to be converted into a file of functions that can be
#       sourced. The Bash completion code will move to this file as well.
#       For now, I'll keep it as a script while I write all the functions so I
#       can have more robust error-checking and also so I don't have to keep
#       closing shells and starting new ones. <2014-01-18 00:23:59>
#
##############################################################################

set -o nounset  # (set -u) Treat unset variables as error and exit script
set -o errexit  # (set -e) Exit if any command returns a non-zero status
set -o pipefail # Return non-zero status if any piped commands fail

SHMARK_VERSION="@@VERSION@@"

#: ${SHMARK_FILE:=bookmarks.example}
: ${SHMARK_FILE:=~/Desktop/test.noindex/bookmarks}

[[ -f "$SHMARK_FILE" ]] || touch "$SHMARK_FILE" || {
    echo >&2 "Couldn't create a bookmarks file at '$SHMARK_FILE'"
    kill -SIGINT $$
}

: ${SHMARK_DEFAULT_ACTION:=}

# == UTILITY FUNCTIONS ==

_shmark_oneline_usage() {
    echo "shmark [-hV] [-#] [action] [bookmark|category]"
}

_shmark_help() {
    cat <<-___EndHelp___

NAME
    shmark - Categorized shell directory bookmarking for Bash

SYNOPSIS
    $(_shmark_oneline_usage)

DESCRIPTION
    Save directory bookmarks and quickly go to any saved directory. Type a
    partial path name followed by tab and shmark will complete the path
    for any saved bookmarks.

    The bookmarks can be assigned a category when saving so that bookmarks
    are presented in groups when listing. Some examples of category names
    might be "@CURRENT", "@NEXT" or "@PENDING" for GTD-style categories,
    and "RECENT" or "MISC" for others.

    A default action (see the list of actions below) can be declared by setting
    a SHMARK_DEFAULT_ACTION environment variable, usually in .bash_profile.
    If a default is declared, it will be run when the function is called with
    no arguments. An example of declaring a default action:

        export SHMARK_DEFAULT_ACTION=list

ACTIONS
    c|cd|g|go [BOOKMARK|-#]
        Go (cd) to the specified bookmarked directory. The directory can
        be specified by its full path (available with tab completion from
        a partially typed path) or by specifying the bookmark's list
        position prefixed with a hyphen, e.g., '-2'. The list position can
        be found using the 'shmark list' command.

    s|save [CATEGORY]
        Bookmark the current directory. An optional category can be
        assigned. If a bookmark for the current directory already exists
        in the bookmarks file, it will be deleted before the new bookmark
        is added. This is an easy way to change the category for the
        bookmark.

    l|ls|list
        Show a list of saved bookmarks. This is the default if no argument
        is given. Bookmarks are listed by category and are prefixed by
        their list index number. (Note that the list index number is not
        the same as the line number in the actual file. The index number
        is assigned after the directories have been sorted by category.)

    dir
        Show just the bookmarked directories without the categories or
        list index numbers. This action is mainly used internally, but it
        might be useful for passing to external commands. Note that the
        directories are still sorted by category the same way they are
        with the 'list' action. If unsorted directies are needed, use the
        'unsorted_dir' action instead.

    unsorted_dir
        Similar to the 'dir' action except that the directories are not
        sorted by category and are instead listed in the same order as in
        the bookmarks file. Like the 'dir' action, this action is mainly
        available for use with any external command that might want the
        data.

    p|print
        Print the raw, unformatted bookmark file.

    d|delete [BOOKMARK|-#]
        Delete the specified directory bookmark from the bookmarks file.
        The directory can be specified by its full path (available with
        tab completion from a partially typed path) or by specifying the
        bookmark's list position prefixed with a hyphen, e.g., '-2'. The
        list position can be found using the 'shmark list' command.

    u|undo
        Undo the last edit to the bookmarks file. There is only one level
        of undo. Running 'undo' again will redo the last edit.

    e|edit
        Open the bookmarks file in the default EDITOR.

    chcat CATEGORY [BOOKMARK|-#]
        Change the category of the specified bookmark. The directory can
        be specified by its full path (available with tab completion from
        a partially typed path) or by specifying the bookmark's list
        position prefixed with a hyphen, e.g., '-2'. The list position can
        be found using the 'shmark list' command.

        Tab completion can also be used for the CATEGORY.

OPTIONS
    -n              No line numbers. Don't output line numbers for lists.
    -h|--help       Display this help message.
    -V|--version    Print version information.
___EndHelp___
    return
}

_shmark_usage() {
    cat <<-___EndUsage___
Usage: $(_shmark_oneline_usage)
Try 'shmark -h' for more info.
___EndUsage___
    return 1
} >&2

_shmark_version() {
    cat <<___EndVersion___
shmark $SHMARK_VERSION
Copyright (c) 2014 Steve Wheeler

This program comes with ABSOLUTELY NO WARRANTY. It is free software
available under the terms of a BSD-style (3-clause) open source license.
Details are in the LICENSE file included with this distribution.
___EndVersion___
    return
}

_shmark_categories() {
    cut -d\| -f1 "$SHMARK_FILE" | sort -u
}

_shmark_list_parse() {
    local result
    result=$(sed -n "s!^$label\|\([^|]*\)\|.*!\1!p" "$SHMARK_FILE")
    if [[ $dir_only = 1 ]]; then
        echo "$result"
    else
        nl -s') ' -v $i -w4 <<< "$result"
    fi
}

_shmark_list_index() {
    [[ -s "$SHMARK_FILE" ]] || return
    sed "$1"'q;d' <<< "$(_shmark_dir)"
}

_shmark_find_line() {
    local dir
    if [[ "$1" =~ ^-[0-9]+$ ]]; then
        dir="$(_shmark_list_index ${1#-})"
    else
        dir="$1"
    fi
    fgrep -n -m1 "|${dir}|" "$SHMARK_FILE" | cut -d: -f1
}

# == ACTIONS ==

_shmark_cd() {
    #echo "DEBUG: ${FUNCNAME}(): $1"
    local dir
    if [[ "$1" =~ ^-[0-9]+$ ]]; then
        dir="$(_shmark_list_index ${1#-})"
    else
        dir="$1"
    fi
    #echo "DEBUG: ${FUNCNAME}(): $dir"
    cd "${dir/#~/$HOME}" && pwd && ls # NOTE: 'ls' is just for testing

    # TODO: Update 'last visited' field for directory in bookmark file.
}

_shmark_save() {
    # Output line format:  label|directory|creation date|last visited
    local label="$1" || return
    local dir="${PWD/#$HOME/~}"     # Replace home directory with tilde
    local curdate="$(date '+%F %T')"
    _shmark_delete "$dir"        # Delete old bookmark first if one exists
    echo "$1|$dir|$curdate|$curdate" >> "$SHMARK_FILE"
    echo >&2 "Bookmark saved for '$dir'."
}

_shmark_list() {
    local dir_only=${dir_only:-0}
    local i=1
    local n label result escaped_label
    local missing_label=0

    [[ -s "$SHMARK_FILE" ]] || return

    while read -r label; do
        if [[ -z "$label" ]]; then
            # Skip uncategorized bookmarks for now. Add them at the bottom.
            missing_label=1
            continue
        fi
        escaped_label=$(sed -E 's/[]\.*+?$|(){}[^]/\\&/g' <<< "$label")
        n=$(grep -c "^$escaped_label" "$SHMARK_FILE")
        [[ $dir_only -eq 1 ]] || echo "$label"
        _shmark_list_parse
        i=$((i + n))
    done <<< "$(_shmark_categories)"

    # Now add any uncategorized bookmarks using a default label
    if [[ $missing_label -eq 1 ]]; then
        label=""
        [[ $dir_only -eq 1 ]] || echo "MISCELLANEOUS"
        _shmark_list_parse
    fi
}

_shmark_dir() {
    local dir_only=1
    _shmark_list
}

_shmark_unsorted_dir() {
    cut -d\| -f2 "$SHMARK_FILE"
}

_shmark_print() {
    #awk -F\| '{ printf "%-10s%-50s%-20s%s\n",$1,$2,$3,$4}' "$SHMARK_FILE"
    cat "$SHMARK_FILE"
}

_shmark_delete() {
    local line_num=$(_shmark_find_line "$1")
    if [[ "$line_num" =~ ^[0-9]+$ ]]; then
        #echo >&2 "Deleting line $line_num from '$SHMARK_FILE'" # :DEBUG:
        cp -p ${SHMARK_FILE}{,.bak}
        printf '%s\n' "${line_num}d" . w | ed -s "$SHMARK_FILE" >/dev/null
        echo >&2 "Bookmark deleted."
    fi
}

_shmark_undo() {
    echo >&2 "Undoing last edit to the bookmarks file..."
    mv -f "${SHMARK_FILE}"{.bak,.tmp} # rename current backup as tmp
    mv -f "${SHMARK_FILE}"{,.bak}     # rename current file as new backup
    mv -f "${SHMARK_FILE}"{.tmp,}     # rename tmp file as new current file
}

_shmark_edit() {
    echo >&2 "TODO: ${FUNCNAME}()"
}

_shmark_chcat() {
    echo >&2 "TODO: ${FUNCNAME}()"
}

# == MAIN FUNCTION ==

shmark() {
    # Process options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -[0-9]*)
                if [[ "$1" =~ ^-[0-9]+$ ]]; then
                    #_shmark_list_index ${1#-} # :DEBUG:
                    _shmark_cd $1
                else
                    echo >&2 "Error: Bad option: $1"
                    _shmark_usage
                fi
                return
                ;;
            -h|--help)
                _shmark_help
                ;;
            -V|--version)
                _shmark_version
                ;;
            -\?)
                _shmark_usage
                ;;
            -*)
                echo >&2 "Error: Bad option: $1"
                _shmark_usage
                ;;
            *) # No more options; stop loop
                break
                ;;
        esac
    done

    # If no action is given, check for a default set in the environment
    local action=${1:-$SHMARK_DEFAULT_ACTION}

    [ -z "$action" ] && _shmark_usage

    # Process actions
    case "$action" in
        c|cd|g|go)  # go (cd) to bookmarked directory
            shift
            if [[ $# -eq 0 ]]; then
                echo >&2 "Error: The 'cd' action requires an argument."
                return
            fi
            _shmark_cd "$1"
            ;;

        s|save)     # save current directory as bookmark
            shift
            _shmark_save "${1:-}" # optional 'label' argument
            ;;

        l|ls|list)  # show categorized bookmarks list
            _shmark_list
            ;;

        dir)        # show just the bookmarked directories w/o labels & line #s
            _shmark_dir
            ;;

        unsorted_dir) # show unsorted bookmarked directories w/o labels/line #s
            _shmark_unsorted_dir
            ;;

        p|print)    # show raw bookmark file
            _shmark_print
            ;;

        d|delete)   # delete a bookmark
            shift
            if [[ $# -eq 0 ]]; then
                echo >&2 "Error: The 'delete' action requires an argument."
                return
            fi
            _shmark_delete "$1"
            ;;

        u|undo)     # undo the last edit to the bookmarks file
            _shmark_undo
            ;;

        e|edit)     # open bookmarks file in EDITOR
            _shmark_edit
            ;;

        chcat)      # Change the category of a bookmark
            shift
            if [[ $# -eq 2 ]]; then
                _shmark_chcat "$@"
            else
                echo >&2 "Error: The 'chcat' action requires two arguments."
                return
            fi
            ;;

        *)
            echo >&2 "Error: Unknown action: $action"
            _shmark_usage
            ;;
    esac
}

# == BASH COMPLETIONS ==

#_shmark() {
#    #printf >&2 "\n%s\n%s\n%s\n"\
#    #    "DEBUG: complete:_shmark():" "  \$1 = $1" "  \$2 = $2"
#
#    local cur prev opts
#    COMPREPLY=()
#    cur="${COMP_WORDS[COMP_CWORD]}"
#    prev="${COMP_WORDS[COMP_CWORD-1]}"
#
#    COMPREPLY=( $( shmark dir | grep ".*$2.*" ) )
#}

#complete -F _shmark -o default shmark  # function
#complete -F _shmark -o default bm         # alias

shmark "$@" # DEBUG: For shell script debugging only. Not for function file.
