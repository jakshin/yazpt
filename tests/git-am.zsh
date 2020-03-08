#!/bin/zsh
# Tests for applying patching from email in a git repo.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name true

# Test
function run_tests() {
	test_case "Applying patches from email (AM)"
	git checkout master
	git am patches/*
	test_init_done
	contains_branch "master"
	contains_status "clean"
	contains "AM 1/2"
	echo bleh >> foo.txt && git add . && git am --continue
	test_init_done
	contains_branch "master"
	contains_status "diverged"
	contains "AM 2/2"
	cd $(git rev-parse --git-dir)
	test_init_done
	contains_dim_branch "master"
	contains_status "diverged"
	contains "AM 2/2"
}

run_tests

# Reinitialize and test again, in a linked worktree
before_linked_tests $script_name
run_tests

# Clean up
after_tests
