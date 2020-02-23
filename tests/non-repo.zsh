#!/bin/zsh
# Tests for directories which aren't git repos.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name

# Test
test_case "Not in a repo"
test_init_done "no-status"
is '[%{%F{226}%}%~%{%f%}]%# '

# Clean up
after_tests