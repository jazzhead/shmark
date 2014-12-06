Installation
============

[shmark] is a Bash functions file along with some optional aliases and Bash
completion files. These files need to be sourced into your shell environment.
To install the files and enable them:

1.  `cd` to the directory containing the shmark source code and run:

    ```
    $ make
    ```

2.  Run _one_ of the following commands depending on which files you wish to
    install:

    ```
    $ make install      # Default: main functions and completion files.
    $ make install-all  # Same as the default, plus optional aliases.
    $ make install-min  # Only the main functions file; no completions or aliases.
    ```

    Details:

    *   `make install` installs the main shmark functions file and its
        Bash completion file in the `~/.bash_functions.d` and
        `~/.bash_completion.d` directories respectively. If you'd rather
        install them somewhere else, then only run `make` and then copy or
        move the files from the `build` directory to your desired location.

    *   `make install-all` installs two extra files in addition to the main
        shmark functions and completion files installed by `make install`.
        The extra files provide the short `bm` and `go` aliases along with
        completions for those aliases. You could instead just use those as
        examples to define your own aliases and completions.

    *   `make install-min` only installs the main functions file without
        installing the completions or aliases.

3.  To enable the functions, aliases, and completions, you'll need to source
    the files into your shell environment. If you installed the files in the
    default directories, you could add something like the following to your
    `~/.bash_profile` or `.bashrc` file:

    ```bash
    # Enable custom Bash functions:
    if [ -d ~/.bash_functions.d ]; then
        for f in ~/.bash_functions.d/*.sh; do
            . "$f"
        done
        unset f
    fi

    # Enable custom Bash completions:
    if [ -d ~/.bash_completion.d ]; then
        for f in ~/.bash_completion.d/*.sh; do
            . "$f"
        done
        unset f
    fi
    ```

    If you only have single files to enable, you could still use code like the
    above, or you could instead just use lines such as:

    ```bash
    . ~/.bash_functions.d/shmark.sh
    ```

    And:

    ```bash
    . ~/.bash_completion.d/shmark.sh
    ```


  [shmark]: http://jazzheaddesign.com/work/code/shmark/
