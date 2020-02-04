#!/bin/zsh
# Tests for new git repos with no commits.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name

# Test
test_case "New repo with no branches/commits"
git init
test_init_done
contains_branch "master"
contains_status "no-upstream"

test_case "In the .git directory of a new repo with no branches/commits"
cd .git
test_init_done "no-status"
contains_dim_branch "master"
contains_status "unknown"

# Clean up
after_tests
