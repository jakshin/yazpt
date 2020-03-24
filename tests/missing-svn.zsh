#!/bin/zsh
# Tests for when Subversion's CLI is missing.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name "svn"
YAZPT_VCS_ORDER=(svn)

# Test
test_case "Subversion isn't installed or can't be found (directory is a working copy)"
saved_path=($path)
unset path
which svn
test_init_done
path=($saved_path)
is '[%{%F{73}%}%~%{%f%}]%# '

test_case "Subversion isn't installed or can't be found (directory isn't a working copy)"
rm -rf .svn
saved_path=($path)
unset path
which svn
test_init_done
path=($saved_path)
is '[%{%F{73}%}%~%{%f%}]%# '

# Clean up
after_tests
