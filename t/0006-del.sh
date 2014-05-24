#!/usr/bin/env bash
set -o nounset  # (set -u) Treat unset variables as error and exit script
#set -o errexit  # (set -e) Exit if any command returns a non-zero status
set -o pipefail # Return non-zero status if any piped commands fail
##############################################################################
#
# Tests for shmark
#
# @date    2014-05-23 Last modified
# @date    2014-01-24 First version
# @author  Steve Wheeler
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

tap_delete() {
    local msg="${1:-}"
    EXPECTED=$(replace_timestamps < "$EXPECTED_FILE")
    shmark -f "$TMPFILE" del "$DEL_TARGET" >/dev/null 2>&1
    RESULT=$(replace_timestamps < "$TMPFILE")
    is "$RESULT" "$EXPECTED" "shmark del ${DEL_TARGET}$msg"
}

# === MAIN ===

plan_tests 11

# Create temp file:
[ -d 'tmp' ] || mkdir -m0700 'tmp' || exit $?
TMPFILE=$(mktemp "tmp/${PROGNAME}.XXXXXX") || exit $?

# File name template for expected data files (':::' is the placeholder):
EXPECTED_TMPL="data/expected/${PROGNAME}/:::.txt"

# --- Group A ---

SAMPLE_FILE='data/bookmarks-01.txt'
cp -f "$SAMPLE_FILE" "$TMPFILE" || exit $?  # copy sample bookmarks file
diag "Group A"

DEL_TARGET="~/Desktop/test.noindex/qux"
EXPECTED_FILE="${EXPECTED_TMPL/:::/a01}"
tap_delete "  (by name)"

DEL_TARGET=10
EXPECTED_FILE="${EXPECTED_TMPL/:::/a02}"
tap_delete "  (by list position)"

DEL_TARGET=1
EXPECTED_FILE="${EXPECTED_TMPL/:::/a03}"
tap_delete "   (first listed bookmark)"

DEL_TARGET=9
EXPECTED_FILE="${EXPECTED_TMPL/:::/a04}"
tap_delete "   (last listed bookmark)"

DEL_TARGET='foo'
EXPECTED_FILE="${EXPECTED_TMPL/:::/a04}"
tap_delete "  (non-matching name ignored)"

[ -f "${TMPFILE}.bak" ]
ok $? "'shmark del' - create backup file"

# --- Group B ---

SAMPLE_FILE='data/bookmarks-02.txt'
cp -f "$SAMPLE_FILE" "$TMPFILE" || exit $?  # copy sample bookmarks file
diag "Group B"

DEL_TARGET="~/Desktop/test.noindex/qux"
EXPECTED_FILE="${EXPECTED_TMPL/:::/b01}"
tap_delete "  (by name)"

DEL_TARGET=10
EXPECTED_FILE="${EXPECTED_TMPL/:::/b02}"
tap_delete "  (by list position)"

DEL_TARGET=1
EXPECTED_FILE="${EXPECTED_TMPL/:::/b03}"
tap_delete "   (first listed bookmark)"

DEL_TARGET=9
EXPECTED_FILE="${EXPECTED_TMPL/:::/b04}"
tap_delete "   (last listed bookmark)"

# --- Group C ---

SAMPLE_FILE='data/bookmarks-03.txt'
cp -f "$SAMPLE_FILE" "$TMPFILE" || exit $?  # copy sample bookmarks file
diag "Group C"

EXPECTED_FILE="${EXPECTED_TMPL/:::/c01}"
shmark -f "$TMPFILE" del 1 >/dev/null 2>&1
diff -q "$EXPECTED_FILE" "$TMPFILE" >/dev/null 2>&1
ok $? "'shmark del' - delete only bookmark in file"

# === END ===

# Clean up:
rm -fr tmp/*

# Change back to the original directory:
cd - > /dev/null

