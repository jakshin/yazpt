#!/bin/zsh
# Tests for escaping the "exit" segment's OK/error characters.
# We escape `!` if prompt_bang is on, and `%` if prompt_percent is on (which it always should be),
# but let `$` expressions through, as a feature.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name

YAZPT_EXIT_ERROR_COLOR=42
YAZPT_EXIT_OK_COLOR=43
YAZPT_LAYOUT='<exit> <cwd> <char> '

# Test
test_case "Exclamation mark, with prompt_bang off"
YAZPT_EXIT_ERROR_CHAR='!'
YAZPT_EXIT_OK_CHAR='!'
setopt no_prompt_bang
test_init_done "false"
contains '%{%F{42}%}!'
excludes '!!'
test_init_done "true"
contains '%{%F{43}%}!'
excludes '!!'

test_case "Exclamation mark, with prompt_bang on"
YAZPT_EXIT_ERROR_CHAR='!'
YAZPT_EXIT_OK_CHAR='!'
setopt prompt_bang
test_init_done "false"
contains '%{%F{42}%}!!'
test_init_done "true"
contains '%{%F{43}%}!!'

test_case "Percent sign, with prompt_percent off"
YAZPT_EXIT_ERROR_CHAR='%'
YAZPT_EXIT_OK_CHAR='%'
setopt no_prompt_percent
test_init_done "false"
contains '%{%F{42}%}%%{%f%}'
test_init_done "true"
contains '%{%F{43}%}%%{%f%}'

test_case "Percent sign, with prompt_percent on"
YAZPT_EXIT_ERROR_CHAR='%'
YAZPT_EXIT_OK_CHAR='%'
setopt prompt_percent
test_init_done "false"
contains '%{%F{42}%}%%%{%f%}'
test_init_done "true"
contains '%{%F{43}%}%%%{%f%}'

# Clean up
after_tests
