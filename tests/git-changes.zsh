#!/bin/zsh
# Tests for various types of file/directory changes in a git repo.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name true

# Test
function run_tests() {
	test_case "In an ignored directory"
	git checkout branch1
	mkdir ignored
	cd ignored
	test_init_done
	contains_dim_branch "branch1"
	contains_status "clean"
	contains "IGNORED"

	test_case "With an empty untracked directory"
	mkdir empty
	test_init_done
	contains_branch "branch1"
	contains_status "clean"

	test_case "With an untracked file"
	echo untracked > untracked.txt
	test_init_done
	contains_branch "branch1"
	contains_status "dirty"
	rm -f untracked.txt  # Cleanup

	test_case "With a modified/renamed/deleted ignored file"
	test_init_done
	contains_branch "branch1"
	contains_status "clean"
	echo ignored > ignored.txt
	test_init_done
	contains_branch "branch1"
	contains_status "clean"
	mv -v ignored.txt ignored.text
	test_init_done
	contains_branch "branch1"
	contains_status "clean"
	rm -fv ignored.text
	test_init_done
	contains_branch "branch1"
	contains_status "clean"

	test_case "With a deleted file (rm)"
	rm -fv bar.txt
	test_init_done
	contains_branch "branch1"
	contains_status "dirty"
	git checkout .  # Cleanup

	test_case "With a deleted file (git rm)"
	git rm bar.txt
	test_init_done
	contains_branch "branch1"
	contains_status "dirty"
	git reset && git checkout bar.txt  # Cleanup

	test_case "With a renamed file (git mv)"
	git mv bar.txt new-name.txt
	test_init_done
	contains_branch "branch1"
	contains_status "dirty"
	git reset HEAD bar.txt new-name.txt && mv new-name.txt bar.txt  # Cleanup

	test_case "With a modified file"
	echo barrrr >> bar.txt
	test_init_done
	contains_branch "branch1"
	contains_status "dirty"

	test_case "With staged changes"
	git add .
	test_init_done
	contains_branch "branch1"
	contains_status "dirty"

	test_case "With a commit that hasn't been pushed"
	git commit -m "modified bar.txt"
	test_init_done
	contains_branch "branch1"
	contains_status "diverged"
	git reset --hard HEAD~1  # Cleanup

	test_case "Remote branch has commits my local branch doesn't"
	git checkout branch2
	git reset HEAD~1
	rm baz.txt
	test_init_done
	contains_branch "branch2"
	contains_status "diverged"
	git pull && git checkout branch1  # Cleanup
}

run_tests

# Reinitialize and test again, in a linked worktree
before_linked_tests $script_name
run_tests

# Clean up
after_tests
