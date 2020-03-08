#!/bin/zsh
# Tests for rebasing in a git repo.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name true

# Test
function run_tests() {
	local git_dir=$(git rev-parse --git-dir)

	test_case "Rebasing interactively"
	export GIT_EDITOR=true
	git checkout rebase-me
	git rebase -i master
	dir_exists "$git_dir/rebase-merge"          # Sanity check
	dir_does_not_exist "$git_dir/rebase-apply"  # Sanity check
	test_init_done
	contains_branch "rebase-me"
	contains_status "dirty"
	contains "REBASING 1/2"
	cd $git_dir
	test_init_done
	contains_dim_branch "rebase-me"
	contains_status "dirty"
	contains "REBASING 1/2"
	unset GIT_EDITOR
	cd - && git rebase --abort  # Cleanup

	test_case "Rebasing"
	git checkout rebase-me
	git rebase master
	dir_does_not_exist "$git_dir/rebase-merge"  # Sanity check
	dir_exists "$git_dir/rebase-apply"          # Sanity check
	test_init_done
	contains_branch "rebase-me"
	contains_status "dirty"
	contains "REBASING 1/2"
	cd $git_dir
	test_init_done
	contains_dim_branch "rebase-me"
	contains_status "dirty"
	contains "REBASING 1/2"
	cd - && git rebase --abort  # Cleanup

	test_case "Rebased branch that hasn't been pushed"
	git checkout rebase-me-too
	git rebase master
	test_init_done
	contains_branch "rebase-me-too"
	contains_status "diverged"
	cd $git_dir
	test_init_done
	contains_dim_branch "rebase-me-too"
	contains_status "diverged"
	contains "IN-GIT-DIR"
	cd - && git checkout master  # Cleanup
}

run_tests

# Reinitialize and test again, in a linked worktree
before_linked_tests $script_name
run_tests

# Clean up
after_tests
