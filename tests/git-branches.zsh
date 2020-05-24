#!/bin/zsh
# Tests for branch/tag/SHA display in a Git repo.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name "git"
YAZPT_VCS_ORDER=(git)

[[ -e ~/.yazpt_allow_subst ]] && yazpt_allow_subst_existed=true
touch ~/.yazpt_allow_subst

# Test
function run_tests() {
	local git_dir=$(git rev-parse --git-dir)

	test_case "On a branch"
	git checkout branch1
	test_init_done
	contains_context "branch1"
	contains_status "clean"

	test_case "In the .git directory, on a branch"
	cd $git_dir
	test_init_done
	contains_dim_context "branch1"
	contains_status "clean"
	contains "IN-GIT-DIR"

	test_case "On a branch with a scary name, with prompt_subst on"
	setopt prompt_subst
	git checkout '$(IFS=_;cmd=echo_arg;$cmd)'
	test_init_done
	contains '$_yazpt_subst[context]'
	PROMPT="$(eval noglob echo $PROMPT)"  # Like prompt_subst will do
	contains_context '$(IFS=_;cmd=echo_arg;$cmd)'
	contains_status "clean"

	test_case "In the .git directory, on a branch with a scary name, with prompt_subst on"
	cd $git_dir
	test_init_done
	contains '$_yazpt_subst[context]'
	PROMPT="$(eval noglob echo $PROMPT)"  # Like prompt_subst will do
	contains_dim_context '$(IFS=_;cmd=echo_arg;$cmd)'
	contains_status "clean"
	contains "IN-GIT-DIR"

	test_case "On a branch with a scary name, with prompt_subst off"
	setopt no_prompt_subst
	git checkout '$(IFS=_;cmd=echo_arg;$cmd)'
	test_init_done
	contains_context '$(IFS=_;cmd=echo_arg;$cmd)'
	contains_status "clean"

	test_case "In the .git directory, on a branch with a scary name, with prompt_subst off"
	cd $git_dir
	test_init_done
	contains_dim_context '$(IFS=_;cmd=echo_arg;$cmd)'
	contains_status "clean"
	contains "IN-GIT-DIR"

	test_case "On a branch that could trigger prompt expansion, with prompt_bang on"
	setopt prompt_bang
	git checkout -b 'is!a!test'
	test_init_done
	contains_context 'is!!a!!test'
	contains_status "no-upstream"

	test_case "In the .git directory, on a branch that could trigger prompt expansion, with prompt_bang on"
	cd $git_dir
	test_init_done
	contains_dim_context 'is!!a!!test'
	contains_status "no-upstream"
	contains "IN-GIT-DIR"

	test_case "On a branch that could trigger prompt expansion, with prompt_bang off"
	setopt no_prompt_bang
	git checkout -b 'is!a!test'
	test_init_done
	contains_context 'is!a!test'
	contains_status "no-upstream"

	test_case "In the .git directory, on a branch that could trigger prompt expansion, with prompt_bang off"
	cd $git_dir
	test_init_done
	contains_dim_context 'is!a!test'
	contains_status "no-upstream"
	contains "IN-GIT-DIR"

	test_case "On a branch that could trigger prompt expansion (prompt_percent)"
	git checkout -b '%F{160}red'
	test_init_done
	contains_context '%%F{160}red'
	contains_status "no-upstream"

	test_case "In the .git directory, on a branch that could trigger prompt expansion (prompt_percent)"
	cd $git_dir
	test_init_done
	contains_dim_context '%%F{160}red'
	contains_status "no-upstream"
	contains "IN-GIT-DIR"

	test_case "With an arbitrary commit checked out"
	first_commit="$(git log --format=%h --reverse | head -n 1)"
	git checkout $first_commit
	test_init_done
	contains_context "$first_commit"
	contains_status "clean"

	test_case "In the .git directory, with an arbitrary commit checked out"
	cd $git_dir
	test_init_done
	contains_dim_context "$first_commit"
	contains_status "clean"
	contains "IN-GIT-DIR"

	test_case "With an arbitrary tagged commit checked out"
	git checkout taggy
	test_init_done
	contains_context "taggy"
	contains_status "clean"

	test_case "In the .git directory, with an arbitrary tagged commit checked out"
	cd $git_dir
	test_init_done
	contains_dim_context "taggy"
	contains_status "clean"
	contains "IN-GIT-DIR"
}

run_tests

# Reinitialize and test again, in a linked worktree
before_linked_tests $script_name
run_tests

# Clean up
after_tests
[[ $yazpt_allow_subst_existed == true ]] || rm -f ~/.yazpt_allow_subst
