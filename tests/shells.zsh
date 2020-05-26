#!/bin/zsh
# Tests for trying to load yazpt with shells other than zsh.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
test_dir="$(pwd -P)"
source ./utils.zsh
before_tests $script_name

# Test
function test_with_shell() {
	local shell=$1
	local src_cmd=$2  # Optional

	if which $shell > /dev/null; then
		test_case "Loading with $shell"
		output="$($shell -c "${src_cmd:-source} $test_dir/../yazpt.zsh-theme" 2>&1)"
		equals "Output" "$output" "Sorry, the yazpt prompt theme only works on zsh."
	fi
}

test_with_shell ash '.'
test_with_shell bash
test_with_shell csh
test_with_shell dash '.'
# test_with_shell fish
# test_with_shell ksh
test_with_shell mksh
test_with_shell posh '.'
test_with_shell sh '.'
test_with_shell tcsh

if which rzsh > /dev/null; then
	test_case "Loading with rzsh (zsh in restricted mode)"
	output="$(rzsh -c "source $test_dir/../yazpt.zsh-theme" 2>&1)"
	equals "Output" "$output" "Sorry, the yazpt prompt theme doesn't work on restricted zsh."
fi

# Clean up
after_tests
