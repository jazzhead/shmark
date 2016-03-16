#!/usr/bin/env bash
set -o nounset  # (set -u) Treat unset variables as error and exit script
#set -o errexit  # (set -e) Exit if any command returns a non-zero status
set -o pipefail # Return non-zero status if any piped commands fail
##############################################################################
#
# Tests for shmark
#
# @date    2016-03-16 Last modified
# @date    2014-01-26 First version
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

# Source third-party TAP functions library:
. lib/vendor/tap-functions.sh || exit $?

# === MAIN ===

plan_tests 2

SAMPLE_FILE='data/bookmarks-01.txt'

# Create temp file:
[ -d 'tmp' ] || mkdir -m0700 'tmp' || exit $?
TMPFILE=$(mktemp "tmp/${PROGNAME}.XXXXXX") || exit $?

cp -f "$SAMPLE_FILE" "$TMPFILE" || exit $?  # copy sample bookmarks file

EXPECTED_FILE="data/expected/${PROGNAME}/001.txt"
EXPECTED=$(cat "$EXPECTED_FILE")
shmark -f "$TMPFILE" chcat -f "_FOO" 4 >/dev/null 2>&1
RESULT=$(cat "$TMPFILE")
while IFS= read -r line; do
    diag "$line"
done <<< "$RESULT"
is "$RESULT" "$EXPECTED" "shmark chcat"

EXPECTED_FILE="data/expected/${PROGNAME}/002.txt"
EXPECTED=$(cat "$EXPECTED_FILE")
shmark -f "$TMPFILE" chcat -f "" 7 >/dev/null 2>&1
RESULT=$(cat "$TMPFILE")
while IFS= read -r line; do
    diag "$line"
done <<< "$RESULT"
is "$RESULT" "$EXPECTED" "shmark chcat (to null category)"

# === END ===

# Clean up:
rm -fr tmp/*

# Change back to the original directory:
cd - > /dev/null

