#!/usr/bin/env bash
set -o nounset  # (set -u) Treat unset variables as error and exit script
#set -o errexit  # (set -e) Exit if any command returns a non-zero status
set -o pipefail # Return non-zero status if any piped commands fail
##############################################################################
#
# Tests for shmark
#
# @date    2014-05-23 Last modified
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

# Source the TAP functions library:
. lib/vendor/tap-functions.sh || exit $?

# === MAIN ===

plan_tests 1

EXPECTED=$(cat "data/expected/${PROGNAME}.txt")
RESULT=$(shmark -f "data/bookmarks-04.txt" listall)
while IFS= read -r line; do
    diag "$line"
done <<< "$RESULT"
is "$RESULT" "$EXPECTED" "shmark list (wrap long lines)"

# === END ===

# Change back to the original directory:
cd - > /dev/null

