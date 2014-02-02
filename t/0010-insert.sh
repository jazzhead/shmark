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

# === FUNCTIONS ===

tap_insert() {
    local msg="${1:-}"
    EXPECTED=$(replace_placeholders < "$EXPECTED_FILE" | replace_timestamps)
    shmark -f "$TMPFILE" insert $IDX >/dev/null 2>&1
    RESULT=$(replace_timestamps < "$TMPFILE")
    is "$RESULT" "$EXPECTED" "shmark insert ${IDX}$msg"
}

# === MAIN ===

plan_tests 32

# Create temp file:
[ -d 'tmp' ] || mkdir -m0700 'tmp' || exit $?
TMPFILE=$(mktemp "tmp/${PROGNAME}.XXXXXX") || exit $?

# File name template for expected data files (':::' is the placeholder):
EXPECTED_TMPL="data/expected/${PROGNAME}/:::.txt"

# --- Group A ---

SAMPLE_FILE='data/bookmarks-01.txt'
cp -f "$SAMPLE_FILE" "$TMPFILE" || exit $?  # copy sample bookmarks file
diag "Group A"

#diag "=================================== Original: '$SAMPLE_FILE'"
#while IFS= read -r line; do
#    diag "$line"
#done <<< "$(shmark -f "$SAMPLE_FILE" listall)"
#diag "-----------------------------------"

IDX=2 # list position index for insertion
EXPECTED_FILE="${EXPECTED_TMPL/:::/a01}"
tap_insert

IDX=3
EXPECTED_FILE="${EXPECTED_TMPL/:::/a02}"
tap_insert

IDX=1
EXPECTED_FILE="${EXPECTED_TMPL/:::/a03}"
tap_insert

IDX=8
EXPECTED_FILE="${EXPECTED_TMPL/:::/a04}"
tap_insert

IDX=6
EXPECTED_FILE="${EXPECTED_TMPL/:::/a05}"
tap_insert

IDX=7
EXPECTED_FILE="${EXPECTED_TMPL/:::/a06}"
tap_insert

IDX=9
EXPECTED_FILE="${EXPECTED_TMPL/:::/a07}"
tap_insert

IDX=12
EXPECTED_FILE="${EXPECTED_TMPL/:::/a08}"
tap_insert

IDX=13
EXPECTED_FILE="${EXPECTED_TMPL/:::/a09}"
tap_insert

cp -f "$SAMPLE_FILE" "$TMPFILE" || exit $?  # reset the temp file

IDX=12
EXPECTED_FILE="${EXPECTED_TMPL/:::/a10}"
tap_insert

IDX=8
EXPECTED_FILE="${EXPECTED_TMPL/:::/a11}"
tap_insert

IDX=14
EXPECTED_FILE="${EXPECTED_TMPL/:::/a12}"
tap_insert " (append to end of list)"

IDX=4
EXPECTED_FILE="${EXPECTED_TMPL/:::/a13}"
tap_insert

IDX=6
EXPECTED_FILE="${EXPECTED_TMPL/:::/a14}"
tap_insert

IDX=13
EXPECTED_FILE="${EXPECTED_TMPL/:::/a15}"
tap_insert " (target last position, insert before it)"

IDX=14
EXPECTED_FILE="${EXPECTED_TMPL/:::/a16}"
tap_insert " (append to end of list)"

# Optionally show results:
#list_result
#print_result


# --- Group B ---

SAMPLE_FILE='data/bookmarks-02.txt'
cp -f "$SAMPLE_FILE" "$TMPFILE" || exit $?  # copy sample bookmarks file
diag "Group B"

#diag "=================================== Original: '$SAMPLE_FILE'"
#while IFS= read -r line; do
#    diag "$line"
#done <<< "$(shmark -f "$SAMPLE_FILE" listall)"
#diag "-----------------------------------"

IDX=2 # list position index for insertion
EXPECTED_FILE="${EXPECTED_TMPL/:::/b01}"
tap_insert

IDX=3
EXPECTED_FILE="${EXPECTED_TMPL/:::/b02}"
tap_insert

IDX=1
EXPECTED_FILE="${EXPECTED_TMPL/:::/b03}"
tap_insert

IDX=8
EXPECTED_FILE="${EXPECTED_TMPL/:::/b04}"
tap_insert

IDX=6
EXPECTED_FILE="${EXPECTED_TMPL/:::/b05}"
tap_insert

IDX=7
EXPECTED_FILE="${EXPECTED_TMPL/:::/b06}"
tap_insert

IDX=9
EXPECTED_FILE="${EXPECTED_TMPL/:::/b07}"
tap_insert

IDX=12
EXPECTED_FILE="${EXPECTED_TMPL/:::/b08}"
tap_insert

IDX=13
EXPECTED_FILE="${EXPECTED_TMPL/:::/b09}"
tap_insert

cp -f "$SAMPLE_FILE" "$TMPFILE" || exit $?  # reset the temp file

IDX=12
EXPECTED_FILE="${EXPECTED_TMPL/:::/b10}"
tap_insert

IDX=8
EXPECTED_FILE="${EXPECTED_TMPL/:::/b11}"
tap_insert

IDX=14
EXPECTED_FILE="${EXPECTED_TMPL/:::/b12}"
tap_insert " (append to end of list)"

IDX=4
EXPECTED_FILE="${EXPECTED_TMPL/:::/b13}"
tap_insert

IDX=6
EXPECTED_FILE="${EXPECTED_TMPL/:::/b14}"
tap_insert

IDX=13
EXPECTED_FILE="${EXPECTED_TMPL/:::/b15}"
tap_insert " (target last position, insert before it)"

IDX=14
EXPECTED_FILE="${EXPECTED_TMPL/:::/b16}"
tap_insert " (append to end of list)"

# Optionally show results:
#list_result
#print_result

# === END ===

# Clean up:
rm -fr tmp/*

# Change back to the original directory:
cd - > /dev/null

