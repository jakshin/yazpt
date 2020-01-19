#!/bin/zsh
# Tests yazpt

# We'll need to call yazpt_precmd manually
cd -- "$(dirname -- "$0")"
source ../yazpt.zsh-theme

# Make a temp directory to work in
tmp="$(mktemp -d)"
echo "Running tests in $tmp"

# Colored output
bright='\e[1m'
normal='\e[0m'
success='\e[38;5;76m'
failure='\e[38;5;160m'
success_bullet="${success}✔${normal}"
failure_bullet="${failure}✖︎${normal}"

# Keeping score
passed=0
failed=0

# Starts a test case
function test_case() {
	local description="$1"
	echo -e "\n${bright}=== Running test case: $description ===${normal}"
	cd $tmp
}

# Declares initialization of the test case to be complete, and calculates the new $PROMPT
function test_init_done() {
	[[ $1 != "no-status" ]] && echo && git status
	yazpt_precmd
	PROMPT="${PROMPT//$'\n'/}"  # Remove linebreaks for easier comparison
	echo $'\n'"-- \$PROMPT is: $PROMPT"
	standard_tests
}

# Runs "standard" tests, i.e. verifies things that should always be true
function standard_tests() {
	contains '%{%F{226}%}%~%{%f%}]%# '  # CWD and %/#
}

# Verifies that $PROMPT is exactly the given string
function is() {
	local is_str="$1"
	if [[ $PROMPT == "$is_str" ]]; then
		echo " ${success_bullet} \$PROMPT is exactly $is_str"
		(( passed++ ))
	else
		echo " ${failure_bullet} \$PROMPT is not $is_str"
		(( failed++ ))
	fi
}

# Verifies that $PROMPT contains the given string
function contains() {
	local contains_str="$1"
	if [[ $PROMPT == *"$contains_str"* ]]; then
		echo " ${success_bullet} \$PROMPT contains $contains_str"
		(( passed++ ))
	else
		echo " ${failure_bullet} \$PROMPT does not contain $contains_str"
		(( failed++ ))
	fi
}

# Verifies that $PROMPT contains the given git branch name, in bright text
function contains_branch() {
	local branch_name="$1"
	contains "%{%F{255}%}$branch_name"
}

# Verifies that $PROMPT contains the given git branch name, in dim text
function contains_dim_branch() {
	local branch_name="$1"
	contains "%{%F{240}%}$branch_name"
}

# Verifies that $PROMPT contains a green clean, orange dirty, red dirty or unknown status indicator
function contains_status() {
	local stat="$1"
	[[ $stat == "green-clean" ]] && stat="%{%F{28}●%f%}"
	[[ $stat == "orange-dirty" ]] && stat="%{%F{208}◆%f%}"
	[[ $stat == "red-dirty" ]] && stat="%{%F{160}⚑%f%}"
	[[ $stat == "unknown" ]] && stat="%{%F{45}?%f%}"
	contains $stat
}

# Verifies that the given directory exists
function dir_exists() {
	local dir="$1"
	if [[ -d $dir ]]; then
		echo " ${success_bullet} Directory '$dir' exists"
		(( passed++ ))
	else
		echo " ${failure_bullet} Directory '$dir' does not exist"
		(( failed++ ))
	fi
}

# Verifies that the given directory doesn't exist
function dir_does_not_exist() {
	local dir="$1"
	if [[ ! -d $dir ]]; then
		echo " ${success_bullet} Directory '$dir' does not exist"
		(( passed++ ))
	else
		echo " ${failure_bullet} Directory '$dir' exists"
		(( failed++ ))
	fi
}

# Run tests (order matters as git's state is built up over the course of tests)
test_case "Not in a repo"
cd $tmp
test_init_done "no-status"
is '[%{%F{226}%}%~%{%f%}]%# '

test_case "New repo with no branches/commits"
git init
test_init_done
contains_branch "master"
contains_status "green-clean"

test_case "In the .git directory of a new repo with no branches/commits"
cd .git
test_init_done "no-status"
contains_dim_branch "master"
contains_status "unknown"

# From here on, we want to be working with a remote repo
cd $tmp
rm -rf .git
git clone "https://github.com/jakshin/yazpt-test.git" .

test_case "On a branch"
git checkout branch1
test_init_done
contains_branch "branch1"
contains_status "green-clean"

test_case "In the .git directory, on a branch"
cd .git
test_init_done "no-status"
contains_dim_branch "branch1"
contains_status "unknown"

test_case "On a branch with a scary name, with prompt_subst on"
setopt prompt_subst
git checkout '$(IFS=_;cmd=echo_arg;$cmd)'
test_init_done
contains '$__yazpt_git_display'
PROMPT="$(eval noglob echo $PROMPT)"  # Like prompt_subst will do
contains_branch '$(IFS=_;cmd=echo_arg;$cmd)'
contains_status "green-clean"

test_case "In the .git directory, on a branch with a scary name, with prompt_subst on"
cd .git
test_init_done "no-status"
contains '$__yazpt_git_display'
PROMPT="$(eval noglob echo $PROMPT)"  # Like prompt_subst will do
contains_dim_branch '$(IFS=_;cmd=echo_arg;$cmd)'
contains_status "unknown"

test_case "On a branch with a scary name, with prompt_subst off"
setopt no_prompt_subst
git checkout '$(IFS=_;cmd=echo_arg;$cmd)'
test_init_done
contains_branch '$(IFS=_;cmd=echo_arg;$cmd)'
contains_status "green-clean"

test_case "In the .git directory, on a branch with a scary name, with prompt_subst off"
cd .git
test_init_done "no-status"
contains_dim_branch '$(IFS=_;cmd=echo_arg;$cmd)'
contains_status "unknown"

test_case "With an arbitrary commit checked out"
first_commit="$(git log --format=%h --reverse | head -n 1)"
git checkout $first_commit
test_init_done
contains_branch "$first_commit"
contains_status "green-clean"

test_case "In the .git directory, with an arbitrary commit checked out"
cd .git
test_init_done "no-status"
contains_dim_branch "$first_commit"
contains_status "unknown"

test_case "With an arbitrary tagged commit checked out"
git checkout taggy
test_init_done
contains_branch "taggy"
contains_status "green-clean"

test_case "In the .git directory, with an arbitrary tagged commit checked out"
cd .git
test_init_done "no-status"
contains_dim_branch "taggy"
contains_status "unknown"

test_case "In an ignored directory"
git checkout branch1
mkdir ignored
cd ignored
test_init_done
contains_dim_branch "branch1"
contains_status "green-clean"

test_case "With an empty untracked directory"
mkdir empty
test_init_done
contains_branch "branch1"
contains_status "green-clean"

test_case "With an untracked file"
echo untracked > untracked.txt
test_init_done
contains_branch "branch1"
contains_status "red-dirty"
rm -f untracked.txt  # Cleanup

test_case "With a modified/renamed/deleted ignored file"
test_init_done
contains_branch "branch1"
contains_status "green-clean"
echo ignored > ignored.txt
test_init_done
contains_branch "branch1"
contains_status "green-clean"
mv -v ignored.txt ignored.text
test_init_done
contains_branch "branch1"
contains_status "green-clean"
rm -fv ignored.text
test_init_done
contains_branch "branch1"
contains_status "green-clean"

test_case "With a deleted file (rm)"
rm -fv bar.txt
test_init_done
contains_branch "branch1"
contains_status "red-dirty"
git checkout .  # Cleanup
test_init_done && contains_status "green-clean"  # Ensure cleanup worked

test_case "With a deleted file (git rm)"
git rm bar.txt
test_init_done
contains_branch "branch1"
contains_status "red-dirty"
git reset && git checkout bar.txt  # Cleanup
test_init_done && contains_status "green-clean"  # Ensure cleanup worked

test_case "With a renamed file (git mv)"
git mv bar.txt new-name.txt
test_init_done
contains_branch "branch1"
contains_status "red-dirty"
git reset HEAD bar.txt new-name.txt && mv new-name.txt bar.txt  # Cleanup
test_init_done && contains_status "green-clean"  # Ensure cleanup worked

test_case "With a modified file"
echo barrrr >> bar.txt
test_init_done
contains_branch "branch1"
contains_status "red-dirty"

test_case "With staged changes"
git add .
test_init_done
contains_branch "branch1"
contains_status "red-dirty"

test_case "With a commit that hasn't been pushed"
git commit -m "modified bar.txt"
test_init_done
contains_branch "branch1"
contains_status "orange-dirty"
git reset --hard HEAD~1  # Cleanup
test_init_done && contains_status "green-clean"  # Ensure cleanup worked

test_case "Remote branch has commits my local branch doesn't"
git checkout branch2
git reset HEAD~1
rm baz.txt
test_init_done
contains_branch "branch2"
contains_status "orange-dirty"
git pull && git checkout branch1  # Cleanup
test_init_done && contains_status "green-clean"  # Ensure cleanup worked

test_case "Rebasing interactively"
export GIT_EDITOR=true
git checkout rebase-me
git rebase -i master
dir_exists ".git/rebase-merge"          # Sanity check
dir_does_not_exist ".git/rebase-apply"  # Sanity check
test_init_done
contains_branch "rebase-me"
contains_status "red-dirty"
contains "REBASING 1/2"
cd .git
test_init_done "no-status"
contains_dim_branch "rebase-me"
contains_status "unknown"
contains "REBASING 1/2"
unset GIT_EDITOR
cd .. && git rebase --abort  # Cleanup
test_init_done && contains_status "green-clean"  # Ensure cleanup worked

test_case "Rebasing"
git checkout rebase-me
git rebase master
dir_does_not_exist ".git/rebase-merge"  # Sanity check
dir_exists ".git/rebase-apply"          # Sanity check
test_init_done
contains_branch "rebase-me"
contains_status "red-dirty"
contains "REBASING 1/2"
cd .git
test_init_done "no-status"
contains_dim_branch "rebase-me"
contains_status "unknown"
contains "REBASING 1/2"
cd .. && git rebase --abort  # Cleanup
test_init_done && contains_status "green-clean"  # Ensure cleanup worked

test_case "Rebased branch that hasn't been pushed"
git checkout rebase-me-too
git rebase master
test_init_done
contains_branch "rebase-me-too"
contains_status "orange-dirty"
cd .git
test_init_done "no-status"
contains_dim_branch "rebase-me-too"
contains_status "unknown"
cd .. && git checkout master  # Cleanup
test_init_done && contains_status "green-clean"  # Ensure cleanup worked

test_case "Applying patches"
git checkout master
git am patches/*
test_init_done
contains_branch "master"
contains_status "green-clean"
contains "AM 1/2"
echo bleh >> foo.txt && git add . && git am --continue
test_init_done
contains_branch "master"
contains_status "orange-dirty"
contains "AM 2/2"
cd .git
test_init_done "no-status"
contains_dim_branch "master"
contains_status "unknown"
contains "AM 2/2"
cd .. && git am --abort  # Cleanup
test_init_done && contains_status "green-clean"  # Ensure cleanup worked

test_case "Merging"
git checkout merge-me
git checkout master
git merge merge-me
test_init_done
contains_branch "master"
contains_status "red-dirty"
contains "MERGING"
cd .git
test_init_done "no-status"
contains_dim_branch "master"
contains_status "unknown"
contains "MERGING"
cd .. && git merge --abort  # Cleanup
test_init_done && contains_status "green-clean"  # Ensure cleanup worked

test_case "Bisecting"
git checkout branch1
git bisect start
test_init_done
contains_branch "branch1"
contains_status "green-clean"
contains "BISECTING"
cd .git
test_init_done "no-status"
contains_dim_branch "branch1"
contains_status "unknown"
contains "BISECTING"
cd .. && git bisect reset  # Cleanup
test_init_done && contains_status "green-clean"  # Ensure cleanup worked

test_case "Cherry-picking"
git checkout cherry-pick-from-me
git checkout master
git cherry-pick 52450fe53496fe6f14e8be48753e65b27aed9ee6..78469cb25340c6bfd2c00f05c58f96704be687f8
test_init_done
contains_branch "master"
contains_status "red-dirty"
contains "CHERRY-PICKING"
git add . && git commit -m "resolved"
test_init_done
contains_branch "master"
contains_status "orange-dirty"
contains "CHERRY-PICKING"
cd .git
test_init_done "no-status"
contains_dim_branch "master"
contains_status "unknown"
contains "CHERRY-PICKING"
cd .. && git reset --hard HEAD~1 && git cherry-pick --abort  # Cleanup
test_init_done && contains_status "green-clean"  # Ensure cleanup worked

test_case "Reverting"
git checkout master
git revert ca438ac307d0e64ada849f0a540f02ca83662628 764967017eb9e65d8f55a54e28e4f4d44c675af6
test_init_done
contains_branch "master"
contains_status "red-dirty"
contains "REVERTING"
git rm foo.txt && git commit -m "Delete foo.txt"
test_init_done
contains_branch "master"
contains_status "orange-dirty"
contains "REVERTING"
git revert --continue
test_init_done
contains_branch "master"
contains_status "red-dirty"
contains "REVERTING"
cd .git
test_init_done "no-status"
contains_dim_branch "master"
contains_status "unknown"
contains "REVERTING"
cd .. && git revert --abort  # Cleanup
test_init_done && contains_status "green-clean"  # Ensure cleanup worked

# Summarize
[[ $failed == 0 ]] && color="$success" || color="$failure"
echo -e "\n${color}Ran $(( passed + failed )) tests: $passed passed, $failed failed${normal}"

# Clean up
rm -rf $tmp
