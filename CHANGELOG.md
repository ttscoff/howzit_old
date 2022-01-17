### 1.1.27

2022-01-17 11:45

#### NEW

- Use fzf for menus if available
- "@run() TITLE" will show TITLE instead of command when listing runnable topics
- @include(FILENAME) will import an external file if the path exists

### 1.1.26

- Fix for error in interactive build notes creation

### 1.1.25

- Hide run block contents by default
- :show_all_code: config setting to include run block contents
- --show-code flag to display run block contents at runtime
- Modify include display

### 1.1.24

- Use ~/.config/howzit/ignore.yaml to ignore patterns when scanning for build notes
- Use `required` and `optional` keys in templates to request that metadata be defined when importing
- Allow templates to include other templates

### 1.1.23

- Add flags to allow content to stay onscreen after exiting pager (less and bat)

### 1.1.21

- Merge directive and block handling so execution order is sequential

### 1.1.20

- Template functionality for including common tasks/topics

### 1.1.19

- Add `--upstream` option to traverse up parent directories for additional build notes

### 1.1.15

- Code refactoring/cleanup
- Rename "sections" to "topics"
- If no match found for topic search, only show error (`:show_all_on_error: false` option)

### 1.1.14

- Fix removal of non-alphanumeric characters from titles
- -s/--select option to display a menu of all available topics
- Allow arguments to be passed after `--` for variable substitution
- Allow --matching TYPE to match first non-ambigous keyword match

### 1.1.13

- --matching [fuzzy,beginswith,partial,exact] flag
- --edit-config flag
- sort flags in help

### 1.1.12

- After consideration, remove full fuzzy matching. Too many positives for shorter strings.

### 1.1.11

- Add full fuzzy matching for topic titles
- Add `@include(TOPIC)` command to import another topic's tasks

### 1.1.10

- Add config file for default options

### 1.1.9

- Use `system` instead of `exec` to allow multiple @run commands
- Add code block runner

### 1.1.8

- Add `-e/--edit` flag to open build notes in $EDITOR

### 1.1.7

- Use `exec` for @run commands to allow interactive processes (e.g. vim)

### 1.1.6

- Add option for outputting title with notes
- Add option for outputting note title only

### 1.1.4

- Fix for "topic not found" when run with no arguments

### 1.1.1

- Reorganize and rename long output options
- Fix wrapping long lines without spaces

### 1.1.0

- Add -R switch for listing "runnable" topics
- Add -T switch for completion-compatible listing of "runnable" topics
- Add -L switch for completion-compatible listing of all topics

### 1.0.1

- Allow topic matching within title, not just at start
- Remove formatting of topic text for better compatibility with mdless/mdcat
- Add @run() syntax to allow executable commands
- Add @copy() syntax to copy text to clipboard
- Add @url/@open() syntax to open urls/files, OS agnostic (hopefully)
- Add support for mdless/mdcat
- Add support for pager
- Offer to create skeleton buildnotes if none found
- Set iTerm 2 marks for navigation when paging is disabled
- Wrap output with option to specify width (default 80, 0 to disable)
