#!/bin/zsh
# Tests for bisecting in a Git repo.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name "git"
YAZPT_VCS_ORDER=(git)

# Test
function run_tests() {
	test_case "Bisecting"
	git checkout branch1
	git bisect start
	test_init_done
	contains_branch "branch1"
	contains_status "clean"
	contains "BISECTING"
	cd $(git rev-parse --git-dir)
	test_init_done
	contains_dim_branch "branch1"
	contains_status "clean"
	contains "BISECTING"
}

run_tests

# Reinitialize and test again, in a linked worktree
before_linked_tests $script_name
run_tests

# Clean up
after_tests
