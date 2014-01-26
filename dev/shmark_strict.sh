#!/bin/bash
set -o nounset  # (set -u) Treat unset variables as error and exit script
set -o errexit  # (set -e) Exit if any command returns a non-zero status
set -o pipefail # Return non-zero status if any piped commands fail
#############################################################################
#
# This is just a wrapper script that sources the shmark.sh functions so that
# those functions can be tested without having to source them into the shell
# environment. The wrapper script also allows stricter testing by setting extra
# options such as 'nounset' and 'errexit'. NOTE: Tests should be run both with
# and without the 'errexit' and other options set above. Run with the options
# set when writing and testing the functions. Then comment the options out to
# simulate the way the functions are likely to be run when sourced into the
# shell environment.
#
# NOTE: Shell scripts like this can't change directories for a shell, so to
# fully test any functions that change directories, the functions file will
# need to be sourced into the shell environment and tested directly from the
# shell instead of this wrapper script.
#
# @date    2014-01-21 First version
# @author  Steve Wheeler
#
##############################################################################
PROGNAME="${0##*/}"

. ./shmark.sh

#echo >&2 "DEBUG: ${PROGNAME}: running..."

shmark "$@"  # call the main function (all other functions are private)
