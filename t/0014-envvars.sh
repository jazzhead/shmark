#!/usr/bin/env bash
set -o nounset  # (set -u) Treat unset variables as error and exit script
#set -o errexit  # (set -e) Exit if any command returns a non-zero status
set -o pipefail # Return non-zero status if any piped commands fail
##############################################################################
#
# Tests for shmark
#
# @date    2014-05-23 Last modified
# @date    2014-01-30 First version
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

# Source custom test functions library:
. lib/shmark_test_functions.sh || exit $?

# Source third-party TAP functions library:
. lib/vendor/tap-functions.sh || exit $?

# === MAIN ===

plan_tests 5

SAMPLE_FILE='data/bookmarks-06.txt'

# 1
diag "*** Set SHMARK_FILE environment variable and source shmark.sh"
SHMARK_FILE="$SAMPLE_FILE" # set environment variable
. ../shmark.sh || exit $?  # source shmark
EXPECTED=$(cat "data/expected/${PROGNAME}/001.txt")
RESULT=$(shmark listall)
#while IFS= read -r line; do
#    diag "$line"
#done <<< "$RESULT"
is "$RESULT" "$EXPECTED" "shmark listall - use SHMARK_FILE env var"

# 2
diag "*** Set SHMARK_DEFAULT_CATEGORY env var and source shmark.sh"
SHMARK_DEFAULT_CATEGORY="ENVVAR_TEST" # set environment variable
. ../shmark.sh || exit $?             # source shmark
EXPECTED=$(cat "data/expected/${PROGNAME}/002.txt")
RESULT=$(shmark listall)
#while IFS= read -r line; do
#    diag "$line"
#done <<< "$RESULT"
is "$RESULT" "$EXPECTED" \
    "shmark listall - use SHMARK_DEFAULT_CATEGORY env var"

# 3
diag "*** Set SHMARK_DEFAULT_ACTION env var and source shmark.sh"
SHMARK_DEFAULT_ACTION="listall" # set environment variable
. ../shmark.sh || exit $?       # source shmark
EXPECTED=$(cat "data/expected/${PROGNAME}/002.txt")
RESULT=$(shmark)
#while IFS= read -r line; do
#    diag "$line"
#done <<< "$RESULT"
is "$RESULT" "$EXPECTED" \
    "shmark - use SHMARK_DEFAULT_ACTION=listall env var"

# 4
diag "*** Set SHMARK_FILE env var, source shmark.sh,"
diag "***   unset SHMARK_DEFAULT_CATEGORY"
SHMARK_FILE="$SAMPLE_FILE"  # set environment variable
. ../shmark.sh || exit $?   # source shmark to set defaults
unset SHMARK_DEFAULT_CATEGORY
shmark listall >/dev/null 2>&1 # should now succeed (failure expected before)
retval=$?
is $retval 0 "shmark listall - should handle unset SHMARK_DEFAULT_CATEGORY"

# 5
diag "*** Unset SHMARK_DEFAULT_ACTION"
unset ${!SHMARK_@}
SHMARK_FILE="$SAMPLE_FILE"  # set environment variable
. ../shmark.sh || exit $?   # source shmark to reset defaults
unset SHMARK_DEFAULT_ACTION
shmark listall >/dev/null 2>&1 # should succeed
retval=$?
is $retval 0 \
    "shmark [any] - should handle unset SHMARK_DEFAULT_ACTION"

# === END ===

# Change back to the original directory:
cd - > /dev/null

