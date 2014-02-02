#!/bin/bash
set -o nounset  # (set -u) Treat unset variables as error and exit script
#set -o errexit  # (set -e) Exit if any command returns a non-zero status
set -o pipefail # Return non-zero status if any piped commands fail
##############################################################################
#
# Tests for shmark
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
# @date    2014-01-26 First version
# @author  Steve Wheeler
##############################################################################

# === SETUP ===

PROGNAME="${0##*/}"                             # get file basename
PROGDIR=$(cd $(dirname $0) && pwd) || exit $?   # get script directory
PROGNAME="${PROGNAME%.*}"                       # file name w/o extension

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

plan_tests 3

SAMPLE_FILE='data/bookmarks-05.txt'

# Create temp file and directories:
[ -d 'tmp' ] || mkdir -m0700 'tmp' || exit $?
[ -d 'tmp/foo/bar' ] || mkdir -p 'tmp/foo/bar' || exit $?
TMPFILE=$(mktemp "tmp/${PROGNAME}.XXXXXX") || exit $?

replace_placeholders < "$SAMPLE_FILE" > "$TMPFILE" || exit $?

shmark -f "$TMPFILE" cd 1 >/dev/null 2>&1
retval=$?
is $retval 0 "'shmark cd' - existing directory"
[ $retval -eq 0 ] && cd - > /dev/null # change back to last directory

shmark -f "$TMPFILE" cd 2 >/dev/null 2>&1
retval=$?
isnt "$retval" 0 "'shmark cd' - should error for non-existent directory"
[ $retval -eq 0 ] && cd - >/dev/null

shmark -f "$TMPFILE" cd >/dev/null 2>&1
retval=$?
isnt "$retval" 0 "'shmark cd' - should error for missing argument"
[ $retval -eq 0 ] && cd - > /dev/null

# === END ===

# Clean up:
rm -fr tmp/*

