#!/bin/zsh
# Tests for bisecting in a git repo.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name true

# Test
test_case "Bisecting"
git checkout branch1
git bisect start
test_init_done
contains_branch "branch1"
contains_status "perfect"
contains "BISECTING"
cd .git
test_init_done
contains_dim_branch "branch1"
contains_status "perfect"
contains "BISECTING"

# Clean up
after_tests
