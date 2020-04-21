#!/bin/zsh
# Tests for merging in a Git repo.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name "git"
YAZPT_VCS_ORDER=(git)

# Test
function run_tests() {
	test_case "Merging"
	git checkout merge-me
	git checkout master
	git merge merge-me
	test_init_done
	contains_context "master"
	contains_status "dirty"
	contains "MERGING"
	cd $(git rev-parse --git-dir)
	test_init_done
	contains_dim_context "master"
	contains_status "dirty"
	contains "MERGING"
}

run_tests

# Reinitialize and test again, in a linked worktree
before_linked_tests $script_name
run_tests

# Clean up
after_tests
