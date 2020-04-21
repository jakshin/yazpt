#!/bin/zsh
# Tests for directories which aren't TFVC workspaces.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name
YAZPT_VCS_ORDER=(tfvc)

# Test
test_case "Not in a workspace"
test_init_done
is '[%{%F{73}%}%~%{%f%}]%# '

# Clean up
after_tests
