To run all tests, from the main project directory (not this 't' test
directory), run:

    make test

which runs:

    prove -f ./t/[0-9][0-9][0-9][0-9]-*.sh

Test scripts can also be run individually with:

    bash t/<test_name>.sh

The test scripts use a shebang line of:

    #!/usr/bin/env bash

That way 'prove' will use the correct interpreter. We want to test
whatever bash is in the $PATH rather than a hardcoded '/bin/bash'. To
test a different version of bash, add the '--exec' option to 'prove',
for example:

    prove -f -e /bin/bash ./t/[0-9][0-9][0-9][0-9]-*.sh

NOTE: The tests require a third-party library to be downloaded, placed
in the 't/lib/vendor' directory, and renamed with a '.sh' extension.
Download the file from:

http://svn.solucorp.qc.ca/repos/solucorp/JTap/trunk/tap-functions
