#!/bin/zsh
# Tests for reverting in a Git repo.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name "git"
YAZPT_VCS_ORDER=(git)

# Test
function run_tests() {
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
	cd $(git rev-parse --git-dir)
	test_init_done
	contains_dim_branch "master"
	contains_status "diverged"
	contains "REVERTING"
}

run_tests

# Reinitialize and test again, in a linked worktree
before_linked_tests $script_name
run_tests

# Clean up
after_tests
