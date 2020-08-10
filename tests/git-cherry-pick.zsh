#!/bin/zsh
# Tests for cherry-picking in a Git repo.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name "git"
YAZPT_VCS_ORDER=(git)

# Recent versions of git end "cherry-picking mode" earlier, apparerenltly starting in v2.24:
# https://github.com/git/git/commit/f233c9f4550a831a69892e0a38db2a7654beb995
version=$(git --version | awk '{ print $3 }')
v=("${(@s/./)version}")
if (( v[1] > 2 || (v[1] == 2 && v[2] >= 24) )); then
	recent_git=true
fi

# Test
function run_tests() {
	test_case "Cherry-picking"
	git checkout cherry-pick-from-me
	git checkout master
	git cherry-pick 52450fe53496fe6f14e8be48753e65b27aed9ee6..78469cb25340c6bfd2c00f05c58f96704be687f8
	test_init_done
	contains_context "master"
	contains_status "dirty"
	contains "CHERRY-PICKING"
	git add . && git commit -m "resolved"
	test_init_done
	contains_context "master"
	contains_status "diverged"
	[[ $recent_git == true ]] || contains "CHERRY-PICKING"
	cd $(git rev-parse --git-dir)
	test_init_done
	contains_dim_context "master"
	contains_status "diverged"
	[[ $recent_git == true ]] && contains "IN-GIT-DIR" || contains "CHERRY-PICKING"
}

run_tests

# Reinitialize and test again, in a linked worktree
before_linked_tests $script_name
run_tests

# Clean up
after_tests
