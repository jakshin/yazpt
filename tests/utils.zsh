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

	echo -e "${bright}=== Running test suite: $test_suite ===${normal}"

	# We'll need to call yazpt_precmd manually
	source ../yazpt.zsh-theme

	# We'll want to keep score
	passed=0
	failed=0

	# Make a temp directory to work in
	tmp="$(mktemp -d)"
	echo "Running tests in $tmp"
	cd "$tmp"

	# Might need to clone a repo
	if [[ -n $clone_repo ]]; then
		git clone "https://github.com/jakshin/yazpt-test.git" .
	fi
}

# Summarizes and cleans up after the test suite is complete
function after_tests() {
	# Summarize; note that code in all.zsh parses this output
	[[ $failed == 0 ]] && color="$success" || color="$failure"
	echo -e "\n${color}↪ Ran $(( passed + failed )) tests: $passed passed, $failed failed${normal}"

	# Clean up
	if [[ -n $tmp ]]; then
		rm -rf $tmp
	fi
}

# Starts a test case
function test_case() {
	local description="$1"
	echo -e "\n${bright}--- Running test case: $description ---${normal}"
	cd $tmp
}

# Declares initialization of the test case to be complete, and calculates the new $PROMPT
function test_init_done() {
	[[ $1 == "no-status" ]] || (echo && git status)
	yazpt_precmd
	PROMPT="${PROMPT//$'\n'/}"  # Remove linebreaks for easier comparison
	echo $'\n'"-- \$PROMPT is: $PROMPT"
	standard_tests
}

# Runs "standard" tests, i.e. verifies things that should always be true
function standard_tests() {
	contains '%{%F{226}%}%~%{%f%}'  # CWD
	contains '%# '                  # % or #, followed by a space
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

# Verifies that $PROMPT contains the given status indicator
function contains_status() {
	local stat="$1"
	[[ $stat == "dirty" ]] && stat="%{%F{166}⚑%f%}"
	[[ $stat == "diverged" ]] && stat="%{%F{208}◆%f%}"
	[[ $stat == "no-upstream" ]] && stat="%{%F{30}◆%f%}"
	[[ $stat == "perfect" ]] && stat="%{%F{28}●%f%}"
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