#!/bin/bash __this-file-should-be-sourced-not-run__
#
# Test functions for shmark test scripts
#
# @date    2014-01-28 Last modified
# @date    2014-01-24 First version
# @author  Steve Wheeler
##############################################################################

replace_timestamps() {
    # No parameters. Gets input from STDIN and outputs to STDOUT.

    # All dates need to be replaced with placeholders because the date added
    # when the function is run won't match a hard-coded date in the expected
    # results data file.
    sed -E \
      's/\|[0-9]{4}(-[0-9]{2}){2} [0-9]{2}(:[0-9]{2}){2}/|YYYY-MM-DD hh:mm:ss/g'
}

replace_placeholders() {
    # No parameters. Gets input from STDIN and outputs to STDOUT. Uses global
    # variables from calling script.

    # The expected results data file can't know the exact path that will be
    # added when the test is run, so a placeholder is used instead which needs
    # to be replaced dynamically during the test.

    # First assign a default value to any null variables in case we're running
    # under nounset:
    : ${ADDED_DIR:=} # For absolute paths
    : ${PROGDIR:=}   # For paths relative to the program's directory

    local line

    # Now replace placeholders:
    while IFS= read -r line; do
        if [ -n "$ADDED_DIR" ]; then
            line="$(sed 's!{ADDED_DIR}!'"$ADDED_DIR"'!' <<< "$line")"
        fi
        if [ -n "$PROGDIR" ]; then
            line="$(sed 's!{PROGDIR}!'"${PROGDIR/#$HOME/~}"'!' <<< "$line")"
        fi
        echo "$line"
    done
}

list_result() {
    # No parameters. Input is from global variable in calling script.
    # Output is to STDOUT.
    local line
    diag "=================================== List Result ('$TMPFILE')"
    while IFS= read -r line; do
        diag "$line"
    done <<< "$(shmark -f "$TMPFILE" listall)"
}

print_result() {
    # No parameters. Input is from global variable in calling script.
    # Output is to STDOUT.
    local line
    diag "=================================== Print Result ('$TMPFILE')"
    while IFS= read -r line; do
        diag "$(printf "%.78s" "$line")"
    done <<< "$(shmark -f "$TMPFILE" print)"
    #done <<< "$(shmark -f "$TMPFILE" print | replace_timestamps)"
}
