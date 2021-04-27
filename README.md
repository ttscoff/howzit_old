# Howzit

A command-line reference tool for tracking project build systems

## Getting Started

Howzit is a simple, self-contained script (at least until I get stupid and make a gem out of it).

### Prerequisites

- Ruby 2.4+ (It probably works on older Rubys, but is untested prior to 2.4.1.)
- Optional: if [`bat`](https://github.com/sharkdp/bat) is available it will page with that
- Optional: [`mdless`](https://github.com/ttscoff/mdless) or [`mdcat`](https://github.com/lunaryorn/mdcat) for formatting output

### Installing

Save the script as `howzit` to a folder in your $PATH and make it executable with:

    chmod a+x howzit

## Usage

### Setup

Howzit relies on there being a file in the current directory with a name that starts with "build" and an extension of `.md`, `.txt`, or `.markdown`, e.g. `buildnotes.md`. This note contains sections such as "Build" and "Deploy" with brief notes about each topic in Markdown (or just plain text) format.

The sections of the notes are delineated by Markdown headings, level 2 or higher, with the heading being the title of the section. I split all of mine apart with h2s. For example, a short one from the little website I was working on yesterday:

```markdown
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
```

Howzit expects there to only be one header level used to split sections. Anything before the first header is ignored.

### @Commands

You can include commands that can be executed by howzit. Commands start at the beginning of a line anywhere in a section. Only one section's commands can be run at once, but all commands in the section will be executed when howzit is run with `-r`. Commands can include any of:

- `@run(COMMAND)`
    
    The command in parenthesis will be executed as is from the current directory of the shell
- `@copy(TEXT)`

    On macOS this will copy the text within the parenthesis to the clipboard. An easy way to offer a shortcut to a longer build command while still allowing it to be edited prior to execution.
- `@open(FILE|URL)`
    
    Will open the file or URL using the default application for the filetype. On macOS this uses the `open` command, on Windows it uses `start`, and on Linux it uses `xdg-open`, which may require separate installation.

### Run blocks (embedded scripts)

For longer scripts you can write shell scripts and then call them with `@run(myscript.sh)`. For those in-between cases where you need a few commands but aren't motivated to create a separate file, you can use fenced code blocks with `run` as the language.

The contents of the block will be written to a temporary file and executed with `/bin/sh -c`. This means that you need a hashbang at the beginning to tell the shell how to interpret the script. If no hashbang is given, the script will be executed as a `sh` script.

Example:

    ```run
    #!/bin/bash
    echo "Just needed a few lines"
    echo "To get through all these commands"
    echo "Almost there!"
    say "Phew, we did it."
    ```

Multiple blocks can be included in a section. @commands take priority over code blocks and will be run first if they exist in the same section.

### Using howzit

Run `howzit` on its own to view the current folder's buildnotes.

Include a section name to see just that section, or no argument to display all.

    howzit build

Use `-l` to list all sections.

    howzit -l

Use `-r` to execute any @copy, @run, or @open commands in the given section. Options can come after the section argument, so to run the commands from the last section you viewed, just hit the up arrow to load the previous command and add `-r`.

    howzit build -r

Other options:

```
Usage: howzit [OPTIONS] [SECTION]

Options:
    -c, --create                     Create a skeleton build note in the current working directory
    -e, --edit                       Edit buildnotes file in current working directory using $EDITOR
    -R, --list-runnable              List sections containing @ directives (verbose)
    -t, --title                      Output title with build notes
        --title-only                 Output title only
    -T, --task-list                  List sections containing @ directives (completion-compatible)
    -L, --list-completions           List sections for completion
    -l, --list                       List available sections
    -r, --run                        Execute @run, @open, and/or @copy commands for given section
        --[no-]color                 Colorize output (default on)
        --[no-]md-highlight          Highlight Markdown syntax (default on), requires mdless or mdcat
        --[no-]pager                 Paginate output (default on)
    -w, --wrap COLUMNS               Wrap to specified width (default 80, 0 to disable)
    -h, --help                       Display this screen
    -v, --version                    Display version number
```

## Additional Features

- Match section titles with any portion of title (non-fuzzy)
- Automatic pagination of output, with optional Markdown highlighting
- Wrap output with option (`-w COLUMNS`) to specify width (default 80, 0 to disable)
- Use `@run()`, `@copy()`, and `@open()` to perform actions within a build notes file
- Use fenced code blocks to include/run embedded scripts
- Set iTerm 2 marks on section titles for navigation when paging is disabled

## Configuration

Some of the command line options can be set as defaults. The first time you run `howzit`, a YAML file is written to `~/.config/howzit/howzit.yaml`. It contains the available options:

```yaml
---
:color: true
:highlight: true
:paginate: false
:wrap: 80
:output_title: false
:highlighter: auto
:pager: auto
```

Most are true/false. `:highlighter:` and `:pager:` can be set to `auto` (default) or a command of your choice for markdown highlighting and pagination.

### Pagers

If set to `auto`, howzit will look for pagers in this order, using the first one it finds available:

- $GIT_PAGER
- $PAGER
- bat
- less
- more
- cat
- pager

If you're defining your own, make sure to include any flags necessary to handle the output. If you're using howzit's coloring, for example, you need to specify any options needed for ANSI escape sequences (e.g. `less -r`).

### Highlighters

If set to `auto` howzit will look for markdown highlighters in this order, using the first it finds available:

- mdless
- mdcat

If you're combining a highlighter with howzit's pagination, include any flags needed to disable the highlighter's pagination (e.g. `mdless --no-pager`).

## Shell Integration

I personally like to alias `bld` to `howzit -r`. If you define a function in your shell, you can have it default to "build" but accept an alternate argument. There's an example for Fish included, and in Bash it would be as simple as `howzit -r ${1:build}`.

For completion you can use `howzit -L` to list all sections, and `howzit -T` to list all "runnable" sections (sections containing an @directive or run block). Completion examples for Fish are included in the `fish` directory.

## Similar Projects

- [mask](https://github.com/jakedeichert/mask/)
- [maid](https://github.com/egoist/maid)
- [saku](https://github.com/kt3k/saku)

There are a few projects that tackle the same concept (a Markdown makefile). Most of them are superior task runners, so if you're looking for a `make` replacement, I recommend exploring the links above. What I like about `howzit` (and what keeps me from switching) is that it's documentation-first, and that I can display the description for each section on the command line. The others also don't have options for listing sections or runnable tasks, so I can't use completion (or my cool script that adds available tasks to my Macbook Pro Touch Bar...). But no, I don't think `howzit` is as good an overall task runner as `mask` or `maid`.

## Author

**Brett Terpstra** - [brettterpstra.com](https://brettterpstra.com)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Roadmap

- Recognize header hierarchy, allow showing/running all sub-sections

## Changelog

### 1.1.10

- Add configuration file for default options

### 1.1.9

- Executable code blocks

### 1.0.1

- Allow section matching within title, not just at start
- Remove formatting of section text for better compatibility with mdless/mdcat
- Add @run() syntax to allow executable commands
- Add @copy() syntax to copy text to clipboard
- Add @url/@open() syntax to open urls/files, OS agnostic (hopefully)
- Add support for mdless/mdcat
- Add support for pager
- Offer to create skeleton buildnotes if none found
- Set iTerm 2 marks for navigation when paging is disabled
- Wrap output with option to specify width (default 80, 0 to disable)

