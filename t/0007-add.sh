#!/bin/bash
set -o nounset  # (set -u) Treat unset variables as error and exit script
#set -o errexit  # (set -e) Exit if any command returns a non-zero status
set -o pipefail # Return non-zero status if any piped commands fail
##############################################################################
#
# Tests for shmark
#
# @date    2014-02-01 Last modified
# @date    2014-01-24 First version
# @author  Steve Wheeler
#
# To run all tests, from the main project directory (not this 't' test
# directory), run:
#
#     make test
#
# which runs:
#
#     prove -f ./t/[0-9][0-9][0-9]-*.sh
#
# Test scripts can also be run individually with:
#
#     bash t/<test_name>.sh
#
##############################################################################

# === SETUP ===

PROGNAME="${0##*/}"                             # get file basename
PROGDIR=$(cd $(dirname $0) && pwd) || exit $?   # get script directory
PROGNAME="${PROGNAME%.*}"                       # file name w/o extension
ADDED_DIR="${PROGDIR/#$HOME/~}" # get absolute directory path (for sourced lib)

# Change to the test directory (so we can specify all paths as relative
# to the test directory):
cd "$PROGDIR" || exit $?

# Unset any shmark variables in the environment so that we use the defaults:
unset ${!SHMARK_@}

# Source shmark:
. ../shmark.sh || exit $?

# Source custom test functions library:
. lib/shmark_test_functions.sh || exit $?

# Source third-party TAP functions library:
. lib/vendor/tap-functions.sh || exit $?

# === MAIN ===

plan_tests 2

SAMPLE_FILE='data/bookmarks-01.txt'

# Create temp file:
[ -d 'tmp' ] || mkdir -m0700 'tmp' || exit $?
TMPFILE=$(mktemp "tmp/${PROGNAME}.XXXXXX") || exit $?
#echo >&2 "$TMPFILE" # :DEBUG:
#cat "$TMPFILE" >&2  # :DEBUG:

cp -f "$SAMPLE_FILE" "$TMPFILE" || exit $?  # copy sample bookmarks file
EXPECTED_FILE="data/expected/${PROGNAME}/001.txt"
EXPECTED=$(replace_placeholders < "$EXPECTED_FILE" | replace_timestamps)
shmark -f "$TMPFILE" add >/dev/null 2>&1
RESULT=$(replace_timestamps < "$TMPFILE")
#while IFS= read -r line; do
#    diag "$line"
#done <<< "$RESULT"
is "$RESULT" "$EXPECTED" "shmark add"

cp -f "$SAMPLE_FILE" "$TMPFILE" || exit $?  # reset the temp file
EXPECTED_FILE="data/expected/${PROGNAME}/002.txt"
EXPECTED=$(replace_placeholders < "$EXPECTED_FILE" | replace_timestamps)
shmark -f "$TMPFILE" add @NEXT >/dev/null 2>&1
RESULT=$(replace_timestamps < "$TMPFILE")
#while IFS= read -r line; do
#    diag "$line"
#done <<< "$RESULT"
is "$RESULT" "$EXPECTED" "shmark add CATEGORY"

# === END ===

# Clean up:
rm -fr tmp/*

# Change back to the original directory:
cd - > /dev/null

