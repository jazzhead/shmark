#!/bin/bash __this-file-should-be-sourced-not-run__
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
# @date    2014-01-30 Last modified
# @date    2014-01-18 First version
# @version @@VERSION@@
# @author  Steve Wheeler
#
##############################################################################

[ -n "$BASH_VERSION" ] || return    # bash required

SHMARK_VERSION="@@VERSION@@"


## ==== SETUP ================================================================

# Assign a null value if the bookmark file variable is undefined:
: ${SHMARK_FILE:=}

# If null, use a default value:
if [[ -z "$SHMARK_FILE" ]]; then
    if [[ -d "${HOME}/var/shmark" ]]; then
        # Avoid creating another dot file/dir if an alternate has been set up
        SHMARK_FILE="${HOME}/var/shmark/bookmarks"
    else
        # Default to creating a dot directory
        SHMARK_FILE="${HOME}/.shmark/bookmarks"
        [[ -d "${HOME}/.shmark" ]] || mkdir -m0700 "${HOME}/.shmark" || {
            echo >&2 "Couldn't create directory at '${HOME}/.shmark'"
            kill -SIGINT $$
        }
    fi
fi

# Expand tilde for home directory path:
SHMARK_FILE="${SHMARK_FILE/#~/$HOME}"

# Create bookmarks file if one doesn't exist:
[[ -f "$SHMARK_FILE" ]] \
    || { touch "$SHMARK_FILE" && chmod 600 "$SHMARK_FILE" ; } \
    || { echo >&2 "Couldn't create a bookmarks file at '$SHMARK_FILE'"
         kill -SIGINT $$ ; }

#
# Check if any default environment variables have been defined. These
# environment variables can be set in .bash_profile or .bashrc. Make sure
# they are set before this functions file is sourced. If you change any of
# them after sourcing this file, then source the file again.
#
# The default action is used if shmark() is run without any action.
: ${SHMARK_DEFAULT_ACTION:=}
#
# The default category is used for any bookmarks that don't have a category.
# Note that this value is never written to the bookmarks file. If you change
# the value of this environment variable, that value will be used whenever
# uncategorized bookmarks are listed.
: ${SHMARK_DEFAULT_CATEGORY:=MISCELLANEOUS}

#echo "DEBUG: $SHMARK_FILE  (exiting early...)"; return 1


# ==== INFO FUNCTIONS ========================================================

# Help, usage, version. These functions are called by the main shmark()
# function and aren't meant to be called directly.

_shmark_oneline_usage() {
    echo "shmark [-hV] [-f bookmark_file] [-#] [action] [bookmark|category]"
}

_shmark_shorthelp() {
    cat <<___EndHelp___
Usage: $(_shmark_oneline_usage)

Actions:
$(_shmark_actions_help | egrep '^    [^ ]')

Try the "help" action for full details.
___EndHelp___
    return 0
}

_shmark_help() {
    cat <<-___EndHelp___

NAME
    shmark - Categorized shell directory bookmarking for Bash

SYNOPSIS
    $(_shmark_oneline_usage)

DESCRIPTION
    Save directory bookmarks and quickly go to any bookmarked directory.
    Type a partial path name then hit the tab key and shmark will
    complete the path for any bookmark.

    The bookmarks can be assigned a category when adding so that
    bookmarks are presented in groups when listing. Some examples of
    category names might be "@CURRENT", "@NEXT" or "@PENDING" for
    GTD-style categories, and "RECENT" or "MISC" for others.

    A default action (see the list of actions below) can be declared by
    setting a SHMARK_DEFAULT_ACTION environment variable, usually in
    .bash_profile. If a default is declared, it will be run when shmark
    is called with no arguments. An example of declaring a default
    action:

        export SHMARK_DEFAULT_ACTION=list

INSTALLATION
    This is a Bash functions file which should be sourced into your
    shell environment rather than run directly. See the included INSTALL
    file for full installation instructions.

OPTIONS
    -#
        Shortcut to go (cd) to a directory bookmark by its list position
        (available from the 'list' command). Just prefix the list
        position number (#) with a hyphen, e.g.:

            shmark -2

    -f bookmark_file
        Use the specified bookmark file instead of the configured file.

    -h|--help
        Display a brief help message (same as action "shorthelp").

    -V|--version
        Print version information.

ACTIONS
$(_shmark_actions_help)

BOOKMARKS FILE
    The bookmarks file is a plaintext file with each line representing a
    directory bookmark. Each bookmark consists of four pipe-delimited
    fields:

        category|directory|date added|last visited

    For example:

        @CURRENT|~/Desktop/foo|2014-01-17 19:12:40|2014-01-17 19:12:40

    The 'last visited' field is updated each time the 'cd' (or 'go')
    action is used to change to a bookmarked directory. Both date fields
    are updated whenever the 'add', 'append' or 'insert' actions are
    used on a directory.

ENVIRONMENT VARIABLES
    Some environment variables can be set that will affect the operation
    of shmark. Export any of the available variables from .bash_profile,
    .bashrc or another startup file. For these environment variables to
    take effect, make sure the shmark.sh file is sourced after any of
    the variables have been exported. Available environment variables:

        SHMARK_FILE=FILE                   same as option -f FILE
        SHMARK_DEFAULT_ACTION=""           run this when called with no args
        SHMARK_DEFAULT_CATEGORY="MISC..."  use for uncategorized bookmarks

    To see the current values for shmark environment variables, run
    'shmark env'
___EndHelp___
    return 0
}

_shmark_actions_help() {
    cat <<-___EndHelp___
    add|a [CATEGORY]
        Bookmark the current directory. An optional CATEGORY can be
        assigned. If a bookmark for the current directory already exists
        in the bookmarks file, it will be deleted before the new
        bookmark is added. This is an easy way to change the category
        for the bookmark and/or promote it to the top of its category.

        If the CATEGORY is omitted, the bookmark will appear under a
        default category of MISCELLANEOUS which is always listed as the
        last category. To change the name of that default category,
        export an environment variable with the desired category name,
        for example:

            export SHMARK_DEFAULT_CATEGORY=Archive

        Bookmarks are added to the beginning of the bookmarks file so
        the most recently added bookmark will be listed as the first in
        its category. To add a bookmark as the very last in its
        category, use the 'append' command. To insert a bookmark at a
        specific list position, use the 'insert' command. All bookmarks
        are grouped by category in the output of the 'list' command.

    append|app [CATEGORY]
        Similar to the 'add' command except that the bookmark is added
        to the bottom of the bookmarks file instead of the top. So a
        bookmark that is "appended" will be listed as the last in its
        category. A bookmark that is "added" will be listed as the first
        in its category. All bookmarks are grouped by category in the
        output if the 'list' command.

    cd|go BOOKMARK
    cd|go NUMBER
        Go (cd) to the specified directory BOOKMARK. The bookmarked
        directory can be specified by its full path (available with tab
        completion from a partially typed path) or by specifying the
        bookmark's list position NUMBER. The list position can be found
        using the 'list' action.

        A shortcut to go to a bookmark by its list position is to just
        prefix the list position NUMBER with a hyphen without using the
        'cd' or 'go' keywords, e.g.:

            shmark -2

    chcat|cc CATEGORY BOOKMARK
    chcat|cc CATEGORY NUMBER
        Change the CATEGORY of the specified BOOKMARK. The bookmarked
        directory can be specified by its full path (available with tab
        completion from a partially typed path) or by specifying the
        bookmark's list position NUMBER. The list position can be found
        using the 'list' action.

        Tab completion can also be used for the CATEGORY.

    del|rm BOOKMARK
    del|rm NUMBER
        Delete the specified directory BOOKMARK from the bookmarks file.
        The bookmarked directory can be specified by its full path
        (available with tab completion from a partially typed path) or
        by specifying the bookmark's list position NUMBER. The list
        position can be found using the 'list' action.

    edit|ed
        Open the bookmarks file in the default EDITOR.

    env
        Show the values for any shmark environment variables that have
        been set.

    help
        Display detailed help.

    insert|ins LIST_POSITION
        Insert a bookmark for the current directory at a specific list
        position. List positions can be found in the output of the
        'list' action. The bookmark currently occupying the target list
        position as well as any bookmarks following it will all be
        pushed down one position.

        A bookmark can be appended to the end of the list by giving a
        list position that is greater than the last position, but the
        'append' command is made specifically for appending.
        Additionally, the 'append' command can append to specific
        categories rather than only the last listed category.

    list|ls
        Show a list of saved bookmarks. Bookmarks are listed by category
        and are prefixed by their list index number. (Note that the list
        index number is not the same as the line number in the actual
        file. The index number is assigned after the directories have
        been sorted by category.) Uncategorized bookmarks are not
        included in the list. Use 'listall' to see a list of all
        bookmarks including those that are uncategorized.

    listall|lsa
        Like 'list', but include uncategorized bookmarks. Uncategorized
        bookmarks are listed after all other categories using a default
        category, which is "MISCELLANEOUS" unless customized by setting
        and exporting a SHMARK_DEFAULT_CATEGORY environment variable.

    listcat|lsc
        Show a list of bookmark categories used in bookmarks file.

    listdir|lsd
        Show just the bookmarked directories without the categories or
        list index numbers. This action is mainly used internally, but
        it might be useful for passing to external commands. Note that
        the directories are still sorted by category the same way they
        are with the 'list' action. If unsorted directories are needed,
        use the 'listunsort' action instead.

    listunsort|lsus
        Similar to the 'listdir' action except that the directories are
        not sorted by category and are instead listed in the same order
        as in the bookmarks file. Categories and list index numbers are
        not shown. Like the 'listdir' action, this action is mainly
        available for use with any external command that might want the
        data.

    print
        Print the raw, unformatted bookmark file. The lines are prefixed
        with a line number (line numbers are not in the actual bookmarks
        file).

    shorthelp
        List brief usage for all command actions (same as -h).

    undo
        Undo the last edit to the bookmarks file. There is only one
        level of undo. Running 'undo' again will redo the last edit.
___EndHelp___
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
    return 0
}


# ==== MAIN FUNCTION =========================================================

##
# This function is the primary interface that calls all the other functions.
#
# @param $1 (string)  Option or command (action)
# @param $2 (str|int) Category, bookmark or list position depending on command
# @param $3 (str|int) The 'chcat' command takes a bookmark or list position arg
# @return   Exit status: 0=true, >0=false
shmark() {
    #echo >&2 "DEBUG: ${FUNCNAME}(): running..."

    # Process options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -[1-9]*)
                if [[ "$1" =~ ^-[1-9][0-9]*$ ]]; then
                    _shmark_cd ${1#-}
                else
                    echo >&2 "Error: Bad option: $1"
                    _shmark_usage
                fi
                return $?
                ;;
            '-#')
                printf >&2 "%s\n" \
                    "Error: Bad option: $1" \
                    "Were you trying to specify a list postion number? E.g.:" \
                    "" \
                    "    shmark -2" \
                    ""
                _shmark_usage
                return $?
                ;;
            -f)
                shift
                local file
                # Substitute home directory path for tilde:
                file="${1/#~/$HOME}"
                # Need an absolute path:
                [[ ${file:0:1} != '/' ]] && file="${PWD}/${file}"
                [[ -f "$file" ]] || touch "$file" || {
                    echo >&2 "Couldn't create a bookmarks file at '$file'"
                    kill -SIGINT $$
                }
                SHMARK_FILE="$file"
                unset file
                shift
                #echo "DEBUG: $SHMARK_FILE"; return 1
                ;;
            -h|--help)
                _shmark_shorthelp
                return $?
                ;;
            -V|--version)
                _shmark_version
                return $?
                ;;
            -\?)
                _shmark_usage
                return $?
                ;;
            -*)
                echo >&2 "Error: Bad option: $1"
                _shmark_usage
                return $?
                ;;
            *) # No more options; stop loop
                break
                ;;
        esac
    done

    # If no action is given, check for a default set in the environment
    local action=${1:-$SHMARK_DEFAULT_ACTION}

    if [ -z "$action" ]; then
        _shmark_usage
        return $?
    fi

    # Process actions
    case "$action" in
        cd|go           ) shift; _shmark_cd     "$@" ;;
        add|a           ) shift; _shmark_add    "$@" ;;
        append|app      ) shift; _shmark_append "$@" ;;
        insert|ins      ) shift; _shmark_insert "$@" ;;
        del|rm          ) shift; _shmark_delete "$@" ;;
        chcat|cc        ) shift; _shmark_chcat  "$@" ;;
        list|ls         ) _shmark_list               ;;
        listall|lsa     ) _shmark_listall            ;;
        listcat|lsc     ) _shmark_list_categories    ;;
        listdir|lsd     ) _shmark_listdir            ;;
        listunsort|lsus ) _shmark_listunsort         ;;
        print           ) _shmark_print              ;;
        undo            ) _shmark_undo               ;;
        env             ) _shmark_env                ;;
        edit|ed         ) _shmark_edit               ;;
        shorthelp       ) _shmark_shorthelp          ;;
        help)
            # If STDOUT is to a terminal (TTY), then try to pipe
            # the output to the PAGER (less by default):
            if [ -t 1 ]; then
                if which "${PAGER:-less}" >/dev/null 2>&1; then
                    _shmark_help | "${PAGER:-less}" && return 0
                fi
            fi
            # Fallback to STDOUT for redirection or pipes:
            _shmark_help
            ;;
        *)
            echo >&2 "Error: Unknown action: $action"
            _shmark_usage
            return $?
            ;;
    esac
}


# ==== ACTIONS ===============================================================

# These are the individual action functions called by the main shmark()
# function. They can also be called individually so that short aliases can be
# defined for individual functions. Example:  alias go='_shmark_cd'
#
# Separate Bash completions will need to be written/defined for any such
# shortcuts to enable completion for any of the functions that take arguments.
# A completions file is already available for the main shmark() function.
# Additionally, an extra completions file is available with an example
# completion for the _shmark_cd() function.

##
# Go (cd) to a bookmarked directory.
#
# @param  (str|int) Bookmarked directory or list position
# @return Exit status: 0=true, >0=false
_shmark_cd() {
    __shmark_check_file_var || return 1

    if [[ $# -eq 0 ]]; then
        echo >&2 "Error: The 'cd' action requires an argument."
        _shmark_usage
        return $?
    fi

    local dir absolute_path line_num bookmark

    # Get bookmark directory path (for searching bookmarks file):
    if [[ "$1" =~ ^[1-9][0-9]*$ ]]; then
        dir="$(__shmark_get_directory_from_list_index $1)"
    else
        dir="${1/#$HOME/~}" # HOME is replaced with tilde in bookmarks file
    fi

    # Need the absolute path (no tilde) for changing directories:
    absolute_path="${dir/#~/$HOME}"
    [[ -d "$absolute_path" ]] || {
        echo >&2 "Error: No such directory: '$dir'"
        return 1
    }

    # Go to the directory (and optionally pwd):
    cd "$absolute_path" || {
        echo >&2 "Error: Couldn't change to directory: '$dir'"
        return 1
    }
    echo >&2 "${PWD/#$HOME/~}"

    # Get line number for updating the bookmarks file:
    line_num=$(__shmark_get_line_number "$dir")
    [[ -n "$line_num" ]] || return 0

    # Update the directory's 'last visited' field in the bookmarks file:
    bookmark=$(sed $line_num'q;d' "$SHMARK_FILE") || return 0
    if [ -n "$bookmark" ]; then
        bookmark=$(__shmark_update_last_visited "$bookmark")
        __shmark_replace_line $line_num "$bookmark"
    fi

    return 0
}

##
# Add a directory bookmark to the top of a category.
#
# @param  (string) Optional category for bookmark
# @return Exit status: 0=true, >0=false
_shmark_add() {
    __shmark_check_file_var || return 1

    local curdir="${PWD/#$HOME/~}"     # Replace home directory with tilde

    local bookmark="$(__shmark_prepare_new_bookmark "$@")"
    [[ -z "$bookmark" ]] && return 1

    printf '%s\n' 0a "$bookmark" . w | ed -s "$SHMARK_FILE"
    echo >&2 "Bookmark added for '$curdir'."
}

##
# Append a directory bookmark to the bottom of a category.
#
# @param  (string) Optional category for bookmark
# @return Exit status: 0=true, >0=false
_shmark_append() {
    __shmark_check_file_var || return 1

    local curdir="${PWD/#$HOME/~}"     # Replace home directory with tilde

    local bookmark="$(__shmark_prepare_new_bookmark "$@")"
    [[ -z "$bookmark" ]] && return 1

    echo "$bookmark" >> "$SHMARK_FILE"
    echo >&2 "Bookmark appended for '$curdir'."
}

##
# Insert a directory bookmark at a specific list position.
#
# @param  (integer) List position for insertion
# @return Exit status: 0=true, >0=false
_shmark_insert() {
    __shmark_check_file_var || return 1

    local target_list_pos="${1:-}"
    local ed_cmd=
    local line_total=$(echo $(wc -l < "$SHMARK_FILE"))
    local np=$((line_total + 1)) # 'np' = "next position" - need short var for:
    local default_errmsg=$( printf "%s\n" \
        "Error: The 'insert' action requires a number argument chosen" \
        "       from the bookmarks list. To append as the last bookmark," \
        "       use ${np}; otherwise, use a number 1-${line_total}."
    )
    local line_num list_pos msg

    # Get the target list postion:
    if [[ -z "$target_list_pos" ]]; then
        # Handle a missing argument by prompting for a number:
        msg=$( printf "%s\n" \
            "" \
            "> Enter a list position where the bookmark should be inserted." \
            "> To append as the last bookmark, use ${np}; otherwise, use a" \
            "> number 1-${line_total}: "
        )
        while true; do
            _shmark_list >&2
            read -p "$msg" list_pos
            [[ "$list_pos" =~ ^[1-9][0-9]*$ ]] && break
        done
    else
        # Make sure a list position argument from the command line is a
        # number and that the number is not zero:
        __shmark_validate_num "$target_list_pos" "$default_errmsg" \
            || return $?
        list_pos="$target_list_pos"
    fi

    # If the list position number is greater than the bookmark total, that
    # means append the new bookmark as the very last bookmark.
    if [[ $list_pos -gt $line_total ]]; then
        # Need the list position for the current last bookmark so we can look
        # up its actual line number and then find out what its category is.
        list_pos=$line_total
        # The 'ed' command for appending (`a`) after the last line (`$`).
        ed_cmd='$a'
    fi

    # Find out the line number in the bookmarks file for the bookmark at
    # this list position.
    line_num=$(__shmark_get_line_number "$list_pos")

    # Now check that the line number is a number and is not zero:
    __shmark_validate_num "$line_num" "$default_errmsg" || return $?

    # Need category of bookmark currently occupying target list position
    local category=$(awk -F\| 'NR=='$line_num' {print $1}' "$SHMARK_FILE")
    local curdir="${PWD/#$HOME/~}"     # Replace home directory with tilde
    local curdate="$(date '+%F %T')"

    #printf >&2 "DEBUG: ${FUNCNAME}(): %s\n" \
    #    "line_total = $line_total" \
    #    "list_pos   = $list_pos" \
    #    "line_num   = $line_num" \
    #    "category   = $category" \
    #    "curdir     = $curdir"
    #echo >&2 "DEBUG: ${FUNCNAME}(): exiting early..."; return 1

    # If there is already an existing bookmark for the current directory,
    # find its line number before deleting it.
    local cur_line_num=$(__shmark_get_line_number "$curdir")
    if [ -n "$cur_line_num" ]; then
        # Find the list position of the old bookmark (so we can adjust the
        # target position if neccesary after deleting the old bookmark):
        local cur_list_pos=$(__shmark_get_list_index_from_directory "$curdir")
        # Delete the old bookmark:
        local delete_msg="Old bookmark deleted."
        local should_report_failure=0  # set to 1 for debugging
        _shmark_delete "$cur_list_pos"
        # If the line number for the old bookmark was less than the target
        # line number, decrement both the target line number (to reflect the
        # new target number) and the line total:
        (( cur_line_num < line_num )) && (( line_num--, line_total-- ))
        # If the old bookmark list position was above the target list
        # position, then decrement the target postion:
        (( cur_list_pos < list_pos )) && (( list_pos-- ))
    fi
    #printf >&2 "DEBUG: ${FUNCNAME}(): %s\n" \
    #    "line_total = $line_total" \
    #    "list_pos   = $list_pos" \
    #    "line_num   = $line_num" \
    #    "category   = $category" \
    #    "curdir     = $curdir"

    # If we don't have an 'ed' command yet, that means we're inserting:
    [[ -z "$ed_cmd" ]] && ed_cmd="${line_num}i"

    #echo >&2 "DEBUG: ${FUNCNAME}(): ed_cmd   = $ed_cmd"

    # Output line format:  category|directory|date added|last visited
    local bookmark="$category|$curdir|$curdate|$curdate"

    #echo >&2 "DEBUG: ${FUNCNAME}(): exiting early..."; return 1

    printf '%s\n' "$ed_cmd" "$bookmark" . w | ed -s "$SHMARK_FILE"
    echo >&2 "Bookmark for '$curdir' inserted into bookmarks file."
}

##
# Delete a bookmark.
#
# @param (str|int) Bookmarked directory path or its list position
# @return Exit status: 0=true, >0=false
_shmark_delete() {
    __shmark_check_file_var || return 1

    if [[ $# -eq 0 ]]; then
        echo >&2 "Error: The 'delete' action requires an argument."
        _shmark_usage
        return $?
    fi

    local delete_msg="${delete_msg:-Bookmark deleted.}"
    local should_report_failure="${should_report_failure:-1}"
    local line_num=$(__shmark_get_line_number "$1")
    if [[ "$line_num" =~ ^[1-9][0-9]*$ ]]; then
        cp -p ${SHMARK_FILE}{,.bak}
        if [[ $(wc -l < "$SHMARK_FILE") -eq 1 ]]; then
            # 'ed' seemingly can't delete all lines from a file, so just
            # redirect nothing to overwrite the file contents if there is only
            # one line remaining:
            > "$SHMARK_FILE"
        else
            printf '%s\n' "${line_num}d" . w | ed -s "$SHMARK_FILE" >/dev/null
        fi
        echo >&2 "$delete_msg"
        return 0
    else
        if [[ "$should_report_failure" -eq 1 ]]; then   # direct 'delete' call
            echo >&2 "Error: Couldn't find line to delete for '$1'"
        else               # called from 'add' or 'insert' function, so backup
            cp -p ${SHMARK_FILE}{,.bak}
        fi
        return 1
    fi
}

##
# Change the category of a bookmark.
#
# @param $1 (string)  Category to use
# @param $2 (str|int) Bookmarked directory path or its list position
# @return   Exit status: 0=true, >0=false
_shmark_chcat() {
    __shmark_check_file_var || return 1

    if [[ $# -ne 2 ]]; then
        echo >&2 "Error: The 'chcat' action requires two arguments."
        _shmark_usage
        return $?
    fi

    local category="$1"
    local line_num=$(__shmark_get_line_number "$2")
    local errmsg=$( printf "%s\n" \
        "Error: The 'chcat' action requires two arguments: a category and" \
        "       either a bookmark directory path or a number chosen from" \
        "       the bookmarks list." \
        "Usage: shmark chcat CATEGORY BOOKMARK|NUMBER"
    )

    __shmark_validate_num "$line_num" "$errmsg" || return $?

    bookmark=$(sed $line_num'q;d' "$SHMARK_FILE")   # get existing bookmark
    bookmark=$(__shmark_update_category "$bookmark" "$category") # update it
    __shmark_replace_line $line_num "$bookmark"     # replace it in the file

    return 0
}

_shmark_edit() {
    __shmark_check_file_var || return 1

    local editor=${EDITOR-vi}
    echo >&2 "Editing bookmarks file (${SHMARK_FILE/#$HOME/~})..."
    $editor "$SHMARK_FILE"
}

_shmark_list() {
    __shmark_check_file_var || return 1

    local listall=${listall:-0}
    local dir_only=${dir_only:-0}
    local i=1
    local n category result escaped_category
    local missing_category=0
    local include_blank_categories=1

    [[ -s "$SHMARK_FILE" ]] || return

    while read -r category; do
        if [[ -z "$category" ]]; then
            # Skip uncategorized bookmarks for now. Add them at the bottom.
            missing_category=1
            continue
        fi
        escaped_category=$(sed -E 's/[]\.*+?$|(){}[^-]/\\&/g' <<< "$category")
        n=$(grep -c "^$escaped_category" "$SHMARK_FILE")
        [[ $dir_only -eq 1 ]] || echo "$category"
        __shmark_format_list_items $dir_only $i "$category"
        i=$((i + n))
    done <<< "$(_shmark_list_categories)"

    # Now add any uncategorized bookmarks using a default category
    if [[ $missing_category -eq 1 ]]; then
        if [[ $listall -eq 1 || $dir_only -eq 1 ]]; then
            category=""
            [[ $dir_only -eq 1 ]] || echo "$SHMARK_DEFAULT_CATEGORY"
            __shmark_format_list_items $dir_only $i "$category"
        fi
    fi
}

_shmark_list_categories() {
    __shmark_check_file_var || return 1

    local include_blank_categories=${include_blank_categories=-0}
    local categories=$(cut -d\| -f1 "$SHMARK_FILE" | sort -u)
    if [[ "$include_blank_categories" -eq 1 ]]; then
        echo "$categories"
    else
        grep -v '^$' <<< "$categories"
    fi
}

_shmark_listall() {
    local listall=1
    _shmark_list
}

_shmark_listdir() {
    local dir_only=1
    _shmark_list
}

_shmark_listunsort() {
    __shmark_check_file_var || return 1

    cut -d\| -f2 "$SHMARK_FILE"
}

_shmark_print() {
    __shmark_check_file_var || return 1

    #awk -F\| '{ printf "%-10s%-50s%-20s%s\n",$1,$2,$3,$4}' "$SHMARK_FILE"
    #cat "$SHMARK_FILE"
    local width=$( echo $( printf $( wc -l < "$SHMARK_FILE" ) | wc -c ) )
    nl -w $width -s ') ' "$SHMARK_FILE"
}

_shmark_undo() {
    __shmark_check_file_var || return 1

    if [[ -f "${SHMARK_FILE}.bak" ]]; then
        echo >&2 "Undoing last edit to the bookmarks file..."
        mv -f "${SHMARK_FILE}"{.bak,.tmp} # rename current backup as tmp
        mv -f "${SHMARK_FILE}"{,.bak}     # rename current file as new backup
        mv -f "${SHMARK_FILE}"{.tmp,}     # rename tmp file as new current
    else
        echo >&2 "Couldn't undo. No previous backup file available."
    fi
}

_shmark_env() {
    local v
    printf "%s\n" "Current shmark environment variables:" ""
    for v in $(echo ${!SHMARK_@}); do
        printf "    %-25s = %s\n" $v "${!v/#$HOME/~}"
    done
    return 0
}


# ==== UTILITY FUNCTIONS (PRIVATE) ===========================================

# These functions are called by the other functions to perform various tasks
# and aren't meant to be called directly. They can be thought of as private
# functions and are identified with a double underscore (__) prefix.

##
# @param  (string) Optional category
# @return (string) Formatted bookmark
__shmark_prepare_new_bookmark() {
    local category="${1:-}"

    # $curdir is inherited from calling function.
    [[ -z "$curdir" ]] && return 1

    # Delete old bookmark first if one exists. Also makes a backup of the
    # bookmark file so don't make another backup in this function.
    local delete_msg="Old bookmark deleted."
    local should_report_failure=0
    _shmark_delete "$curdir" || true  # continue regardless

    # Output line format:  category|directory|date added|last visited
    local curdate="$(date '+%F %T')"
    echo "$category|$curdir|$curdate|$curdate"
}

##
# @param $1 (integer) Bool 1=true, 0=false. Should only directories be returned?
# @param $2 (integer) Starting list postition number
# @param $3 (string)  Bookmark category
# @return   (string)  Formatted list items
__shmark_format_list_items() {
    __shmark_check_file_var || return 1

    if [[ $# -ne 3 ]]; then
        echo >&2 "Error: '$FUNCNAME()' requires three arguments."
        echo >&2 "Usage: $FUNCNAME DIR_ONLY(int) IDX(int) CATEGORY(str)"
        return 1
    fi
    local dir_only=$1
    local idx=$2
    local category="$3"
    local result width formatted line

    # Find lines with matching category:
    result=$(sed -n "s!^$category\|\([^|]*\)\|.*!\1!p" "$SHMARK_FILE")

    if [[ $dir_only -eq 1 ]]; then
        echo "$result"
    else
        # Get the number of digits in the last line number:
        width=$( echo $(printf $(wc -l < "$SHMARK_FILE") | wc -c) )
        # Indent list items two spaces:
        width=$(( width + 2 ))
        # Number the list items:
        formatted=$(nl -w $width -s ') ' -v $idx <<< "$result")
        # Wrap long lines:
        while IFS= read -r line; do
            __shmark_wrap_long_line 80 '/' "      " "$line"
        done <<< "$formatted"
    fi
}

##
# @param $1 (integer) Maximum line width
# @param $2 (string)  Delimiter for splitting line
# @param $3 (string)  Indent for wrapped lines (literal characters)
# @param $4 (string)  The line to wrap
# @return   (string)  Wrapped line
__shmark_wrap_long_line() {
    if [[ $# -ne 4 ]]; then
        echo >&2 "Error: '$FUNCNAME()' requires four arguments."
        echo >&2 \
            "Usage: $FUNCNAME WIDTH(int) DELIMITER(str) INDENT(str) LINE(str)"
        return 1
    fi
    local width="$1"      # maximum line width
    local delimiter="$2"  # delimiter for splitting line
    local indent="$3"     # indent for wrapped lines (literal characters)
    local line="$4"       # the line to wrap
    local wrapped_line=
    local tmp final_line segments item
    if [ ${#line} -gt $width ]; then
        while IFS=$delimiter read -ra segments; do
            for item in "${segments[@]}"; do
                if [ -n "$wrapped_line" ]; then
                    tmp="${wrapped_line}/$item"
                    if [ $(tail -1 <<< "$tmp" | tr -d '\n' | wc -c) -lt $width ]
                    then
                        wrapped_line="$tmp"
                    else
                        wrapped_line="${wrapped_line}/"$'\n'"${indent}${item}"
                    fi
                else
                    wrapped_line="$item"
                fi
                #echo DEBUG:; echo "$wrapped_line"
            done
            final_line="$wrapped_line"
        done <<< "$line"
    else
        final_line="$line"
    fi
    echo "$final_line"
}

##
# @param  (integer) List position
# @return (string)  Bookmarked directory path at given list position
__shmark_get_directory_from_list_index() {
    __shmark_check_file_var || return 1

    if [[ $# -ne 1 ]]; then
        echo >&2 "Error: '$FUNCNAME()' requires an integer argument."
        echo >&2 "Usage: $FUNCNAME INTEGER"
        return 1
    fi
    if [[ ! "$1" =~ ^[1-9][0-9]*$ ]]; then
        echo >&2 "Error: '$FUNCNAME()' requires an integer argument."
        echo >&2 "Usage: $FUNCNAME INTEGER"
        return 1
    fi
    [[ -s "$SHMARK_FILE" ]] || return
    sed "$1"'q;d' <<< "$(_shmark_listdir)"
}

##
# @param  (string) Bookmarked directory path
# @return (integer) List position of given bookmarked directory
__shmark_get_list_index_from_directory() {
    if [[ $# -ne 1 ]]; then
        echo >&2 "Error: '$FUNCNAME()' requires an argument."
        echo >&2 "Usage: $FUNCNAME DIRECTORY_PATH(str)"
        return 1
    fi
    _shmark_listdir | grep -n -m1 "^${1}$" | cut -d: -f1
}

##
# @param  (str|int) Directory path or its list position
# @return (integer) Line number in bookmarks file for given directory
__shmark_get_line_number() {
    __shmark_check_file_var || return 1

    if [[ $# -ne 1 ]]; then
        echo >&2 "Error: '$FUNCNAME()' requires an argument."
        echo >&2 "Usage: $FUNCNAME DIRECTORY_PATH|LIST_POSITION"
        return 1
    fi
    local dir
    if [[ "$1" =~ ^[1-9][0-9]*$ ]]; then
        dir="$(__shmark_get_directory_from_list_index $1)"
    else
        dir="${1/#$HOME/~}" # bookmarks file uses tildes for HOME
    fi
    fgrep -n -m1 "|${dir}|" "$SHMARK_FILE" | cut -d: -f1
}

##
# @param $1 (integer) Number to validate
# @param $2 (string)  Error message
# @return   Exit status: 0=true, >0=false
__shmark_validate_num() {
    if [[ $# -ne 2 ]]; then
        echo >&2 "Error: '$FUNCNAME()' requires two arguments."
        echo >&2 "Usage: $FUNCNAME NUM(int) ERROR_MESSAGE(str)"
        return 1
    fi
    local num="$1"
    local msg="$2"
    if [[ ! "$num" =~ ^[1-9][0-9]*$ ]]; then
        echo >&2 "$msg"
        echo >&2 ""
        _shmark_list >&2
        echo >&2 ""
        _shmark_usage
        return $?
    fi
}

##
# @param  (string) A directory bookmark line (pipe-delimited, four fields)
# @return (string) Updated bookmark with current date for last field
__shmark_update_last_visited() {
    if [[ $# -ne 1 ]]; then
        echo >&2 "Error: '$FUNCNAME()' requires an argument."
        echo >&2 "Usage: $FUNCNAME BOOKMARK_LINE(str)"
        return 1
    fi
    local line="$1"
    printf "%s|%s\n" "$(cut -d\| -f1-3 <<< "$line")" "$(date '+%F %T')"
    # Bookmark format:  category|directory|date added|last visited
}

##
# @param $1 (string) A directory bookmark line (pipe-delimited, four fields)
# @param $2 (string) New category
# @return   (string) Updated bookmark with new category as first field
__shmark_update_category() {
    if [[ $# -ne 2 ]]; then
        echo >&2 "Error: '$FUNCNAME()' requires two arguments."
        echo >&2 "Usage: $FUNCNAME BOOKMARK_LINE(str) CATEGORY(str)"
        return 1
    fi
    local line="$1"
    local category="$2"
    printf "%s|%s\n" "$category" "$(cut -d\| -f2-4 <<< "$line")"
    # Bookmark format:  category|directory|date added|last visited
}

##
# Replaces line in bookmarks file
#
# @param $1 (integer) Line number from bookmarks file
# @param $2 (string)  The replacement text (a formatted directory bookmark)
__shmark_replace_line() { # void
    __shmark_check_file_var || return 1

    if [[ $# -ne 2 ]]; then
        echo >&2 "Error: '$FUNCNAME()' requires two arguments."
        echo >&2 "Usage: $FUNCNAME LINE_NUM(int) BOOKMARK_LINE(str)"
        return 1
    fi
    local line_num="$1"
    local line="$2"
    cp -p ${SHMARK_FILE}{,.bak}
    printf '%s\n' "${line_num}c" "$line" . w |
    ed -s "$SHMARK_FILE" >/dev/null
}

##
# Check if the SHMARK_FILE variable is set.
#
# @return   Exit status: 0=true, >0=false
__shmark_check_file_var() {
    #unset SHMARK_FILE  # DEBUG 'set -o nounset (set -u)'
    if [[ -z "${SHMARK_FILE:+1}" ]]; then
        cat <<-__EOF__ >&2
			Error: The SHMARK_FILE environment variable is not set. It
			  probably got unset at some point. If you exported a custom
			  location, try exporting it again and then sourcing 'shmark.sh'
			  to reset it. Otherwise, just source 'shmark.sh' again.
		__EOF__
        return 1
    fi
    return 0
}

