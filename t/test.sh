#!/bin/bash
#
# From the main project directory (not this 't' test directory), run:
#
#     prove -f ./t/test.sh
#
##############################################################################

# === SETUP ===

# Save the script's directory (the test directory) into a variable if
# needed later. (Not all tests will need it.)
PROGDIR=$(cd $(dirname $0) && pwd) || exit $?

# Change to the test directory (so we can specify all paths as relative
# to the test directory):
cd "$PROGDIR" || exit $?
# Or if the variable isn't needed, just:
#cd $(dirname $0) || exit $?

# Source the TAP functions library:
. lib/vendor/tap-functions.sh || exit $?

# === MAIN ===

plan_tests 2
is   "foo" "foo" "foo is foo"
isnt "foo" "bar" "foo isn't bar"

# === END ===

# Very LAST thing - change back to the original directory. Might not be needed.
cd - > /dev/null


# --- DEBUG: Workout the script directory stuff ---
#echo "original directory: $PWD"
#echo
#
#PROGDIR=$(cd $(dirname $0) && pwd)
#
#echo "program dir: $PROGDIR"
#echo "current dir: $PWD"
#echo
#echo "changing to program dir..."
#cd "$PROGDIR"
#echo "current dir: $PWD"
#echo
#echo "changing back..."
#cd - > /dev/null
#echo "current dir: $PWD"
#echo
#echo "changing directly to program directory..."
#cd $(dirname $0)
#echo "current directory: $PWD"
#echo
#echo "changing back..."
#cd - > /dev/null
#echo "current dir: $PWD"
# ------------------------------------------------
