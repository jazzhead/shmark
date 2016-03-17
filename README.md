shmark
======

**Categorized shell directory bookmarking for Bash**

[shmark][1] is a collection of [Bash][2] functions for enabling shell
directory bookmarking with optional categories. It allows you to bookmark a
directory so that you can easily and quickly return to it later. You can
organize the bookmarks list in categories and rearrange the list of bookmarks
in any order. shmark also includes Bash completions allowing you to type a
partial command or directory path and then hit the tab key to auto-complete
the command.

The shmark function can be called with `shmark` or, if the optional aliases
are installed, it can be called with just `bm` (short for "bookmark"). The
other optional alias that can be installed is `go` for `shmark cd`. You can
instead define your own aliases if the included ones conflict with existing
commands or aliases on your system or if you'd just like to add aliases for
more shmark actions. The included aliases and completions can be used as
examples in those cases.


Features
--------

*   Bookmark shell directories so that they can be quickly returned to later.

*   Change to a bookmarked directory using either its list position or tab
    completion for its name/path.

*   Show a list of bookmarked directories.

*   Bookmarks can be assigned a category. The bookmarks are sorted by
    category when listing. (Some examples of category names might be
    "@CURRENT", "@NEXT" or "@PENDING" for GTD-style categories, and "RECENT"
    or "MISC" for others.)

*   Rearrange bookmarks in the saved bookmark list.

*   Change a bookmark's category.

*   Delete a bookmark.

*   Insert a bookmark into a specific list position when adding it.

*   Undo the last action.

*   Declare a default action that shmark will run when called without any
    arguments (`list` for example).


Usage
-----

The following is a typical example of basic usage (shortcuts are shown in
comments).

1.  Start by changing to a directory normally:

    ```bash
    $ cd ~/Desktop/foo
    ```

2.  Bookmark the directory with shmark:

    ```bash
    $ shmark add            # or `shmark a` or just `bm a`
    ```

3.  Change to another directory normally:

    ```bash
    $ cd ~/Desktop/bar
    ```

4.  Bookmark the directory, this time with an optional category:

    ```bash
    $ shmark add @CURRENT   # or `bm a @CURRENT`
    ```

5.  List your categorized directory bookmarks (notice that uncategorized
    bookmarks are omitted):

    ```bash
    $ shmark list           # or `bm ls`
    @CURRENT
      1) ~/Desktop/bar
    ```

6.  List all bookmarks. Uncategorized bookmarks will be listed under a
    configurable default category:

    ```bash
    $ shmark listall        # or `bm lsa`
    @CURRENT
      1) ~/Desktop/bar
    MISCELLANEOUS
      2) ~/Desktop/foo
    ```

7.  Assign a category (in this case "@NEXT") to the uncategorized bookmark
    (identified by its current list position: 2):

    ```bash
    $ shmark chcat @NEXT 2  # or `bm cc @NEXT 2`
    ```

8.  List the categorized bookmarks again to see the change:

    ```bash
    $ shmark list           # or `bm ls`
    @CURRENT
      1) ~/Desktop/bar
    @NEXT
      2) ~/Desktop/foo
    ```

9.  Change to a bookmarked directory using its list number:

    ```bash
    $ shmark cd 2           # or `bm cd 2` or `bm -2` or just `go 2`
    ~/Desktop/foo
    ```

10. Change to a bookmarked directory using tab completion:

    ```bash
    $ shmark cd bar[TAB]    # or `bm cd bar[TAB]` or `go bar[TAB]`
    ~/Desktop/bar
    ```

Those are a few of the most common commands, but there are many more commands
that can be used for things such as deleting a bookmark, moving a bookmark in
the list, inserting a bookmark into a specific list position, and more.
Here is a brief listing of the available commands:

```
$ shmark -h
Usage: shmark [-hV] [-f bookmark_file] [-#] [action] [bookmark|category]

Actions:
    add|a [CATEGORY]
    append|app [CATEGORY]
    cat
    cd|go [BOOKMARK]
    cd|go [NUMBER]
    chcat|cc [-f] CATEGORY [BOOKMARK]
    chcat|cc [-f] CATEGORY [NUMBER]
    del|rm [-f] [BOOKMARK]
    del|rm [-f] [NUMBER]
    edit|ed
    env
    help [ACTION]
    index|idx
    insert|ins NUMBER
    list|ls [-#] [CATEGORY]
    listall|lsa [-#] [CATEGORY]
    listcat|lsc
    listdir|lsd
    listunsort|lsus
    move|mv [-f] [FROM_POSITION] TO_POSITION
    print
    shorthelp
    undo

Try the "help" action for full details.
```


Configuration
-------------

shmark can be customized by exporting a few environment variables in your
`.bash_profile` or `.bashrc` file.

### Default Action

Specify a default action that shmark will run when called without any
arguments (see the output of the `-h` option or the `help` action for a list
of available actions):

```bash
export SHMARK_DEFAULT_ACTION=list
```

### Default Category

If no category is specified when adding a bookmark, the bookmark will appear
under a default category of "MISCELLANEOUS" which is always listed as the last
category. To change the name of that default category, export an environment
variable with the desired category name, for example:

```bash
export SHMARK_DEFAULT_CATEGORY=Archive
```

### Bookmarks File Name

By default, shmark will save bookmarks in a `~/var/shmark/bookmarks` file if
it finds a `~/var` directory or in `~/.shmark/bookmarks` otherwise. A custom
file path can be specified instead (including a custom parent directory for
the file is a good idea because the function creates backup and temporary
files):

```bash
export SHMARK_FILE=$HOME/.some_directory/my_shmarks
```


Installation
------------

See the [INSTALL][3] file.


Bugs
----

Please report any bugs using the GitHub [issue tracker for shmark][4].


Credits
-------

shmark was written by [Steve Wheeler](http://swheeler.com/).


License
-------

Copyright &copy; 2014--2016 Steve Wheeler.

shmark is free software available under the terms of a BSD-style (3-clause)
open source license. See the [LICENSE][5] file for details.


  [1]: http://jazzheaddesign.com/work/code/shmark/
  [2]: https://www.gnu.org/software/bash/
  [3]: INSTALL.md
  [4]: https://github.com/jazzhead/shmark/issues
  [5]: LICENSE
