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

# === MAIN ===

plan_tests 2

[ -d 'tmp' ] || mkdir -m0700 'tmp' || exit $?
TMPFILE=$(mktemp "tmp/${PROGNAME}.XXXXXX") || exit $?

EXPECTED_FILE_ORIG="data/expected/${PROGNAME}/orig.txt"
EXPECTED_FILE_EDIT="data/expected/${PROGNAME}/edit.txt"
cp -f "$EXPECTED_FILE_EDIT" "$TMPFILE" || exit $?       # start with edited file
cp -f "$EXPECTED_FILE_ORIG" "${TMPFILE}.bak" || exit $? # the backup is the orig

shmark -f "$TMPFILE" undo >/dev/null 2>&1  # back to previous (.bak)
EXPECTED=$(cat "$EXPECTED_FILE_ORIG")
RESULT=$(cat "$TMPFILE")
is "$RESULT" "$EXPECTED" "shmark undo (back to previous file)"

shmark -f "$TMPFILE" undo >/dev/null 2>&1  # redo edit
EXPECTED=$(cat "$EXPECTED_FILE_EDIT")
RESULT=$(cat "$TMPFILE")
is "$RESULT" "$EXPECTED" "shmark undo (redo back to newer file)"

# === END ===

# Clean up:
rm -fr tmp/*

# Change back to the original directory:
cd - > /dev/null

