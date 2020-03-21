# Utilities for testing yazpt.
# This file is meant to be sourced by each test suite, not invoked directly.

# Colored output
bright='\e[1m'
normal='\e[0m'
success='\e[38;5;76m'
failure='\e[38;5;160m'
success_bullet="${success}✔${normal}"
failure_bullet="${failure}✖︎${normal}"

# Initializes the test suite
function before_tests() {
	local test_suite="$1"
	local clone_repo="$2"

	bright='\e[1m'
	echo -e "${bright}=== Running test suite: $test_suite ===${normal}"

	# We'll need to call yazpt_precmd manually
	source ../yazpt.zsh-theme

	# We'll want to keep score
	passed=0
	failed=0

	# Make a temp directory to work in
	unset test_root
	tmp="$(mktemp -d)"
	echo "Running tests in $tmp"
	cd "$tmp"

	# Might need to clone a repo
	if [[ -n $clone_repo ]]; then
		git clone "https://github.com/jakshin/yazpt-test.git" .
	fi
}

# Reinitializes the test suite, for use in a linked worktree
function before_linked_tests() {
	local test_suite="$1"

	bright='\e[38;5;81m'
	echo -e "\n${bright}=== Rerunning test suite: $script_name (in a linked worktree) ===${normal}"

	cd $tmp
	rm -rf * .git .gitignore
	git clone "https://github.com/jakshin/yazpt-test.git"
	cd "yazpt-test"
	git checkout -b "no-conflicts-in-linked-worktree"
	git worktree add "../yazpt-linked" master

	test_root="$tmp/yazpt-linked"
	cd "$test_root"
}

# Summarizes and cleans up after the test suite is complete
function after_tests() {
	# Summarize; note that code in all.zsh parses this output
	[[ $failed == 0 ]] && color="$success" || color="$failure"
	echo -e "\n${color}↪ Ran $(( passed + failed )) tests: $passed passed, $failed failed${normal}"

	# Clean up
	if [[ -n $tmp ]]; then
		cd ~
		rm -rf $tmp
	fi
}

# Starts a test case
function test_case() {
	local description="$1"
	echo -e "\n${bright}--- Running test case: $description ---${normal}"

	if [[ -n $test_root ]]; then
		cd $test_root
	else
		cd $tmp
	fi
}

# Declares initialization of the test case to be complete, and calculates the new $PROMPT
function test_init_done() {
	[[ $1 == "" || $1 == "no-standard-tests" ]] || eval $1
	yazpt_precmd

	PROMPT="${PROMPT//$'\n'/}"  # Remove linebreaks for easier comparison
	echo $'\n'"-- \$PROMPT is: $PROMPT"

	[[ $1 == "no-standard-tests" ]] || standard_tests
}

# Runs "standard" tests, i.e. verifies things that should always be true
function standard_tests() {
	contains "%{%F{$YAZPT_CWD_COLOR}%}%~%{%f%}"  # CWD
	contains '%# '  # % or #, followed by a space

	local output="$(yazpt_precmd 2>&1)"
	if [[ -n $output ]]; then
		echo " ${failure_bullet} yazpt_precmd had output: ${output//$'\n'/}"
		(( failed++ ))
	fi
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

# Verifies that $PROMPT doesn't contain the given string
function excludes() {
	local excludes_str="$1"
	if [[ $PROMPT != *"$excludes_str"* ]]; then
		echo " ${success_bullet} \$PROMPT doesn't contain $excludes_str"
		(( passed++ ))
	else
		echo " ${failure_bullet} \$PROMPT erroneously contains $excludes_str"
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

# Verifies that $PROMPT contains the given git status indicator
function contains_status() {
	local stat="$1"
	[[ $stat == "clean" ]] && stat="%{%F{29}%}●%{%f%}"
	[[ $stat == "dirty" ]] && stat="%{%F{208}%}⚑%{%f%}"
	[[ $stat == "diverged" ]] && stat="%{%F{166}%}◆%{%f%}"
	[[ $stat == "no-upstream" ]] && stat="%{%F{31}%}◆%{%f%}"
	[[ $stat == "unknown" ]] && stat="%{%F{9}%}⌀%{%f%}"
	contains $stat
}

# Verifies that $PROMPT doesn't contain any of the standard git status indicators
function excludes_status() {
	if [[ $PROMPT != *⚑* && $PROMPT != *◆* && $PROMPT != *●* && $PROMPT != *⌀* && $PROMPT != *⚭* ]]; then
		echo " ${success_bullet} \$PROMPT doesn't contain git status"
		(( passed++ ))
	else
		echo " ${failure_bullet} \$PROMPT erroneously contains git status"
		(( failed++ ))
	fi
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

# Verifies that precmd_functions contains exactly one of our functions
function has_one_precmd_function() {
	local i count=0
	for (( i=1; i <= $#precmd_functions; i++ )); do
		local fn=$precmd_functions[$i]
		[[ $fn == *"yazpt"* ]] && (( count++ ))
	done

	if [[ $count == 1 ]]; then
		echo " ${success_bullet} The precmd_functions array contains exactly one of our functions"
		(( passed++ ))
	elif [[ $count == 0 ]]; then
		echo " ${failure_bullet} The precmd_functions array doesn't contain one of our functions"
		(( failed++ ))
	else
		echo " ${failure_bullet} The precmd_functions array erroneously contains $count of our functions"
		(( failed++ ))
	fi
}

# Verifies that precmd_functions contains none of our functions
function has_no_precmd_function() {
	local i
	for (( i=1; i <= $#precmd_functions; i++ )); do
		local fn=$precmd_functions[$i]
		if [[ fn == *"yazpt"* ]]; then
			echo " ${failure_bullet} The precmd_functions array erroneously contains one of our functions"
			(( failed++ ))
		fi
	done

	echo " ${success_bullet} The precmd_functions array contains none of our functions"
	(( passed++ ))
}
