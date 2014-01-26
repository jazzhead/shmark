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
# @date    2014-01-26 Last modified
# @date    2014-01-18 First version
# @author  Steve Wheeler
#
##############################################################################

[ -n "$BASH_VERSION" ] || return    # bash required

SHMARK_VERSION="@@VERSION@@"

#: ${SHMARK_FILE:=bookmarks.example}
: ${SHMARK_FILE:="~/Desktop/test.noindex/bookmarks"}
SHMARK_FILE="${SHMARK_FILE/#~/$HOME}" # expand tilde to home directory path
#echo "DEBUG: $SHMARK_FILE"; return 1

[[ -f "$SHMARK_FILE" ]] || touch "$SHMARK_FILE" || {
    echo >&2 "Couldn't create a bookmarks file at '$SHMARK_FILE'"
    kill -SIGINT $$
}

: ${SHMARK_DEFAULT_ACTION:=}

# == INFO FUNCTIONS ==

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

ACTIONS
$(_shmark_actions_help)

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
        been sorted by category.)

    listcat|lsc
        Show list of bookmark categories used in bookmarks file.

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

# == MAIN FUNCTION ==

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
                file="${1/#~/$HOME}" # expand tilde to home directory path
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
        cd|go)      # go (cd) to bookmarked directory
            shift
            if [[ $# -eq 0 ]]; then
                echo >&2 "Error: The 'cd' action requires an argument."
                return
            fi
            _shmark_cd "$1"
            ;;

        add|a)      # add bookmark for current directory to top of file
            shift
            _shmark_add "${1:-}" # 'label' argument optional
            ;;

        append|app) # append bookmark for current directory to bottom of file
            shift
            _shmark_append "${1:-}" # 'label' argument optional
            ;;

        insert|ins) # insert a bookmark at a specific list position
            shift
            _shmark_insert "${1:-}" # will be prompted if arg omitted
            ;;

        list|ls)    # show categorized bookmarks list
            _shmark_list
            ;;

        listcat|lsc) # show list of bookmark categories used
            _shmark_list_categories
            ;;

        listdir|lsd)    # show bookmarked directories only w/o labels & line #s
            _shmark_listdir
            ;;

        listunsort|lsus) # show unsorted bookmarked directories only
            _shmark_listunsort
            ;;

        print)      # show raw bookmark file (w/line numbers)
            _shmark_print
            ;;

        del|rm)     # delete a bookmark
            shift
            if [[ $# -eq 0 ]]; then
                echo >&2 "Error: The 'delete' action requires an argument."
                return
            fi
            _shmark_delete "$1"
            ;;

        undo)       # undo the last edit to the bookmarks file
            _shmark_undo
            ;;

        edit|ed)    # open bookmarks file in EDITOR
            _shmark_edit
            ;;

        chcat|cc)   # change the category of a bookmark
            shift
            if [[ $# -eq 2 ]]; then
                _shmark_chcat "$@"
            else
                echo >&2 "Error: The 'chcat' action requires two arguments."
                return
            fi
            ;;

        help)       # show detailed help
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

        shorthelp)  # show short help
            _shmark_shorthelp
            ;;

        *)
            echo >&2 "Error: Unknown action: $action"
            _shmark_usage
            ;;
    esac
}

# == UTILITY FUNCTIONS ==

_shmark_format_list_items() {
    local dir_only=$1
    local idx=$2
    local label="$3"
    local result width formatted line

    # Find lines with matching category (label):
    result=$(sed -n "s!^$label\|\([^|]*\)\|.*!\1!p" "$SHMARK_FILE")

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
            _shmark_wrap_long_line 80 '/' "      " "$line"
        done <<< "$formatted"
    fi
}

_shmark_wrap_long_line() {
    # Usage:  _shmark_wrap_long_line WIDTH DELIMITER INDENT LINE
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

_shmark_get_directory_from_list_index() {
    # @param  integer List position
    # @return string  Bookmarked directory path at given list position
    [[ -s "$SHMARK_FILE" ]] || return
    sed "$1"'q;d' <<< "$(_shmark_listdir)"
}

_shmark_get_list_index_from_directory() {
    # @param  string  Bookmarked directory path
    # @return integer List position of given bookmarked directory
    _shmark_listdir | grep -n -m1 "^${1}$" | cut -d: -f1
}

_shmark_get_line_number() {
    # @param  string|integer  Directory path or its list position
    # @return integer         Line number in bookmarks file for given directory
    local dir
    if [[ "$1" =~ ^[1-9][0-9]*$ ]]; then
        dir="$(_shmark_get_directory_from_list_index $1)"
    else
        dir="$1"
    fi
    fgrep -n -m1 "|${dir}|" "$SHMARK_FILE" | cut -d: -f1
}

_shmark_validate_num() {
    local num="$1"; shift
    local msg="$1"
    if [[ ! "$num" =~ ^[1-9][0-9]*$ ]]; then
        echo >&2 "$msg"
        echo >&2 ""
        _shmark_list >&2
        echo >&2 ""
        _shmark_usage
    fi
}

_shmark_update_last_visited() {
    # @param  string A directory bookmark line (pipe-delimited, four fields)
    # @return string Updated bookmark with current date for last field
    local line="$1"
    printf "%s|%s\n" "$(cut -d\| -f1-3 <<< "$line")" "$(date '+%F %T')"
    # Bookmark format:  label|directory|creation date|last visited
}

_shmark_replace_line() { # void
    # Replaces line in bookmarks file
    # @param integer Line number from bookmarks file
    # @param string  The replacement text (a formatted directory bookmark)
    local line_num="$1"; shift
    local line="$1"
    cp -p ${SHMARK_FILE}{,.bak}
    printf '%s\n' "${line_num}c" "$line" . w |
    ed -s "$SHMARK_FILE" >/dev/null
}

# == ACTIONS ==

_shmark_cd() {
    local dir absolute_path line_num bookmark

    # Get bookmark directory path (for searching bookmarks file):
    if [[ "$1" =~ ^[1-9][0-9]*$ ]]; then
        dir="$(_shmark_get_directory_from_list_index $1)"
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
    cd "$absolute_path" && echo >&2 "${PWD/#$HOME/~}"

    # Get line number for updating the bookmarks file:
    line_num=$(_shmark_get_line_number "$dir")

    # Update the directory's 'last visited' field in the bookmarks file:
    bookmark=$(sed $line_num'q;d' "$SHMARK_FILE")
    bookmark=$(_shmark_update_last_visited "$bookmark")
    _shmark_replace_line $line_num "$bookmark"

    return 0
}

_shmark_add() {
    local label="$1" || return
    local curdir="${PWD/#$HOME/~}"     # Replace home directory with tilde
    local curdate="$(date '+%F %T')"

    # Delete old bookmark first if one exists. Also makes a backup of the
    # bookmark file so don't make another backup in this function.
    local delete_msg="Old bookmark deleted."
    local should_report_failure=0
    _shmark_delete "$curdir" || true  # continue regardless

    # Output line format:  label|directory|creation date|last visited
    local bookmark="$label|$curdir|$curdate|$curdate"
    printf '%s\n' 0a "$bookmark" . w | ed -s "$SHMARK_FILE"
    echo >&2 "Bookmark added for '$curdir'."
}

_shmark_append() {
    local label="$1" || return
    local curdir="${PWD/#$HOME/~}"     # Replace home directory with tilde
    local curdate="$(date '+%F %T')"

    # Delete old bookmark first if one exists. Also makes a backup of the
    # bookmark file so don't make another backup in this function.
    local delete_msg="Old bookmark deleted."
    local should_report_failure=0
    _shmark_delete "$curdir" || true  # continue regardless

    # Output line format:  label|directory|creation date|last visited
    local bookmark="$label|$curdir|$curdate|$curdate"
    echo "$bookmark" >> "$SHMARK_FILE"
    echo >&2 "Bookmark appended for '$curdir'."
}

_shmark_insert() {
    local line_num list_pos msg
    local ed_cmd=
    local line_total=$(echo $(wc -l < "$SHMARK_FILE"))
    local np=$((line_total + 1)) # 'np' = "next position" - need short var for:
    local default_errmsg=$( printf "%s\n" \
        "Error: The 'insert' action requires a number argument chosen" \
        "       from the bookmarks list. To append as the last bookmark," \
        "       use ${np}; otherwise, use a number 1-${line_total}."
    )

    # Get the target list postion:
    if [[ -z "$1" ]]; then
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
        _shmark_validate_num "$1" "$default_errmsg"
        list_pos="$1"
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
    line_num=$(_shmark_get_line_number "$list_pos")

    # Now check that the line number is a number and is not zero:
    _shmark_validate_num "$line_num" "$default_errmsg"

    # Need category of bookmark currently occupying target list position
    local label=$(awk -F\| 'NR=='$line_num' {print $1}' "$SHMARK_FILE")
    local curdir="${PWD/#$HOME/~}"     # Replace home directory with tilde
    local curdate="$(date '+%F %T')"

    #printf >&2 "DEBUG: ${FUNCNAME}(): %s\n" \
    #    "line_total = $line_total" \
    #    "list_pos   = $list_pos" \
    #    "line_num   = $line_num" \
    #    "label      = $label"    \
    #    "curdir     = $curdir"
    #echo >&2 "DEBUG: ${FUNCNAME}(): exiting early..."; return 1

    # If there is already an existing bookmark for the current directory,
    # find its line number before deleting it.
    local cur_line_num=$(_shmark_get_line_number "$curdir")
    if [ -n "$cur_line_num" ]; then
        # Find the list position of the old bookmark (so we can adjust the
        # target position if neccesary after deleting the old bookmark):
        local cur_list_pos=$(_shmark_get_list_index_from_directory "$curdir")
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
    #    "label      = $label"    \
    #    "curdir     = $curdir"

    # If we don't have an 'ed' command yet, that means we're inserting:
    [[ -z "$ed_cmd" ]] && ed_cmd="${line_num}i"

    #echo >&2 "DEBUG: ${FUNCNAME}(): ed_cmd   = $ed_cmd"

    # Output line format:  label|directory|creation date|last visited
    local bookmark="$label|$curdir|$curdate|$curdate"

    #echo >&2 "DEBUG: ${FUNCNAME}(): exiting early..."; return 1

    printf '%s\n' "$ed_cmd" "$bookmark" . w | ed -s "$SHMARK_FILE"
    echo >&2 "Bookmark for '$curdir' inserted into bookmarks file."
}

_shmark_delete() {
    # @param  string|integer  Directory path or its list position
    local delete_msg="${delete_msg:-Bookmark deleted.}"
    local should_report_failure="${should_report_failure:-1}"
    local line_num=$(_shmark_get_line_number "$1")
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

_shmark_edit() {
    local editor=${EDITOR-vi}
    echo >&2 "*** Editing bookmarks file (${SHMARK_FILE/#$HOME/~})..."
    $editor "$SHMARK_FILE"
}

_shmark_list() {
    local dir_only=${dir_only:-0}
    local i=1
    local n label result escaped_label
    local missing_label=0
    local include_blank_categories=1

    [[ -s "$SHMARK_FILE" ]] || return

    while read -r label; do
        if [[ -z "$label" ]]; then
            # Skip uncategorized bookmarks for now. Add them at the bottom.
            missing_label=1
            continue
        fi
        escaped_label=$(sed -E 's/[]\.*+?$|(){}[^-]/\\&/g' <<< "$label")
        n=$(grep -c "^$escaped_label" "$SHMARK_FILE")
        [[ $dir_only -eq 1 ]] || echo "$label"
        _shmark_format_list_items $dir_only $i "$label"
        i=$((i + n))
    done <<< "$(_shmark_list_categories)"

    # Now add any uncategorized bookmarks using a default label
    if [[ $missing_label -eq 1 ]]; then
        label=""
        [[ $dir_only -eq 1 ]] || echo "MISCELLANEOUS"
        _shmark_format_list_items $dir_only $i "$label"
    fi
}

_shmark_list_categories() {
    local include_blank_categories=${include_blank_categories=-0}
    local categories=$(cut -d\| -f1 "$SHMARK_FILE" | sort -u)
    if [[ "$include_blank_categories" -eq 1 ]]; then
        echo "$categories"
    else
        grep -v '^$' <<< "$categories"
    fi
}

_shmark_listdir() {
    local dir_only=1
    _shmark_list
}

_shmark_listunsort() {
    cut -d\| -f2 "$SHMARK_FILE"
}

_shmark_print() {
    #awk -F\| '{ printf "%-10s%-50s%-20s%s\n",$1,$2,$3,$4}' "$SHMARK_FILE"
    #cat "$SHMARK_FILE"
    local width=$( echo $( printf $( wc -l < "$SHMARK_FILE" ) | wc -c ) )
    nl -w $width -s ') ' "$SHMARK_FILE"
}

_shmark_undo() {
    if [[ -f "${SHMARK_FILE}.bak" ]]; then
        echo >&2 "Undoing last edit to the bookmarks file..."
        mv -f "${SHMARK_FILE}"{.bak,.tmp} # rename current backup as tmp
        mv -f "${SHMARK_FILE}"{,.bak}     # rename current file as new backup
        mv -f "${SHMARK_FILE}"{.tmp,}     # rename tmp file as new current
    else
        echo >&2 "Couldn't undo. No previous backup file available."
    fi
}

_shmark_chcat() {
    echo >&2 "TODO: ${FUNCNAME}()"
}

