#!/bin/zsh
# Tests for merging in a git repo.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name true

# Test
test_case "Merging"
git checkout merge-me
git checkout master
git merge merge-me
test_init_done
contains_branch "master"
contains_status "dirty"
contains "MERGING"
cd .git
test_init_done
contains_dim_branch "master"
contains_status "dirty"
contains "MERGING"

# Clean up
after_tests
