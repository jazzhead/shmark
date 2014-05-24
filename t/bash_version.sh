#!/usr/bin/env bash
#
# From the main project directory (not this 't' test directory), run:
#
#     prove -fv ./t/bash_version.sh           # prove uses shebang interpreter
#     prove -fv -e bash ./t/bash_version.sh       # specify another bash
#     prove -fv -e /bin/bash ./t/bash_version.sh  # specify another bash
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

diag "BASH_VERSION = $BASH_VERSION"

# === END ===

# Very LAST thing - change back to the original directory. Might not be needed.
cd - > /dev/null

