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
# @date    2014-05-23 Last modified
# @date    2014-01-18 First version
# @version @@VERSION@@
# @author  Steve Wheeler
#
##############################################################################

[ -n "$BASH_VERSION" ] || return    # bash required


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
        (available from the 'list' command). Use the list position
        number (#) with a leading hyphen (-), e.g.:

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
    action is used to change to a bookmarked directory.

ENVIRONMENT VARIABLES
    Some environment variables can be set that will affect the operation
    of shmark. Export any of the available variables from .bash_profile,
    .bashrc or another startup file. Available environment variables:

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
        are grouped by category in the output of the 'list' and
        'listall' commands.

    append|app [CATEGORY]
        Similar to the 'add' command except that the bookmark is added
        to the bottom of the bookmarks file instead of the top. So a
        bookmark that is "appended" will be listed as the last in its
        category. A bookmark that is "added" will be listed as the first
        in its category. All bookmarks are grouped by category in the
        output of the 'list' and 'listall' commands.

    cd|go [BOOKMARK]
    cd|go [NUMBER]
        Go (cd) to the specified directory BOOKMARK. The bookmarked
        directory can be specified by its full path (available with tab
        completion from a partially typed path) or by specifying the
        bookmark's list position NUMBER. The list position can be found
        using the 'list' or 'listall' actions.

        If a BOOKMARK or NUMBER argument is omitted, shmark will go to
        the first listed bookmark (position #1) by default.

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
        using the 'list' or 'listall' actions.

        Tab completion can also be used for the CATEGORY.

    del|rm BOOKMARK
    del|rm NUMBER
        Delete the specified directory BOOKMARK from the bookmarks file.
        The bookmarked directory can be specified by its full path
        (available with tab completion from a partially typed path) or
        by specifying the bookmark's list position NUMBER. The list
        position can be found using the 'list' or 'listall' actions.

    edit|ed
        Open the bookmarks file in the default EDITOR.

    env
        Show the values for any shmark environment variables that have
        been set.

    help
        Display detailed help.

    insert|ins NUMBER
        Insert a bookmark for the current directory at a specific list
        position NUMBER. List positions can be found in the output of
        the 'list' or 'listall' actions. The bookmark currently
        occupying the target list position as well as any bookmarks
        following it will all be pushed down one position.

        A bookmark can be appended to the end of the list by giving a
        list position that is greater than the last position (shown by
        the 'listall' command), but the 'append' command is made
        specifically for appending. Additionally, the 'append' command
        can append to specific categories rather than only the last
        listed category.

    list|ls [-#]
        Show a list of saved bookmarks. Bookmarks are listed by category
        and are prefixed by their list index number. (Note that the list
        index number is not the same as the line number in the actual
        file. The index number is assigned after the directories have
        been sorted by category.) Uncategorized bookmarks are not
        included in the list. Use 'listall' to see a list of all
        bookmarks including those that are uncategorized.

        Limit the number of bookmarks shown by supplying a number
        argument with a leading hyphen (-NUMBER) indicating the maximum,
        e.g.:

            shmark list -5

    listall|lsa [-#]
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

    move|mv FROM_POSITION TO_POSITION
        Move a bookmark from one list postion (number) to another. List
        positions can be found in the output of the 'list' or 'listall'
        actions. The bookmark currently occupying the target list
        position as well as any bookmarks following it will all be
        pushed down one position.

        A bookmark can be appended to the end of the list by giving a
        list position that is greater than the last position (shown by
        the 'listall' command), but the 'append' command is made
        specifically for appending. Additionally, the 'append' command
        can append to specific categories rather than only the last
        listed category.

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
    __shmark_setup_envvars
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
# @param $3 (str|int) 'chcat' and 'move' take an additional argument
# @return   Exit status: 0=true, >0=false
shmark() {
    #echo >&2 "DEBUG: ${FUNCNAME}(): running..."

    # Process options
    while [ $# -gt 0 ]; do
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
    #unset SHMARK_DEFAULT_ACTION  # DEBUG: test nounset
    : ${SHMARK_DEFAULT_ACTION:=}  # Handle 'set -o nounset'
    local action=${1:-$SHMARK_DEFAULT_ACTION}

    if [ -z "$action" ]; then
        echo >&2 "Error: An 'action' argument is required."
        _shmark_usage
        return $?
    fi

    # Process actions
    case "$action" in
        cd|go           ) shift; _shmark_cd      "$@" ;;
        add|a           ) shift; _shmark_add     "$@" ;;
        append|app      ) shift; _shmark_append  "$@" ;;
        insert|ins      ) shift; _shmark_insert  "$@" ;;
        move|mv         ) shift; _shmark_move    "$@" ;;
        del|rm          ) shift; _shmark_delete  "$@" ;;
        chcat|cc        ) shift; _shmark_chcat   "$@" ;;
        list|ls         ) shift; _shmark_list    "$@" ;;
        listall|lsa     ) shift; _shmark_listall "$@" ;;
        listcat|lsc     ) _shmark_listcat             ;;
        listdir|lsd     ) _shmark_listdir             ;;
        listunsort|lsus ) _shmark_listunsort          ;;
        print           ) _shmark_print               ;;
        undo            ) _shmark_undo                ;;
        env             ) _shmark_env                 ;;
        edit|ed         ) _shmark_edit                ;;
        shorthelp       ) _shmark_shorthelp           ;;
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
    __shmark_setup_envvars || return 1

    local dir absolute_path line_num bookmark

    # Get bookmark directory path (for searching bookmarks file):
    if [ $# -eq 0 ]; then
        # Default to first bookmark if no arg
        dir="$(__shmark_get_directory_from_list_index 1)"
    elif [[ "$1" =~ ^[1-9][0-9]*$ ]]; then
        dir="$(__shmark_get_directory_from_list_index $1)"
    else
        dir=${1/#$HOME/\~} # HOME is replaced with tilde in bookmarks file
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
    echo >&2 ${PWD/#$HOME/\~}

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
    __shmark_setup_envvars || return 1

    local curdir=${PWD/#$HOME/\~}     # Replace home directory with tilde

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
    __shmark_setup_envvars || return 1

    local curdir=${PWD/#$HOME/\~}     # Replace home directory with tilde

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
    __shmark_setup_envvars || return 1

    local target_list_pos="${1:-}"
    local ed_cmd=
    local line_total=$(echo $(wc -l < "$SHMARK_FILE"))
    local np=$((line_total + 1)) # 'np' = "next position" - need short var for:
    local default_errmsg=$( printf "%s\n" \
        "Error: The 'insert' action requires a number argument chosen" \
        "       from the bookmarks list. To append as the last bookmark," \
        "       use ${np}; otherwise, use a number 1-${line_total}."
    )
    local line_num list_pos msg bookmark

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
    if [ $list_pos -gt $line_total ]; then
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
    local curdir=${PWD/#$HOME/\~}     # Replace home directory with tilde

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
        bookmark=$(_shmark_delete "$cur_list_pos")

        # Update category for existing bookmark:
        bookmark=$(__shmark_update_category "$bookmark" "$category")

        # If the line number for the old bookmark was less than the target
        # line number, decrement both the target line number (to reflect the
        # new target number) and the line total:
        (( cur_line_num < line_num )) && (( line_num--, line_total-- ))

        # If the old bookmark list position was above the target list
        # position, then decrement the target postion:
        (( cur_list_pos < list_pos )) && (( list_pos-- ))
    else
        # New bookmark:
        local curdate="$(date '+%F %T')"
        bookmark="$category|$curdir|$curdate|$curdate"
    fi

    # If we don't have an 'ed' command yet, that means we're inserting:
    [[ -z "$ed_cmd" ]] && ed_cmd="${line_num}i"

    printf '%s\n' "$ed_cmd" "$bookmark" . w | ed -s "$SHMARK_FILE"
    echo >&2 "Bookmark for '$curdir' inserted into bookmarks file."
}

##
# Move a directory bookmark from one list position to another.
#
# @param $1 (integer) List position of bookmark to move
# @param $2 (integer) Target list position to move the bookmark
# @return Exit status: 0=true, >0=false
_shmark_move() {
    __shmark_setup_envvars || return 1

    local line_total=$(echo $(wc -l < "$SHMARK_FILE"))
    local np=$((line_total + 1)) # 'np' = "next position" - need short var for:
    local errmsg=$( printf "%s\n" \
        "Error: The 'move' action requires two number arguments chosen" \
        "       from the bookmarks list -- a source position and a target" \
        "       postition. To append as the last bookmark, use ${np} as the" \
        "       target postion; otherwise, use a number 1-${line_total}."
    )

    if [ $# -ne 2 ]; then
        echo >&2 "$errmsg"
        _shmark_usage
        return $?
    fi

    local from_list_pos="$1"
    local to_list_pos="$2"
    local ed_cmd=
    local from_line_num from_list_pos to_line_num to_list_pos

    # Make sure list position arguments are non-zero integers:
    __shmark_validate_num "$from_list_pos" "$errmsg" || return $?
    __shmark_validate_num "$to_list_pos" "$errmsg" || return $?

    # If the target list position number is greater than the bookmark total,
    # that means append the new bookmark as the very last bookmark.
    if [ $to_list_pos -gt $line_total ]; then
        # Need the list position for the current last bookmark so we can look
        # up its actual line number and then find out what its category is.
        to_list_pos=$line_total
        # The 'ed' command for appending (`a`) after the last line (`$`).
        ed_cmd='$a'
    fi

    # Find out the line numbers in the bookmarks file for the bookmarka at
    # these list positions:
    from_line_num=$(__shmark_get_line_number "$from_list_pos")
    to_line_num=$(__shmark_get_line_number "$to_list_pos")

    # Make sure the line numbers are non-zero integers:
    __shmark_validate_num "$from_line_num" "$errmsg" || return $?
    __shmark_validate_num "$to_line_num" "$errmsg" || return $?

    # Get existing bookmark w/o the category (fields 2-4):
    local bookmark=$(
        awk -F\| 'NR=='$from_line_num' {printf "%s|%s|%s",$2,$3,$4}' \
            "$SHMARK_FILE"
    )
    local directory=${bookmark%%|*} # just so we can report it

    # Need category of bookmark currently occupying target list position
    local category=$(awk -F\| 'NR=='$to_line_num' {print $1}' "$SHMARK_FILE")

    # Update bookmark with new category:
    bookmark="${category}|${bookmark}"

    # Delete the old bookmark:
    local delete_msg="Old bookmark deleted."
    local should_report_failure=0  # set to 1 for debugging
    _shmark_delete "$from_list_pos" >/dev/null

    # If the line number for the old bookmark was less than the target
    # line number, decrement both the target line number (to reflect the
    # new target number) and the line total:
    (( from_line_num < to_line_num )) && (( to_line_num--, line_total-- ))

    # If the old bookmark list position was above the target list
    # position, then decrement the target postion:
    (( from_list_pos < to_list_pos )) && (( to_list_pos-- ))

    # If we don't have an 'ed' command yet, that means we're inserting:
    [[ -z "$ed_cmd" ]] && ed_cmd="${to_line_num}i"

    printf '%s\n' "$ed_cmd" "$bookmark" . w | ed -s "$SHMARK_FILE"
    echo >&2 "Bookmark for '$directory' moved."
}

##
# Delete a bookmark.
#
# @param  (str|int) Bookmarked directory path or its list position
# @return (string)  The bookmark deleted (if any)
#         Exit status: 0=true, >0=false
_shmark_delete() {
    __shmark_setup_envvars || return 1

    if [ $# -eq 0 ]; then
        echo >&2 "Error: The 'delete' action requires an argument."
        _shmark_usage
        return $?
    fi

    local delete_msg="${delete_msg:-Bookmark deleted.}"
    local should_report_failure="${should_report_failure:-1}"
    local line_num=$(__shmark_get_line_number "$1")
    local bookmark
    if [[ "$line_num" =~ ^[1-9][0-9]*$ ]]; then
        cp -p ${SHMARK_FILE}{,.bak}
        bookmark=$(sed $line_num'q;d' "$SHMARK_FILE") # get existing bookmark
        if [ $(wc -l < "$SHMARK_FILE") -eq 1 ]; then
            # 'ed' seemingly can't delete all lines from a file, so just
            # redirect nothing to overwrite the file contents if there is only
            # one line remaining:
            > "$SHMARK_FILE"
        else
            printf '%s\n' "${line_num}d" . w | ed -s "$SHMARK_FILE" >/dev/null
        fi
        echo >&2 "$delete_msg"  # diagnostic message to STDERR -- not captured
        echo "$bookmark"        # old bookmark to STDOUT for capturing
        return 0
    else
        if [ "$should_report_failure" -eq 1 ]; then   # direct 'delete' call
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
    __shmark_setup_envvars || return 1

    if [ $# -ne 2 ]; then
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
    __shmark_setup_envvars || return 1

    local editor=${EDITOR-vi}
    local shortpath=${SHMARK_FILE/#$HOME/\~}  # Replace home dir with tilde
    echo >&2 "Editing bookmarks file ($shortpath)..."
    $editor "$SHMARK_FILE"
}

_shmark_list() {
    #unset SHMARK_FILE              # DEBUG 'set -o nounset (set -u)'
    #unset SHMARK_DEFAULT_CATEGORY  # DEBUG 'set -o nounset (set -u)'
    __shmark_setup_envvars || return 1

    local max=${1:--0}
    local listall=${listall:-0}     # inherit from calling function
    local dir_only=${dir_only:-0}   # inherit from calling function
    local i=1
    local n category result escaped_category list_items width
    local missing_category=0
    local include_blank_categories=1

    [[ -s "$SHMARK_FILE" ]] || return

    if [[ ! "$max" =~ ^-[0-9]+$ ]]; then
        echo >&2 "Error: The 'list' action takes an optional -NUM argument."
        _shmark_usage
        return $?
    fi

    max=${max#-} # don't need the dash anymore; just the integer

    # Get the number of digits in the last line number:
    width=$( echo $( wc -l < "$SHMARK_FILE" ) )
    width=${#width}

    while read -r category; do
        if [[ -z "$category" ]]; then
            # Skip uncategorized bookmarks for now. Add them at the bottom.
            missing_category=1
            continue
        fi
        escaped_category=$(sed -E 's/[]\.*+?$|(){}[^-]/\\&/g' <<< "$category")
        n=$(grep -c "^$escaped_category" "$SHMARK_FILE") # no. matching lines
        [ $dir_only -eq 1 ] || echo "$category"
        list_items=$(__shmark_format_list_items $dir_only $i $width \
            "$category")
        i=$(( i + n )) # the next list position
        if [ $dir_only -eq 0 ]; then
            __shmark_wrap_list_items "$max" $i $n $width "$list_items" \
                || return
        else
            echo "$list_items"
        fi
    done <<< "$(_shmark_listcat)"

    # Now add any uncategorized bookmarks using a default category
    if [ $missing_category -eq 1 ]; then
        if [ $listall -eq 1 ] || [ $dir_only -eq 1 ]; then
            category=""
            n=$(grep -c "^[|]" "$SHMARK_FILE") # no. matching lines
            [ $dir_only -eq 1 ] || echo "$SHMARK_DEFAULT_CATEGORY"
            list_items=$(__shmark_format_list_items $dir_only $i $width \
                "$category")
            i=$(( i + n )) # the next list position
            if [ $dir_only -eq 0 ]; then
                __shmark_wrap_list_items "$max" $i $n $width "$list_items" \
                    || return
            else
                echo "$list_items"
            fi
        fi
    fi
}

_shmark_listcat() {
    __shmark_setup_envvars || return 1

    local include_blank_categories=${include_blank_categories=-0}
    local categories=$(cut -d\| -f1 "$SHMARK_FILE" | sort -u)
    if [ "$include_blank_categories" -eq 1 ]; then
        echo "$categories"
    else
        grep -v '^$' <<< "$categories"
    fi
}

_shmark_listall() {
    local listall=1
    _shmark_list "$@"
}

_shmark_listdir() {
    local dir_only=1
    _shmark_list
}

_shmark_listunsort() {
    __shmark_setup_envvars || return 1

    cut -d\| -f2 "$SHMARK_FILE"
}

_shmark_print() {
    __shmark_setup_envvars || return 1

    local width=$( echo $( wc -l < "$SHMARK_FILE" ) )
    width=${#width}
    nl -w $width -s ') ' "$SHMARK_FILE"
}

_shmark_undo() {
    __shmark_setup_envvars || return 1

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
    __shmark_setup_envvars || return 1

    local var val
    printf "%s\n" "Current shmark environment variables:" ""
    for var in $(echo ${!SHMARK_@}); do
        val=${!var/#$HOME/\~}    # Replace home dir with tilde
        printf "    %-25s = %s\n" $var "$val"
    done
    return 0
}


# ==== UTILITY FUNCTIONS (PRIVATE) ===========================================

# These functions are called by the other functions to perform various tasks
# and aren't meant to be called directly. They assume that the calling function
# has already validated the environment variables. These functions can be
# thought of as private functions and are identified with a double underscore
# (__) prefix.

##
# Validate and/or create a bookmarks file.
#
__shmark_setup_bookmark_file() {
    #echo >&2 "DEBUG: ${FUNCNAME}(): running..."

    # Assign a null value if the bookmark file variable is undefined:
    : ${SHMARK_FILE:=}

    # If null, use a default value:
    if [[ -z "$SHMARK_FILE" ]]; then
        if [[ -d "${HOME}/var/shmark" ]]; then
            # Avoid creating another dot file/dir if alternate has been set up:
            SHMARK_FILE="${HOME}/var/shmark/bookmarks"
        else
            # Default to creating a dot directory:
            SHMARK_FILE="${HOME}/.shmark/bookmarks"
            [[ -d "${HOME}/.shmark" ]] || mkdir -m0700 "${HOME}/.shmark" \
                || {
                echo >&2 "Couldn't create directory at '${HOME}/.shmark'"
                kill -SIGINT $$
            }
        fi
    fi

    # Substitute home directory path for tilde:
    [[ ${SHMARK_FILE:0:1} == '~' ]] \
        && SHMARK_FILE="${SHMARK_FILE/#~/$HOME}"

    # Create bookmarks file if one doesn't exist:
    [[ -f "$SHMARK_FILE" ]] \
        || { touch "$SHMARK_FILE" && chmod 600 "$SHMARK_FILE" ; } \
        || { echo >&2 "Couldn't create a bookmarks file at '$SHMARK_FILE'"
    kill -SIGINT $$ ; }
}

##
# Set any undefined environment variables.
#
# These environment variables can be customized in .bash_profile or .bashrc.
# This function should be called by all "action" functions.
#
__shmark_setup_envvars() {
    #echo >&2 "DEBUG: ${FUNCNAME}(): running..."

    SHMARK_VERSION="@@VERSION@@"

    __shmark_setup_bookmark_file || return 1

    # The default action is used if shmark() is run without any args.
    : ${SHMARK_DEFAULT_ACTION:=}

    # The default category is used for any bookmarks that don't have a
    # category. This value is never written to the bookmarks file. If you
    # change the value of this environment variable, that value will be used
    # whenever uncategorized bookmarks are listed.
    : ${SHMARK_DEFAULT_CATEGORY:=MISCELLANEOUS}

    return 0
}

##
# Prepare a new bookmark for the current directory for adding or appending.
#
# If a bookmark for the current directory already exists, it is extracted and
# then deleted from the file. The category for the bookmark is then updated. If
# there was no existing bookmark for the current directory, then a new one is
# created. In either case, the formatted bookmark is returned to the caller via
# STDOUT.
#
# @param  (string) Optional category
# @return (string) Formatted bookmark
__shmark_prepare_new_bookmark() {
    local category="${1:-}"

    # $curdir is inherited from calling function.
    [[ -z "$curdir" ]] && return 1

    # Delete old bookmark first if one exists. Also makes a backup of the
    # bookmark file so don't make another backup in this function. If a
    # bookmark is deleted, it is returned via STDOUT.
    local delete_msg="Old bookmark deleted."
    local should_report_failure=0
    local bookmark=$(_shmark_delete "$curdir") || true  # continue regardless

    if [[ -z "$bookmark" ]]; then
        # New bookmark:
        local curdate="$(date '+%F %T')"
        bookmark="$category|$curdir|$curdate|$curdate"
    else
        # Update category for existing bookmark:
        bookmark=$(__shmark_update_category "$bookmark" "$category")
    fi

    echo "$bookmark"
}

##
# @param $1 (integer) Bool 1=true, 0=false. Should only directories be returned?
# @param $2 (integer) Starting list postition number
# @param $3 (integer) Number of digits in last line number
# @param $4 (string)  Bookmark category
# @return   (string)  Formatted list items
__shmark_format_list_items() {
    if [ $# -ne 4 ]; then
        echo >&2 "Error: '$FUNCNAME()' requires four arguments."
        echo >&2 "Usage: $FUNCNAME DIR_ONLY(int) IDX(int) WIDTH(int) CATEGORY(str)"
        return 1
    fi
    local dir_only=$1
    local idx=$2
    local width="$3"
    local category="$4"
    local result

    # Find lines with matching category:
    result=$(sed -n "s!^$category\|\([^|]*\)\|.*!\1!p" "$SHMARK_FILE")

    if [ $dir_only -eq 1 ]; then
        echo "$result"
    else
        # Indent list items two spaces:
        width=$(( width + 2 ))
        # Number the list items:
        nl -w $width -s ') ' -v $idx <<< "$result"
    fi
}

##
# Wrap long lines on a delimiter
#
# @param $1 (integer) Maximum line width
# @param $2 (string)  Delimiter for splitting line
# @param $3 (string)  Indent for wrapped lines (literal characters)
# @param $4 (string)  The line to wrap
# @return   (string)  Wrapped line
__shmark_wrap_long_line() {
    if [ $# -ne 4 ]; then
        echo >&2 "Error: '$FUNCNAME()' requires four arguments."
        echo >&2 \
            "Usage: $FUNCNAME WIDTH(int) DELIMITER(char) INDENT(str) LINE(str)"
        return 1
    fi
    local width="$1"   # maximum line width
    local delim="$2"   # delimiter for splitting line
    local indent="$3"  # indent for wrapped lines
    local line="$4"    # the line to wrap
    local wrapped_lines=( "" )
    local idx=0
    local segments item tmp final_text

    if [ ${#delim} -ne 1 ]; then
        echo >&2 "Error: $FUNCNAME(): DELIMITER must be a single character."
        echo >&2 \
            "Usage: $FUNCNAME WIDTH(int) DELIMITER(char) INDENT(str) LINE(str)"
        return 1
    fi

    if [ ${#line} -gt $width ]; then
        while IFS=$delim read -ra segments; do
            for item in "${segments[@]}"; do
                if [[ -n "${wrapped_lines[$idx]}" ]]; then
                    # Line is not empty, so append the next segment:
                    tmp="${wrapped_lines[$idx]}${delim}${item}"
                    if [ ${#tmp} -lt $width ]; then
                        # If the width of the new line is still less than the
                        # max, replace the existing line with the new line:
                        wrapped_lines[$idx]="$tmp"
                    else
                        # The new line is too long so chop off the last added
                        # segment (but keep a trailing delimiter):
                        wrapped_lines[$idx]="${tmp%${delim}*}${delim}"
                        # Put that last segment on the next line:
                        (( idx++ )) || :
                        wrapped_lines[$idx]="${indent}${item}"
                    fi
                else
                    # This line is empty, so just add the first segment:
                    wrapped_lines[$idx]="$item"
                fi
            done
            # Restore trailing delimiter if original line had one:
            [[ "${line:(-1):1}" == "${delim}" ]] \
                && wrapped_lines[$idx]="${wrapped_lines[$idx]%${delim}}${delim}"
            # Join array of lines:
            final_text=$( IFS=$'\n' ; echo "${wrapped_lines[*]}" )
        done <<< "$line"
    else
        final_text="$line"
    fi
    echo "$final_text"
}

##
# Wrap list items with an optional maximum number to output
#
# @param $1 (integer) Maximum list items
# @param $2 (integer) Next list index
# @param $3 (integer) Number of list items
# @param $4 (integer) Number of digits in last line number
# @param $5 (string)  The list items to wrap
# @return   (string)  Wrapped lines
__shmark_wrap_list_items() {
    if [ $# -ne 5 ]; then
        echo >&2 "Error: '$FUNCNAME()' requires five arguments."
        echo >&2 \
            "Usage: $FUNCNAME MAX(int) INDEX(int) LINE_COUNT(int) WIDTH(int) ITEMS(str)"
        return 1
    fi
    local max="$1"
    local idx="$2"
    local line_count="$3"
    local width="$4"
    local list_items="$5"
    local h line indent

    # Adjust indent width for added list characters
    # (see __shmark_format_list_items):
    width=$(( width + 4 ))
    indent=$(printf "%${width}s" " ")

    if [ $max  -gt 0 ] && [ $idx -gt $max ]; then
        h=$(( max - idx + 1 + line_count )) # number for 'head'
        #echo >&2 "DEBUG: h = (max - i + 1 + n) = ($max - $i + 1 + $n) = $h"
        while IFS= read -r line; do
            __shmark_wrap_long_line 80 '/' "$indent" "$line"
        done <<< "$(head -${h} <<< "$list_items")"
        #echo >&2 "DEBUG: exiting..."
        return 1 # not an error, but signal caller to exit
    fi
    #echo >&2 "DEBUG: --- list items ($n):"
    while IFS= read -r line; do
        __shmark_wrap_long_line 80 '/' "$indent" "$line"
    done <<< "$list_items"
    return 0
}

##
# @param  (integer) List position
# @return (string)  Bookmarked directory path at given list position
__shmark_get_directory_from_list_index() {
    if [ $# -ne 1 ]; then
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
    if [ $# -ne 1 ]; then
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
    if [ $# -ne 1 ]; then
        echo >&2 "Error: '$FUNCNAME()' requires an argument."
        echo >&2 "Usage: $FUNCNAME DIRECTORY_PATH|LIST_POSITION"
        return 1
    fi
    local dir
    if [[ "$1" =~ ^[1-9][0-9]*$ ]]; then
        dir="$(__shmark_get_directory_from_list_index $1)"
    else
        dir=${1/#$HOME/\~} # bookmarks file uses tildes for HOME
    fi
    fgrep -n -m1 "|${dir}|" "$SHMARK_FILE" | cut -d: -f1
}

##
# @param $1 (integer) Number to validate
# @param $2 (string)  Error message
# @return   Exit status: 0=true, >0=false
__shmark_validate_num() {
    if [ $# -ne 2 ]; then
        echo >&2 "Error: '$FUNCNAME()' requires two arguments."
        echo >&2 "Usage: $FUNCNAME NUM(int) ERROR_MESSAGE(str)"
        return 1
    fi
    local num="$1"
    local msg="$2"
    if [[ ! "$num" =~ ^[1-9][0-9]*$ ]]; then
        echo >&2 "$msg"
        echo >&2 ""
        _shmark_listall >&2
        echo >&2 ""
        _shmark_usage
        return $?
    fi
}

##
# @param  (string) A directory bookmark line (pipe-delimited, four fields)
# @return (string) Updated bookmark with current date for last field
__shmark_update_last_visited() {
    if [ $# -ne 1 ]; then
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
    if [ $# -ne 2 ]; then
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
    if [ $# -ne 2 ]; then
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

