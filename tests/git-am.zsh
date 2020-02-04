#!/bin/zsh
# Tests for applying patching from email in a git repo.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name true

# Test
test_case "Applying patches from email (AM)"
git checkout master
git am patches/*
test_init_done
contains_branch "master"
contains_status "perfect"
contains "AM 1/2"
echo bleh >> foo.txt && git add . && git am --continue
test_init_done
contains_branch "master"
contains_status "diverged"
contains "AM 2/2"
cd .git
test_init_done "no-status"
contains_dim_branch "master"
contains_status "unknown"
contains "AM 2/2"

# Clean up
after_tests
