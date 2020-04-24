#!/bin/zsh
# Tests for the "char" segment's prompt character.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name

real_os=$OS

# Test
test_case "Running on Windows, as Administrator"
unset _yazpt_char
OS="Windows_XX"
function net() {
	return 0
}
test_init_done "no-standard-tests"
contains "# "
excludes "%#"
OS=$real_os
unfunction net

test_case "Running on Windows, as a regular user"
unset _yazpt_char
OS="Windows_XX"
function net() {
	return 2  # 'net session' returns this error when run as a regular user
}
test_init_done  # Standard tests suffice in this case
OS=$real_os
unfunction net

test_case "Running on an OS other than Windows"
unset _yazpt_char
OS="dummy"
test_init_done  # Standard tests suffice in this case
OS=$real_os

test_case "Using a cached value"
_yazpt_char='@@@'
function net() {
	# This unexpected output will trigger a test failure
	echo "THIS FUNCTION SHOULDN'T HAVE RUN"
}
test_init_done "no-standard-tests"
contains '@@@'
unfunction net

# Clean up
after_tests
