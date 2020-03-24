#!/bin/zsh
# Tests for settings (via environment variables).

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name

# Test
test_case "Current working directory color"
YAZPT_CWD_COLOR=5
test_init_done
contains '%{%F{5}%}%~%{%f%}'

test_case "Command exit code = error"
YAZPT_EXIT_ERROR_CHAR="✦"
YAZPT_EXIT_ERROR_COLOR=9
YAZPT_EXIT_ERROR_CODE_VISIBLE=true
test_init_done "(exit 42)"
contains '%{%F{9}%}✦%{%f%}'
contains '%{%F{9}%}42%{%f%}'
YAZPT_EXIT_ERROR_CHAR=""
test_init_done "(exit 42)"
excludes '✘'
contains '%{%F{9}%}42%{%f%}'
YAZPT_EXIT_ERROR_CHAR="✦"
YAZPT_EXIT_ERROR_CODE_VISIBLE=false
test_init_done "(exit 42)"
contains '%{%F{9}%}✦%{%f%}'
excludes '42'

test_case "Command exit code = success"
YAZPT_EXIT_OK_CHAR="✧"
YAZPT_EXIT_OK_COLOR=10
YAZPT_EXIT_OK_CODE_VISIBLE=true
test_init_done "true"
contains '%{%F{10}%}✧%{%f%}'
contains '%{%F{10}%}0%{%f%}'
YAZPT_EXIT_OK_CHAR=""
test_init_done "true"
excludes '✧'
contains '%{%F{10}%}0%{%f%}'
YAZPT_EXIT_OK_CHAR="✧"
YAZPT_EXIT_OK_CODE_VISIBLE=false
test_init_done "true"
contains '%{%F{10}%}✧%{%f%}'
excludes '}0'

# Clean up
after_tests
