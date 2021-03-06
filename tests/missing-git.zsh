#!/bin/zsh
# Tests for when Git's CLI is missing.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name "git"
YAZPT_VCS_ORDER=(git)

# Test
test_case "Git isn't installed or can't be found (repo directory)"
saved_path=($path)
unset path
which git
test_init_done
path=($saved_path)
is '[%{%F{73}%}%~%{%f%}]%# '

test_case "Git isn't installed or can't be found (non-repo directory)"
rm -rf .git
saved_path=($path)
unset path
which git
test_init_done
path=($saved_path)
is '[%{%F{73}%}%~%{%f%}]%# '

# Clean up
after_tests
