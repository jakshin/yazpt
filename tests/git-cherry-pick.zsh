#!/bin/zsh
# Tests for cherry-picking in a git repo.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name true

# Test
test_case "Cherry-picking"
git checkout cherry-pick-from-me
git checkout master
git cherry-pick 52450fe53496fe6f14e8be48753e65b27aed9ee6..78469cb25340c6bfd2c00f05c58f96704be687f8
test_init_done
contains_branch "master"
contains_status "dirty"
contains "CHERRY-PICKING"
git add . && git commit -m "resolved"
test_init_done
contains_branch "master"
contains_status "diverged"
contains "CHERRY-PICKING"
cd .git
test_init_done "no-status"
contains_dim_branch "master"
contains_status "unknown"
contains "CHERRY-PICKING"

# Clean up
after_tests