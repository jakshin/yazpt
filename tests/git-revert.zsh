#!/bin/zsh
# Tests for reverting in a git repo.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name true

# Test
test_case "Reverting"
git checkout master
git revert ca438ac307d0e64ada849f0a540f02ca83662628 764967017eb9e65d8f55a54e28e4f4d44c675af6
test_init_done
contains_branch "master"
contains_status "dirty"
contains "REVERTING"
git rm foo.txt && git commit -m "Delete foo.txt"
test_init_done
contains_branch "master"
contains_status "diverged"
contains "REVERTING"
git revert --continue
test_init_done
contains_branch "master"
contains_status "dirty"
contains_status "diverged"
contains "REVERTING"
cd .git
test_init_done "no-status"
contains_dim_branch "master"
contains_status "unknown"
contains "REVERTING"

# Clean up
after_tests
