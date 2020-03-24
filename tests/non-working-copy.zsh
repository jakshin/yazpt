#!/bin/zsh
# Tests for directories which aren't Subversion working copies.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name
YAZPT_VCS_ORDER=(svn)

# Test
test_case "Not in a working copy"
test_init_done
is '[%{%F{73}%}%~%{%f%}]%# '

# Clean up
after_tests
