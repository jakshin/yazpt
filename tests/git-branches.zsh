#!/bin/zsh
# Tests for branch (and non-branch) display in a git repo.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name true

# Test
test_case "On a branch"
git checkout branch1
test_init_done
contains_branch "branch1"
contains_status "perfect"

test_case "In the .git directory, on a branch"
cd .git
test_init_done
contains_dim_branch "branch1"
contains_status "unknown"

test_case "On a branch with a scary name, with prompt_subst on"
setopt prompt_subst
git checkout '$(IFS=_;cmd=echo_arg;$cmd)'
test_init_done
contains '$yazpt_git_branch__'
PROMPT="$(eval noglob echo $PROMPT)"  # Like prompt_subst will do
contains_branch '$(IFS=_;cmd=echo_arg;$cmd)'
contains_status "perfect"

test_case "In the .git directory, on a branch with a scary name, with prompt_subst on"
cd .git
test_init_done
contains '$yazpt_git_branch__'
PROMPT="$(eval noglob echo $PROMPT)"  # Like prompt_subst will do
contains_dim_branch '$(IFS=_;cmd=echo_arg;$cmd)'
contains_status "unknown"

test_case "On a branch with a scary name, with prompt_subst off"
setopt no_prompt_subst
git checkout '$(IFS=_;cmd=echo_arg;$cmd)'
test_init_done
contains_branch '$(IFS=_;cmd=echo_arg;$cmd)'
contains_status "perfect"

test_case "In the .git directory, on a branch with a scary name, with prompt_subst off"
cd .git
test_init_done
contains_dim_branch '$(IFS=_;cmd=echo_arg;$cmd)'
contains_status "unknown"

test_case "With an arbitrary commit checked out"
first_commit="$(git log --format=%h --reverse | head -n 1)"
git checkout $first_commit
test_init_done
contains_branch "$first_commit"
contains_status "perfect"

test_case "In the .git directory, with an arbitrary commit checked out"
cd .git
test_init_done
contains_dim_branch "$first_commit"
contains_status "unknown"

test_case "With an arbitrary tagged commit checked out"
git checkout taggy
test_init_done
contains_branch "taggy"
contains_status "perfect"

test_case "In the .git directory, with an arbitrary tagged commit checked out"
cd .git
test_init_done
contains_dim_branch "taggy"
contains_status "unknown"

# Clean up
after_tests
