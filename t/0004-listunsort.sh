#!/bin/bash
set -o nounset  # (set -u) Treat unset variables as error and exit script
#set -o errexit  # (set -e) Exit if any command returns a non-zero status
set -o pipefail # Return non-zero status if any piped commands fail
##############################################################################
#
# Tests for shmark
#
# @date    2014-02-01 Last modified
# @date    2014-01-23 First version
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

# Source the TAP functions library:
. lib/vendor/tap-functions.sh || exit $?

# === MAIN ===

plan_tests 1

EXPECTED=$(cat "data/expected/${PROGNAME}.txt")
RESULT=$(shmark -f "data/bookmarks-02.txt" listunsort)
while IFS= read -r line; do
    diag "$line"
done <<< "$RESULT"
is "$RESULT" "$EXPECTED" "shmark listunsort"

# === END ===

# Change back to the original directory:
cd - > /dev/null

