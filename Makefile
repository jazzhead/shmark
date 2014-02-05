##############################################################################
#
# Makefile for shmark
#
# @date    2014-02-05 Last modified
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


# Locations
PREFIX      := $(HOME)
FUNC_DIR    := $(PREFIX)/.bash_functions.d
COMP_DIR    := $(PREFIX)/.bash_completion.d
BUILD       := _build
FUNC_BUILD  := $(BUILD)/functions
COMP_BUILD  := $(BUILD)/completion

# Tools
RM          := rm -rfv
CP          := cp -p
SED         := LANG=C sed
MKDIR       := mkdir -pvm0700
PROVE       := prove -f

# Install tool and options
INSTALL     := install
INSTOPTS    := -pSv
INSTMODE    := -m 0600
INSTDIRMODE := -m 0700

# Source files
SRC_MAIN    := shmark.sh
SRC_EXTRA   := shmark_extra.sh

# (NOTE: These source completion file names are just used in the help
# text. The target rules compute the names as needed because the actual
# target names are the same as the function names.)
SRC_COMP        := $(subst .sh,_completion.sh,$(SRC_MAIN))
SRC_COMP_EXTRA  := $(subst .sh,_completion.sh,$(SRC_EXTRA))

# Build targets
TARGET_FUNC     := $(addprefix $(FUNC_BUILD)/,$(SRC_MAIN) $(SRC_EXTRA))
TARGET_COMP     := $(addprefix $(COMP_BUILD)/,$(SRC_MAIN) $(SRC_EXTRA))

# Install targets
#   by directory:
FUNC_INSTALL_FILES    := $(addprefix $(FUNC_DIR)/,$(SRC_MAIN) $(SRC_EXTRA))
COMP_INSTALL_FILES    := $(addprefix $(COMP_DIR)/,$(SRC_MAIN) $(SRC_EXTRA))
#   by rule:
ALL_INSTALL_FILES     := $(FUNC_INSTALL_FILES) $(COMP_INSTALL_FILES)
DEFAULT_INSTALL_FILES := $(filter-out %_extra.sh,$(ALL_INSTALL_FILES))
MIN_INSTALL_FILES     := $(filter-out %_extra.sh,$(FUNC_INSTALL_FILES))


# ==== TARGETS ===============================================================

all: $(TARGET_FUNC) $(TARGET_COMP)
	@echo "--->  ** Build complete"

install: all $(DEFAULT_INSTALL_FILES)
	@echo "--->  ** Installation complete"
	@echo "$$POST_INSTALL_TEXT"

install-min: all $(MIN_INSTALL_FILES)
	@echo "--->  ** Installation complete"
	@echo "$$POST_INSTALL_TEXT"

install-all: all $(ALL_INSTALL_FILES)
	@echo "--->  ** Installation complete"
	@echo "$$POST_INSTALL_TEXT"

help:
	@echo "$$HELPTEXT"

test:
	@echo "--->  ** Running shmark tests..."
	@echo "--->  (Source files tested because build files are almost identical)"
	@if [ -f t/lib/vendor/tap-functions.sh ]; then \
		$(PROVE) ./t/[0-9][0-9][0-9][0-9]-*.sh; \
	else \
		echo "The tests require a third-party library to be downloaded and"; \
		echo "placed in the 't/lib/vendor' directory. Download the file from:"; \
		echo "http://svn.solucorp.qc.ca/repos/solucorp/JTap/trunk/tap-functions"; \
	fi
	@echo "--->  ** Testing complete"

check: test

clean:
	@echo "--->  ** Deleting '$(BUILD)' directory..."
	@$(RM) $(BUILD)
	@echo "--->  ** Deletion complete"

uninstall:
	@echo "--->  ** Uninstalling shmark files..."
	@-$(RM) $(ALL_INSTALL_FILES) 2>/dev/null || true # ignore missing file error
	@echo "--->  ** Uninstall complete"

.PHONY: all test check help clean uninstall install install-all install-min


# ==== DEPENDENCIES ==========================================================

# Static Pattern Rule Syntax:
#     targets ...: target-pattern: prereq-patterns ...
#         recipe

# Build function files
$(TARGET_FUNC): $(FUNC_BUILD)/%: %
	$(call build-file,$(@D),$<,$@)

# Build completion files
#   (Completion source files will be renamed to be the same as the function
#   files, but in a separate build directory.)
$(TARGET_COMP): $(COMP_BUILD)/%.sh: %_completion.sh
	$(call build-file,$(@D),$<,$@)

# Install function files
$(FUNC_INSTALL_FILES): $(FUNC_DIR)/%: %
	$(call install-file,$(@D),$(FUNC_BUILD)/$<)

# Install completion files
$(COMP_INSTALL_FILES): $(COMP_DIR)/%: %
	$(call install-file,$(@D),$(COMP_BUILD)/$<)


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
		$(MKDIR) $1; \
	}
	@if [ 0 = $$(grep -cm1 '@@VERSION@@' "$2") ]; then \
		echo "--->  Copying $2 to $3..."; \
		$(CP) "$2" "$3"; \
	else \
		echo "--->  Processing $2 to insert VERSION into $3..."; \
		$(SED) -e 's/@@VERSION@@/$(VERSION)/g' < "$2" > "$3"; \
	fi
endef


# ==== TEXT VARIABLES ========================================================

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

    $(subst $(HOME),~,$(FUNC_DIR))

Completion files will be installed in:
    
    $(subst $(HOME),~,$(COMP_DIR))

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
    if [ -d $(subst $(HOME),~,$(FUNC_DIR)) ]; then
        for f in $(subst $(HOME),~,$(FUNC_DIR))/*.sh; do
            . "$$f"
        done
        unset f
    fi

    # Enable custom Bash completions:
    if [ -d $(subst $(HOME),~,$(COMP_DIR)) ]; then
        for f in $(subst $(HOME),~,$(COMP_DIR))/*.sh; do
            . "$$f"
        done
        unset f
    fi

If you only have single files to enable, you can could still use code
like the above, or you could instead use lines such as:

    . $(subst $(HOME),$$HOME,$(FUNC_DIR))/shmark.sh

And:

    . $(subst $(HOME),$$HOME,$(COMP_DIR))/shmark.sh

endef
export POST_INSTALL_TEXT

