# Utilities for testing yazpt. This file is meant to be sourced by each test suite, not invoked directly.
# Copyright (c) 2020 Jason Jackson <jasonjackson@pobox.com>. Distributed under GPL v2.0, see LICENSE for details.

# Colored output
bright='\e[1m'
normal='\e[0m'
warning='\e[38;5;204m'
success='\e[38;5;76m'
failure='\e[38;5;160m'
success_bullet="${success}✔ ${normal}"
failure_bullet="${failure}✖ ${normal}"

# Default VCS behavior settings (overridden in many test suites)
YAZPT_VCS_ORDER=()
YAZPT_GIT_PATHS=()
YAZPT_SVN_PATHS=()
YAZPT_TFVC_PATHS=()

# Avoid unwanted side effects
YAZPT_COMPILE=false
YAZPT_READ_RC_FILE=false

# Utility function which converts the string passed to it to a series of hex characters representing its raw bytes
function convert_to_hex() {
	local str="$1"
	local hex_str hex i

	for (( i=1; i <= $#str; i++ )); do
		printf -v hex %.2x "'$str[$i]"
		hex_str+=$hex
	done

	echo $hex_str
}

# Utility function for getting the current time with higher resolution than seconds,
# since macOS's "date" doesn't allow that
function current_timestamp() {
	perl -MTime::HiRes=time -e 'printf "%.9f\n", time'
}

# Utility function that tries to find a TFVC CLI,
# first checking $path, then a few likely locations on Windows
function find_tfvc_cli() {
	if which tf > /dev/null; then
		tf_cli='tf'
	elif [[ $OS == "Windows"* ]]; then
		local subpath="/Community/Common7/IDE/CommonExtensions/Microsoft/TeamFoundation/Team Explorer/TF.exe"
		local found=$(echo "C:/Program Files"*"/Microsoft Visual Studio/"[[:digit:]]*"$subpath"(nN[1]^on))
		if [[ -n $found ]]; then
			tf_cli="$found"
		else
			found=$(echo "C:/Program Files"*"/Microsoft Visual Studio "[[:digit:]]*"/Common7/IDE/TF.exe"(nN[1]^on))
			[[ -n $found ]] && tf_cli="$found"
		fi
	fi

	if [[ -n $tf_cli && $OS == "Windows"* ]]; then
		if $tf_cli | head -n 1 | grep -Fq "Version 10."; then
			unset tf_cli  # VS 2010 and its TF.exe don't appear to support local workspaces
		fi
	fi
}

# Utility function that initializes variables which are helpful when running the TFVC CLI
function init_tfvc_vars() {
	if [[ $OS == "Windows"* ]]; then
		tf_dir_name='$tf'
		tf_opt_char='/'
	else
		tf_dir_name='.tf'
		tf_opt_char='-'
		tf_args="-collection:https://dev.azure.com/jasonjackson0568 -login:$TF_PAT,"

		if [[ $OSTYPE == "darwin"* ]]; then
			# TEE-CLC apparently needs Java 8 in order to run (it doesn't work on Zulu OpenJDK 12, anyway)
			export JAVA_HOME="$(/usr/libexec/java_home --version 1.8 --failfast)"
		fi
	fi
}

# Utility function that makes TFVC notice local file/folder changes which were made without using the TFVC CLI
function tf_status() {
  $tf_cli status ${=tf_args} -format:detailed | grep -vF -- "-----"
}

# Initializes the test suite
function before_tests() {
	local test_suite="$1"
	local repo_type="$2"

	bright='\e[1m'
	echo -e "${bright}=== Running test suite: $test_suite ===${normal}"

	# We'll need to call yazpt_precmd and yazpt_preexec manually
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
	elif [[ $repo_type == *tfvc* ]]; then
		if [[ $OS != "Windows"* ]]; then
			# As of 4/30/2020, TEE-CLC can't authenticate against Azure DevOps with a PAT anymore
			echo "${warning}⚠ Skipping this test suite because it can only run successfully on Windows${normal}"
			after_tests
			exit
		fi

		find_tfvc_cli
		init_tfvc_vars

		if [[ -z $tf_cli ]]; then
			echo "${warning}⚠ Skipping this test suite because no compatible 'tf' CLI was found${normal}"
			[[ $OS == "Windows"* ]] && echo "(Note that VS 2010's TF.exe isn't compatible, because it doesn't support local workspaces)"
			after_tests
			exit
		fi

		local host=${HOST:-$HOSTNAME}
		local host_parts=(${(s:.:)host})
		local short_host=$host_parts[1]

		if [[ $repo_type == *"tfvc-winky"* ]]; then
			if [[ $TTY == "/dev/cons"* && $TERM_PROGRAM != "Tabby" ]]; then
				# This test fails in Windows Terminal and when launching zsh.exe directly,
				# but I don't think it's yazpt's fault (it works in other terminals)
				echo "${warning}⚠ Skipping this test suite because it doesn't work in this terminal${normal}"
				after_tests
				exit
			fi

			local workspace_name="${short_host}_yazpt_winky_tests"
			local server_path='$/yazpt-tfvc-test/Wîñky-ßränçh 😉'
		else
			local workspace_name="${short_host}_yazpt_tests"
			local server_path='$/yazpt-tfvc-test/Main'
		fi

		if ! $tf_cli workspaces ${=tf_args} $workspace_name > /dev/null; then
			$tf_cli workspace ${=tf_args} -new $workspace_name
		fi

		$tf_cli workfold ${=tf_args} -map -workspace:$workspace_name "$server_path" .
		$tf_cli get ${=tf_args}
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
	yazpt_preexec
	[[ $1 == "" || $1 == "no-standard-tests" ]] || eval $1
	yazpt_precmd

	PROMPT="${PROMPT//$'\n'/}"  # Remove linebreaks for easier comparison
	echo $'\n'"--> \$PROMPT is: $PROMPT"

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
	local has_special_chars="$2"  # Boolean

	if [[ $has_special_chars == true ]]; then
		local prompt_=$(convert_to_hex "$PROMPT")
		local contains_str_=$(convert_to_hex "$contains_str")
	else
		local prompt_="$PROMPT"
		local contains_str_="$contains_str"
	fi

	if [[ $prompt_ == *"$contains_str_"* ]]; then
		echo " ${success_bullet} \$PROMPT contains $contains_str"
		(( passed++ ))
	else
		echo " ${failure_bullet} \$PROMPT does not contain $contains_str"
		(( failed++ ))
	fi
}

# Verifies that $PROMPT contains the given string at the start of its VCS context, in bright text
function contains_context() {
	local context_str="$1"
	local has_special_chars="$2"  # Boolean
	contains "%{%F{255}%}$context_str" $has_special_chars
}

# Verifies that $PROMPT contains the given string at the start of its VCS context, in dim text
function contains_dim_context() {
	local context_str="$1"
	local has_special_chars="$2"  # Boolean
	[[ $OSTYPE == "haiku" ]] && local color=243 || local color=240
	contains "%{%F{$color}%}$context_str" $has_special_chars
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

# Verifies that $PROMPT doesn't contain any of the standard TFVC status indicators
function excludes_tfvc_status() {
	if [[ $PROMPT != *●* && $PROMPT != *⚑* && $PROMPT != *⊠* && $PROMPT != *⌀* ]]; then
		echo " ${success_bullet} \$PROMPT doesn't contain TFVC status"
		(( passed++ ))
	else
		echo " ${failure_bullet} \$PROMPT erroneously contains TFVC status"
		(( failed++ ))
	fi
}

# Verifies that the given file contains the given string
function file_contains() {
	local file="$1" str="$2"
	local display_str="${str//$'\n'/}"
	if grep -Fq "$str" "$file"; then
		echo " ${success_bullet} File '$file' contains string \"$display_str\""
		(( passed++ ))
	else
		echo " ${failure_bullet} File '$file' does not contain string \"$display_str\""
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

# Verifies that preexec_functions contains exactly one of our functions
function has_one_preexec_function() {
	local i count=0
	for (( i=1; i <= $#preexec_functions; i++ )); do
		local fn=$preexec_functions[$i]
		[[ $fn == *"yazpt"* ]] && (( count++ ))
	done

	if [[ $count == 1 ]]; then
		echo " ${success_bullet} The preexec_functions array contains exactly one of our functions"
		(( passed++ ))
	elif [[ $count == 0 ]]; then
		echo " ${failure_bullet} The preexec_functions array doesn't contain one of our functions"
		(( failed++ ))
	else
		echo " ${failure_bullet} The preexec_functions array erroneously contains $count of our functions"
		(( failed++ ))
	fi
}

# Verifies that preexec_functions contains none of our functions
function has_no_preexec_function() {
	local i
	for (( i=1; i <= $#preexec_functions; i++ )); do
		local fn=$preexec_functions[$i]
		if [[ fn == *"yazpt"* ]]; then
			echo " ${failure_bullet} The preexec_functions array erroneously contains one of our functions"
			(( failed++ ))
		fi
	done

	echo " ${success_bullet} The preexec_functions array contains none of our functions"
	(( passed++ ))
}

# Verifies that the given variable equals its expected value
function equals() {
	local val_name=$1
	local actual_val=$2
	local expected_val=$3

	if [[ $actual_val == $expected_val ]]; then
		echo " ${success_bullet} $val_name equals \"$expected_val\""
		(( passed++ ))
	else
		echo " ${failure_bullet} $val_name doesn't equal \"$expected_val\" (\"$actual_val\" instead)"
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
