#!/bin/zsh
# Tests for yazpt's path prefix lists.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name

function test_path_prefix_list() {
	array_name=$1
	if .yazpt_check_path $array_name; then
		echo "allowed"
	else
		echo "rejected"
	fi
}

# Test
test_case "Empty path prefix list allows any path"
empty_array=()
result=$(test_path_prefix_list empty_array)
equals "Result" $result "allowed"

test_case "Path prefix list with short prefix of current path allows it"
list=(dummy ${TMPDIR:-/tmp/})
result=$(test_path_prefix_list list)
equals "Result" $result "allowed"

test_case "Path prefix list with different prefix rejects the current directory"
list=(/foo ~/Documents)
result=$(test_path_prefix_list list)
equals "Result" $result "rejected"

test_case "Path prefix list matching current directory allows it"
cwd="$(pwd)"
list=($cwd)
result=$(test_path_prefix_list list)
equals "Result" $result "allowed"

test_case "Path prefix list matching current directory, but with trailing slash, rejects it"
cwd="$(pwd)/"
list=($cwd)
result=$(test_path_prefix_list list)
equals "Result" $result "rejected"

# Clean up
after_tests
