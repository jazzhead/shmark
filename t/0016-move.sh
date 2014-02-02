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
PROGNAME="${PROGNAME%.*}"                       # file name w/o extension

# Change to the test directory (so we can specify all paths as relative
# to the test directory):
cd $(dirname $0) || exit $?

# Unset any shmark variables in the environment so that we use the defaults:
unset ${!SHMARK_@}

# Source shmark:
. ../shmark.sh || exit $?

# Source custom test functions library:
. lib/shmark_test_functions.sh || exit $?

# Source third-party TAP functions library:
. lib/vendor/tap-functions.sh || exit $?

# === FUNCTIONS ===

tap_move() {
    local from_idx=$1
    local to_idx=$2
    local msg="${3:-}"
    EXPECTED=$(cat "$EXPECTED_FILE")
    shmark -f "$TMPFILE" move $from_idx $to_idx >/dev/null 2>&1
    RESULT=$(cat "$TMPFILE")
    is "$RESULT" "$EXPECTED" "shmark move ${from_idx} ${to_idx}$msg"
}

# === MAIN ===

plan_tests 13

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

EXPECTED_FILE="${EXPECTED_TMPL/:::/a01}"
tap_move 2 1

EXPECTED_FILE="${EXPECTED_TMPL/:::/a02}"
tap_move 1 4

EXPECTED_FILE="${EXPECTED_TMPL/:::/a03}"
tap_move 3 12 " (target last position, insert before it)"

EXPECTED_FILE="${EXPECTED_TMPL/:::/a04}"
tap_move 11 13 " (append to end of list)"

EXPECTED_FILE="${EXPECTED_TMPL/:::/a05}"
tap_move 12 5 " (insert as first line in file)"

EXPECTED_FILE="${EXPECTED_TMPL/:::/a06}"
tap_move 5 13 " (move/append back to end of list)"


# --- Group B ---

SAMPLE_FILE='data/bookmarks-02.txt'
cp -f "$SAMPLE_FILE" "$TMPFILE" || exit $?  # copy sample bookmarks file
diag "Group B"

#diag "=================================== Original: '$SAMPLE_FILE'"
#while IFS= read -r line; do
#    diag "$line"
#done <<< "$(shmark -f "$SAMPLE_FILE" listall)"
#diag "-----------------------------------"

EXPECTED_FILE="${EXPECTED_TMPL/:::/b01}"
tap_move 2 1

EXPECTED_FILE="${EXPECTED_TMPL/:::/b02}"
tap_move 1 4

EXPECTED_FILE="${EXPECTED_TMPL/:::/b03}"
tap_move 3 5 " (target bookmark at last line of file, insert above it)"

EXPECTED_FILE="${EXPECTED_TMPL/:::/b04}"
tap_move 4 12 " (target last list position, insert before it)"

EXPECTED_FILE="${EXPECTED_TMPL/:::/b05}"
tap_move 11 13 " (append to end of list)"

EXPECTED_FILE="${EXPECTED_TMPL/:::/b06}"
tap_move 12 5 " (insert as first line in file)"

EXPECTED_FILE="${EXPECTED_TMPL/:::/b07}"
tap_move 5 13 " (move/append back to end of list)"

# Optionally show results:
#list_result
#print_result

# === END ===

# Clean up:
rm -fr tmp/*

# Change back to the original directory:
cd - > /dev/null

