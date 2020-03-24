# Utilities for testing yazpt.
# This file is meant to be sourced by each test suite, not invoked directly.

# Colored output
bright='\e[1m'
normal='\e[0m'
success='\e[38;5;76m'
failure='\e[38;5;160m'
success_bullet="${success}✔${normal}"
failure_bullet="${failure}✖︎${normal}"

# Utility function for getting the current time with higher resolution than seconds,
# since macOS's "date" doesn't allow that
function current_timestamp() {
	perl -MTime::HiRes=time -e 'printf "%.9f\n", time'
}

# Initializes the test suite
function before_tests() {
	local test_suite="$1"
	local repo_type="$2"

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

	# Might need to clone or check out a repo
	if [[ $repo_type == *git* ]]; then
		git clone "https://github.com/jakshin/yazpt-test.git" .
	elif [[ $repo_type == *svn-root* ]]; then
		svn checkout "https://svn.riouxsvn.com/yazpt-svn-test" .
	elif [[ $repo_type == *svn* ]]; then
		svn checkout "https://svn.riouxsvn.com/yazpt-svn-test/trunk" .
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
	local stat="$1" stat_str

	if [[ $stat == "clean" ]]; then
		stat_str="%{%F{29}%}●%{%f%}"
	elif [[ $stat == "conflict" ]]; then
		stat_str="%{%F{9}%}≠%{%f%}"
	elif [[ $stat == "dirty" ]]; then
		stat_str="%{%F{208}%}⚑%{%f%}"
	elif [[ $stat == "diverged" ]]; then
		stat_str="%{%F{166}%}◆%{%f%}"
	elif [[ $stat == "locked" ]]; then
		stat_str="%{%F{229}%}⊠%{%f%}"
	elif [[ $stat == "no-upstream" ]]; then
		stat_str="%{%F{31}%}◆%{%f%}"
	elif [[ $stat == "unknown" ]]; then
		stat_str="%{%F{9}%}⌀%{%f%}"
	else
		stat_str="~~~ [not a known status] ~~~"
	fi

	contains $stat_str
}

# Verifies that $PROMPT doesn't contain any of the standard Git status indicators
function excludes_git_status() {
	if [[ $PROMPT != *⚑* && $PROMPT != *◆* && $PROMPT != *●* && $PROMPT != *⌀* && $PROMPT != *⚭* ]]; then
		echo " ${success_bullet} \$PROMPT doesn't contain Git status"
		(( passed++ ))
	else
		echo " ${failure_bullet} \$PROMPT erroneously contains Git status"
		(( failed++ ))
	fi
}

# Verifies that $PROMPT doesn't contain any of the standard Subversion status indicators
function excludes_svn_status() {
	if [[ $PROMPT != *●* && $PROMPT != *⚑* && $PROMPT != *⊠* && $PROMPT != *≠* && $PROMPT != *⌀* ]]; then
		echo " ${success_bullet} \$PROMPT doesn't contain Subversion status"
		(( passed++ ))
	else
		echo " ${failure_bullet} \$PROMPT erroneously contains Subversion status"
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

# Verifies that the given variable equals its expected value
function equals() {
	local val_name=$1
	local actual_val=$2
	local expected_val=$3

	if [[ $actual_val == $expected_val ]]; then
		echo " ${success_bullet} $val_name equals $expected_val"
		(( passed++ ))
	else
		echo " ${failure_bullet} $val_name doesn't equal $expected_val ($actual_val instead)"
		(( failed++ ))
	fi
}

# Verifies that the first variable given is less than the second variable given
function first_is_less() {
	local val1_name=$1
	local val1=$2
	local val2_name=$3
	local val2=$4

	if (( $val1 < $val2 )); then
		echo " ${success_bullet} $val1_name is less than $val2_name"
		(( passed++ ))
	else
		echo " ${failure_bullet} $val1_name ($val1) isn't less than $val2_name ($val2)"
		(( failed++ ))
	fi
}
