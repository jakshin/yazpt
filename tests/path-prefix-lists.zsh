#!/bin/zsh
# Tests for yazpt's path prefix whitelists.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name

function test_whitelist() {
	array_name=$1
	if .yazpt_check_whitelist $array_name; then
		echo "allowed"
	else
		echo "rejected"
	fi
}

# Test
test_case "Empty whitelist allows any path"
empty_array=()
result=$(test_whitelist empty_array)
equals "Whitelist result" $result "allowed"

test_case "Whitelist with short prefix of current path allows it"
whitelist=(dummy ${TMPDIR:-/tmp/})
result=$(test_whitelist whitelist)
equals "Whitelist result" $result "allowed"

test_case "Whitelist with different prefix rejects the current directory"
whitelist=(/foo ~/Documents)
result=$(test_whitelist whitelist)
equals "Whitelist result" $result "rejected"

test_case "Whitelist matching current directory allows it"
cwd="$(pwd)"
whitelist=($cwd)
result=$(test_whitelist whitelist)
equals "Whitelist result" $result "allowed"

test_case "Whitelist matching current directory, but with trailing slash, rejects it"
cwd="$(pwd)/"
whitelist=($cwd)
result=$(test_whitelist whitelist)
equals "Whitelist result" $result "rejected"

# Clean up
after_tests
