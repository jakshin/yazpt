#!/bin/zsh
# Tests for escaping the execution time character.
# We escape `!` if prompt_bang is on, and `%` if prompt_percent is on (which it always should be),
# but let `$` expressions through, as a feature.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name

YAZPT_EXECTIME_COLOR=42
YAZPT_LAYOUT='<exectime> <cwd> <char> '
YAZPT_RLAYOUT=''

# Test
test_case "Exclamation mark, with prompt_bang off"
YAZPT_EXECTIME_CHAR='!'
setopt no_prompt_bang
test_init_done "_yazpt_cmd_exec_start=$((SECONDS - 11))"
contains '%{%F{42}%}!'
excludes '!!'

test_case "Exclamation mark, with prompt_bang on"
YAZPT_EXECTIME_CHAR='!'
setopt prompt_bang
test_init_done "_yazpt_cmd_exec_start=$((SECONDS - 11))"
contains '%{%F{42}%}!!'

test_case "Percent sign, with prompt_percent off"
YAZPT_EXECTIME_CHAR='%'
setopt no_prompt_percent
test_init_done "_yazpt_cmd_exec_start=$((SECONDS - 11))"
contains '%{%F{42}%}%'
excludes '%%'

test_case "Percent sign, with prompt_percent on"
YAZPT_EXECTIME_CHAR='%'
setopt prompt_percent
test_init_done "_yazpt_cmd_exec_start=$((SECONDS - 11))"
contains '%{%F{42}%}%%'

# Clean up
after_tests
