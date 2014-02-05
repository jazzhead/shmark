##############################################################################
#
# Makefile for shmark
#
# @date    2014-02-04 First version
# @author  Steve Wheeler
#
##############################################################################

# Version used for distributions (when there is no git repo).
# Update before tagging release.
VERSION = 0.0.0

SHELL   = /bin/sh


# If run from a git repo, then override the version above with
# a version derived from git tags formatted as `v[0-9]*`.
ifneq (,$(wildcard .git))
VERSION = $(subst v,,$(shell git describe --match "v[0-9]*" --dirty --always))
# NOTE: Remove the `--always` option to exit if git can't find a tag
#       instead of falling back to an abbreviated commit hash.
endif


INSTALL     = install

PREFIX     := $(HOME)
BUILD       = _build
INSTOPTS    = -pSv
INSTMODE    = -m 0600
INSTDIRMODE = -m 0700

# Source files:
SRC_MAIN         = shmark.sh
SRC_EXTRA        = shmark_extra.sh
#
# (NOTE: These source completion file names are just used in the help
# text. The target rules compute the names as needed because the actual
# target names are the same as the function names.)
SRC_COMP        := $(subst .sh,_completion.sh,$(SRC_MAIN))
SRC_COMP_EXTRA  := $(subst .sh,_completion.sh,$(SRC_EXTRA))

# Build directories:
BUILD_FUNC      := $(BUILD)/functions
BUILD_COMP      := $(BUILD)/completion
# Build targets:
TARGET_FUNC     := $(addprefix $(BUILD_FUNC)/,$(SRC_MAIN) $(SRC_EXTRA))
TARGET_COMP     := $(addprefix $(BUILD_COMP)/,$(SRC_MAIN) $(SRC_EXTRA))

# Install directories:
INSTDIR_FUNC    := $(PREFIX)/.bash_functions.d
INSTDIR_COMP    := $(PREFIX)/.bash_completion.d
# Install targets:
#   by directory:
FUNC_INSTALL    := $(addprefix $(INSTDIR_FUNC)/,$(SRC_MAIN) $(SRC_EXTRA))
COMP_INSTALL    := $(addprefix $(INSTDIR_COMP)/,$(SRC_MAIN) $(SRC_EXTRA))
#   for targets:
INSTALL_ALL     := $(FUNC_INSTALL) $(COMP_INSTALL)
INSTALL_DEFAULT := $(filter-out %_extra.sh,$(INSTALL_ALL))
INSTALL_MIN     := $(filter-out %_extra.sh,$(FUNC_INSTALL))


# ==== PHONY TARGETS =========================================================

all: $(TARGET_FUNC) $(TARGET_COMP)
	@echo "--->  ** Build complete"

install: all $(INSTALL_DEFAULT)
	@echo "--->  ** Install complete"
	@echo "$$POST_INSTALL_TEXT"

install-min: all $(INSTALL_MIN)
	@echo "--->  ** Install complete"
	@echo "$$POST_INSTALL_TEXT"

install-all: all $(INSTALL_ALL)
	@echo "--->  ** Install complete"
	@echo "$$POST_INSTALL_TEXT"

help:
	@echo "$$HELPTEXT"

test:
	@if [ -f t/lib/vendor/tap-functions.sh ]; then \
		prove -f ./t/[0-9][0-9][0-9][0-9]-*.sh; \
	else \
		echo "The tests require a third-party library to be downloaded and"; \
		echo "placed in the 't/lib/vendor' directory. Download the file from:"; \
		echo "http://svn.solucorp.qc.ca/repos/solucorp/JTap/trunk/tap-functions"; \
	fi

clean:
	@rm -vr $(BUILD)
	@echo "--->  Deleted $(BUILD) directory"

uninstall:
	@echo "--->  Uninstalling shmark files..."
	@-rm -v $(INSTALL_ALL) 2>/dev/null || true  # ignore missing file errors

.PHONY: all test help clean uninstall install install-all install-min


# ==== FILE TARGETS ==========================================================

# Static Pattern Rule Syntax:
#     targets ...: target-pattern: prereq-patterns ...
#         recipe

# ---- Build targets

$(TARGET_FUNC): $(BUILD_FUNC)/%: %
	$(call build-file,$(@D),$<,$@)

# Completion source files will be renamed to be the same as the function files,
# but in a separate build directory:
$(TARGET_COMP): $(BUILD_COMP)/%.sh: %_completion.sh
	$(call build-file,$(@D),$<,$@)

# ---- Install targets

$(FUNC_INSTALL): $(INSTDIR_FUNC)/%: %
	$(call install-file,$(@D),$(BUILD_FUNC)/$<)

$(COMP_INSTALL): $(INSTDIR_COMP)/%: %
	$(call install-file,$(@D),$(BUILD_COMP)/$<)


# ==== FUNCTIONS =============================================================

define install-file
	@#echo "--->  Installing '$2' into '$1'"
	@$(INSTALL) -dv $(INSTDIRMODE) "$1" && \
	$(INSTALL) $(INSTOPTS) $(INSTMODE) "$2" "$1"
endef

define build-file
	@#echo "--->  Building '$2' as '$3'"
	@[ -d "$1" ] || { \
		echo "--->  Creating directory \"$1\"..."; \
		mkdir -pvm0700 $1; \
	}
	@if [ 0 = $$(grep -cm1 '@@VERSION@@' "$2") ]; then \
		echo "--->  Copying $2 to $3..."; \
		cp -p "$2" "$3"; \
	else \
		echo "--->  Processing $2 to insert VERSION into $3..."; \
		LANG=C sed -e 's/@@VERSION@@/$(VERSION)/g' < "$2" > "$3"; \
	fi
endef


# ==== MULTILINE TEXT VARIABLES ==============================================

define HELPTEXT

Make Commands for shmark
------------------------

make
make all
    Copy all source files to the build directory performing any
    substitutions such as inserting the version number.

make help
    Display this help.

make install
    Install the main shmark functions file and its Bash completion
    file. ($(SRC_MAIN), $(SRC_COMP))

make install-min
    Minimal install. Only install the main shmark functions file
    without installing the Bash completion file. ($(SRC_MAIN))

make install-all
    Install the main shmark function and completion files along with
    the two extra files that provide short aliases and completions for
    those aliases. ($(SRC_MAIN), $(SRC_COMP), $(SRC_EXTRA),
    $(SRC_COMP_EXTRA))

make uninstall
    Uninstall all installed shmark files.

make test
    Run tests on the source files. (Build files are essentially the same
    with just some placeholder text replaced, so they aren't tested.)

make clean
    Delete all build files.

Installation Notes
------------------

Function (and alias) files will be installed in:

    $(subst $(HOME),~,$(INSTDIR_FUNC))

Completion files will be installed in:
    
    $(subst $(HOME),~,$(INSTDIR_COMP))

The files in those directories need to loaded into your shell
environment by sourcing them from your ~/.bash_profile or ~/.bashrc.

endef
export HELPTEXT

# ----

define POST_INSTALL_TEXT

****************************************
***  POST-INSTALLATION INSTRUCTIONS  ***
****************************************

The installed files must be enabled by sourcing them into your shell
environment. If you have multiple function files and/or completion
files, as you would if you installed all of the shmark files, enable
the files by adding the following to your ~/.bash_profile or ~/.bashrc
file:

    # Enable custom Bash functions:
    if [ -d $(subst $(HOME),~,$(INSTDIR_FUNC)) ]; then
        for f in $(subst $(HOME),~,$(INSTDIR_FUNC))/*.sh; do
            . "$$f"
        done
        unset f
    fi

    # Enable custom Bash completions:
    if [ -d $(subst $(HOME),~,$(INSTDIR_COMP)) ]; then
        for f in $(subst $(HOME),~,$(INSTDIR_COMP))/*.sh; do
            . "$$f"
        done
        unset f
    fi

If you only have single files to enable, you can could still use code
like the above, or you could instead use lines such as:

    . $(subst $(HOME),$$HOME,$(INSTDIR_FUNC))/shmark.sh

And:

    . $(subst $(HOME),$$HOME,$(INSTDIR_COMP))/shmark.sh

endef
export POST_INSTALL_TEXT

