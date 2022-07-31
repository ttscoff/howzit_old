# Howzit

A command-line reference tool for tracking project build systems

Howzit is a tool that allows you to keep Markdown-formatted notes about a project's tools and procedures. It functions as an easy lookup for notes about a particular task, as well as a task runner to automatically execute appropriate commands.

<!--README-->

## Features

- Match topic titles with any portion of title
- Automatic pagination of output, with optional Markdown highlighting
- Use `@run()`, `@copy()`, and `@open()` to perform actions within a build notes file
- Use `@include()` to import another topic's tasks
- Use fenced code blocks to include/run embedded scripts
- Sets iTerm 2 marks on topic titles for navigation when paging is disabled
- Inside of git repositories, howzit will work from subdirectories, assuming build notes are in top level of repo
- Templates for easily including repeat tasks
- Grep topics for pattern and choose from matches

## Getting Started

Howzit is a simple, self-contained script (at least until I get stupid and make a gem out of it).

### Prerequisites

- Ruby 2.4+ (It probably works on older Rubys, but is untested prior to 2.4.1.)
- Optional: if [`bat`](https://github.com/sharkdp/bat) is available it will page with that
- Optional: [`mdless`](https://github.com/ttscoff/mdless) or [`mdcat`](https://github.com/lunaryorn/mdcat) for formatting output

### Installing

#### One-Line Install

You can install `howzit` by running:

    curl -SsL 'https://raw.githubusercontent.com/ttscoff/howzit/main/install.sh'|bash

#### Manual Install

[Clone the repo](https://github.com/ttscoff/howzit/) or just [download the self-contained script](https://github.com/ttscoff/howzit/blob/main/howzit). Save the script as `howzit` to a folder in your $PATH and make it executable with:

    chmod a+x howzit

## Anatomy of a Build Notes File

Howzit relies on there being a file in the current directory with a name that starts with "build" or "howzit" and an extension of `.md`, `.txt`, or `.markdown`, e.g. `buildnotes.md` or `howzit.txt`. This note contains topics such as "Build" and "Deploy" with brief notes about each topic in Markdown (or just plain text) format.

> Tip: Add "buildprivate.md" to your global gitignore (`git config --get core.excludesfile`). In a project where you don't want to share your build notes, just name the file "buildprivate.md" instead of "buildnotes.md" and it will automatically be ignored.

If there are files that match the "build*" pattern that should not be recognized as build notes by howzit, add them to `~/.config/howzit/ignore.yaml`. This file is a simple list of patterns that should be ignored when scanning for build note files. Use `(?:i)` at the beginning of a pattern to make it case insensitive.

The topics of the notes are delineated by Markdown headings, level 2 or higher, with the heading being the title of the topic. I split all of mine apart with h2s. For example, a short one from the little website I was working on yesterday:

    ## Build

    gulp js: compiles and minifies all js to dist/js/main.min.js

    gulp css: compass compile to dist/css/

    gulp watch

    gulp (default): [css,js]

    ## Deploy

    gulp sync: rsync /dist/ to scoffb.local

    ## Package management

    yarn

    ## Components

    - UIKit

Howzit expects there to only be one header level used to split topics. Anything before the first header is ignored. If your topics use h2 (`##`), you can use a single h1 (`#`) line at the top to title the project.

### @Commands

You can include commands that can be executed by howzit. Commands start at the beginning of a line anywhere in a topic. Only one topic's commands can be run at once, but all commands in the topic will be executed when howzit is run with `-r`. Commands can include any of:

- `@run(COMMAND)`

    The command in parenthesis will be executed as is from the current directory of the shell
- `@copy(TEXT)`

    On macOS this will copy the text within the parenthesis to the clipboard. An easy way to offer a shortcut to a longer build command while still allowing it to be edited prior to execution.
- `@open(FILE|URL)`

    Will open the file or URL using the default application for the filetype. On macOS this uses the `open` command, on Windows it uses `start`, and on Linux it uses `xdg-open`, which may require separate installation.
- `@include(TOPIC)`

    Includes all tasks from another topic, matching the name (partial match allowed) and returning first match.

### Run blocks (embedded scripts)

For longer scripts you can write shell scripts and then call them with `@run(myscript.sh)`. For those in-between cases where you need a few commands but aren't motivated to create a separate file, you can use fenced code blocks with `run` as the language.

    ```run OPTIONAL TITLE
    #!/bin/bash
    # Commands...
    ```

The contents of the block will be written to a temporary file and executed with `/bin/sh -c`. This means that you need a hashbang at the beginning to tell the shell how to interpret the script. If no hashbang is given, the script will be executed as a `sh` script.

Example:

    ```run Just Testing
    #!/bin/bash
    echo "Just needed a few lines"
    echo "To get through all these commands"
    echo "Almost there!"
    say "Phew, we did it."
    ```

Multiple blocks can be included in a topic. @commands take priority over code blocks and will be run first if they exist in the same topic.

### Variables

When running commands in a topic, you can use a double dash (`--`) in the command line (surrounded by spaces) and anything after it will be interpreted as shell arguments. These can be used in commands with `$` placeholders. `$1` represents the first argument, counting up from there. Use `$@` to pass all arguments as a shell-escaped string.

For example, the topic titled "Test" could contain an @run command with placeholders:

    ## Test
    @run(./myscript.sh $@)

Then you would run it on the command line using:

    howzit -r test -- -x "arg 1" arg2

This would execute the command as `./myscript.sh -x arg\ 1 arg2`.

Placeholders can be used in both commands and run blocks. If a placeholder doesn't have an argument supplied, it's not replaced (e.g. leaves `$2` in the command).

### Templates and metadata

You can create templates to reuse topics in multiple build note files. Create files using the same formatting as a build note in `~/.config/howzit/templates` with `.md` extensions. Name them the way you'll reference them:

    ~/.config/howzit/templates
    - markdown.md
    - ruby.md
    - obj-c.md

> Use `howzit --templates` for a list of templates you've created, along with the topics they'll add when included. Just in case you make a bunch and can't remember what they're called or what they do. I was just planning ahead.

You can then include the topics from a template in any build note file using a `template:` key at the top of the file.

Howzit allows MultiMarkdown-style metadata at the top of a build notes file. These are key/value pairs separated by a colon:

    template: markdown
    key 1: value 1
    key 2: value 2

The template key can include multiple template names separated by commas.

Additional metadata keys populate variables you can then use inside of your templates (and build notes), using `[%key]`. You can define a default value for a placeholder with `[%key:default]`.

For example, in the template `markdown.md` you could have:

    ### Spellcheck

    Check spelling of all Markdown files in git repo.

    ```run
    #!/bin/bash
    for dir in [%dirs:.]; do
        cd "$dir"
        /Users/ttscoff/scripts/spellcheck.bash
        cd -
    done
    ```

Then, in a `buildnotes.md` file in your project, you could include at the top of the file:

    template: markdown
    dirs: . docs

    # My Project...

If you only want to include certain topics from a template file, use the format `template_name[topic]` or include multiple topics separated by commas: `template_name[topic 1, topic 2]`. You can also use `*` as a wildcard, where `template_name[build*]` would include topics "Build" and "Build and Run".

If a topic in the current project's build note has an identical name to a template topic, the local topic takes precedence. This allows you to include a template but modify just a part of it by duplicating the topic title.

Templates can include other templates with a `template:` key at the top of the template.

You can define what metadata keys are required for the template using a `required:` key at the top of the template. For example, if the template `script.md` uses a placeholder `[%executable]` that can't have a default value as it's specific to each project, you can add:

    required: executable 

at the top of `project.md`. If the template is included in a build notes file and the `executable:` key is not defined, an error will be shown.

## Using howzit

Run `howzit` on its own to view the current folder's buildnotes.

Include a topic name to see just that topic, or no argument to display all.

    howzit build

Use `-l` to list all topics.

    howzit -l

Use `-r` to execute any @copy, @run, or @open commands in the given topic. Options can come after the topic argument, so to run the commands from the last topic you viewed, just hit the up arrow to load the previous command and add `-r`.

    howzit build -r

Other options:

    Usage: howzit [OPTIONS] [TOPIC]

    Show build notes for the current project (buildnotes.md). Include a topic name to see just that topic, or no argument to display all.

    Options:
        -c, --create                     Create a skeleton build note in the current working directory
        -e, --edit                       Edit buildnotes file in current working directory using editor.sh
            --grep PATTERN               Display sections matching a search pattern
        -L, --list-completions           List topics for completion
        -l, --list                       List available topics
        -m, --matching TYPE              Topics matching type
                                         (partial, exact, fuzzy, beginswith)
        -R, --list-runnable              List topics containing @ directives (verbose)
        -r, --run                        Execute @run, @open, and/or @copy commands for given topic
        -s, --select                     Select topic from menu
        -T, --task-list                  List topics containing @ directives (completion-compatible)
        -t, --title                      Output title with build notes
        -q, --quiet                      Silence info message
            --verbose                    Show all messages
        -u, --upstream                   Traverse up parent directories for additional build notes
            --show-code                  Display the content of fenced run blocks
        -w, --wrap COLUMNS               Wrap to specified width (default 80, 0 to disable)
            --edit-config                Edit configuration file using editor.sh
            --title-only                 Output title only
            --templates                  List available templates
            --[no-]color                 Colorize output (default on)
            --[no-]md-highlight          Highlight Markdown syntax (default on), requires mdless or mdcat
            --[no-]pager                 Paginate output (default on)
        -h, --help                       Display this screen
        -v, --version                    Display version number


## Configuration

Some of the command line options can be set as defaults. The first time you run `howzit`, a YAML file is written to `~/.config/howzit/howzit.yaml`. You can open it in your default editor automatically by running `howzit --edit-config`. It contains the available options:

    ---
    :color: true
    :highlight: true
    :paginate: true
    :wrap: 80
    :output_title: false
    :highlighter: auto
    :pager: auto
    :matching: partial
    :include_upstream: false
    :log_level: 1

If `:color:` is false, output will not be colored, and markdown highlighting will be bypassed.

If `:color:` is true and `:highlight:` is true, the `:highlighter:` option will be used to add Markdown highlighting.

If `:paginate:` is true, the `:pager:` option will be used to determine the tool used for pagination. If it's false and you're using iTerm, "marks" will be added to topic titles allowing keyboard navigation.

`:highlighter:` and `:pager:` can be set to `auto` (default) or a command of your choice for markdown highlighting and pagination.

`:matching:` can be "partial", "beginswith", "fuzzy" or "exact" (see below).

If `:include_upstream:` is true, build note files in parent directories will be included in addition to the current directory. Priority goes from current directory to root in descending order, so the current directory is top priority, and a build notes file in / is the lowest. Higher priority topics  will not be overwritten by a duplicate topic from a lower priority note.

Set `:log_level:` to 0 for debug messages, or 3 to suppress superfluous info messages.

### Matching

All matching is case insensitive. This setting can be overridden by the `--matching TYPE` flag on the command line.

- `:matching: partial`

    Partial is the default, search matches any part of the topic title.

    _Example:_ `howzit other` matches 'An<mark>other</mark> Topic'.

- `:matching: beginswith`

    Matches from the start of the title.

    _Example:_ `howzit another` matches '<mark>Another</mark> Topic', but neither 'other' or 'topic' will.

- `:matching: fuzzy`

    Matches anything containing the search characters in order, no matter what comes between them.

    _Example:_ `howzit asct` matches '<mark>A</mark>nother <mark>S</mark>e<mark>c</mark><mark>t</mark>ion'

- `:matching: exact`

    Case insensitive but must match the entire title.

    _Example:_ Only `howzit another topic` will match 'Another Topic'

### Pager

If set to `auto`, howzit will look for pagers in this order, using the first one it finds available:

- $GIT_PAGER
- $PAGER
- bat
- less
- more
- cat
- pager

If you're defining your own, make sure to include any flags necessary to handle the output. If you're using howzit's coloring, for example, you need to specify any options needed to display ANSI escape sequences (e.g. `less -r`).

### Highlighter

If set to `auto` howzit will look for markdown highlighters in this order, using the first it finds available:

- mdcat
- mdless

If you're combining a highlighter with howzit's pagination, include any flags needed to disable the highlighter's pagination (e.g. `mdless --no-pager`).

## Shell Integration

I personally like to alias `bld` to `howzit -r`. If you define a function in your shell, you can have it default to "build" but accept an alternate argument. There's an example for Fish included, and in Bash it would be as simple as `howzit -r ${1:build}`.

For completion you can use `howzit -L` to list all topics, and `howzit -T` to list all "runnable" topics (topics containing an @directive or run block). Completion examples for Fish are included in the `fish` directory.

## Similar Projects

- [mask](https://github.com/jakedeichert/mask/)
- [maid](https://github.com/egoist/maid)
- [saku](https://github.com/kt3k/saku)

There are a few projects that tackle the same concept (a Markdown makefile). Most of them are superior task runners, so if you're looking for a `make` replacement, I recommend exploring the links above. What I like about `howzit` (and what keeps me from switching) is that it's documentation-first, and that I can display the description for each topic on the command line. The others also don't have options for listing topics or runnable tasks, so I can't use completion (or my cool script that adds available tasks to my Macbook Pro Touch Bar...). But no, I don't think `howzit` is as good an overall task runner as `mask` or `maid`.

## Roadmap

- Recognize header hierarchy, allow showing/running all sub-topics

## Author

**Brett Terpstra** - [brettterpstra.com](https://brettterpstra.com)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

<!--END README-->

