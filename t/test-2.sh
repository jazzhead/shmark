#!/bin/bash
set -o nounset  # (set -u) Treat unset variables as error and exit script
#set -o errexit  # (set -e) Exit if any command returns a non-zero status
set -o pipefail # Return non-zero status if any piped commands fail
##############################################################################

# === SETUP ===

PROGNAME="${0##*/}"                             # get file basename
PROGDIR=$(cd $(dirname $0) && pwd) || exit $?   # get script directory
PROGNAME="${PROGNAME%.*}"                       # file name w/o extension

# Change to the test directory (so we can specify all paths as relative
# to the test directory):
cd "$PROGDIR" || exit $?

_shmark_variables() {
    local v
    for v in $(echo ${!SHMARK_@}); do
        printf "        %-25s = %s\n" $v "${!v/#$HOME/~}"
    done
    return 0
}

echo "--- 1) Current Environment ---"
_shmark_variables

# Unset any shmark variables in the environment so that we use the defaults:
unset ${!SHMARK_@}

echo "--- 2) After Unsetting Variables ---"
_shmark_variables

# Source shmark:
. ../shmark.sh || exit $?

echo "--- 3) After Sourcing shmark.sh ---"
_shmark_variables

