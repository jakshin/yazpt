#!/bin/zsh
# Tests for making presets.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name

# Test
test_case "Try to save a preset as a directory"
source "$yazpt_default_preset_file"
YAZPT_CWD_COLOR=123
mkdir foo
yazpt_make_preset ./foo
return_code=$?
equals return_code $return_code "1"

test_case "Try to save a preset with no changes"
source "$yazpt_default_preset_file"
YAZPT_VCS_ORDER=(svn)
yazpt_make_preset ./nothing.zsh -e
return_code=$?
equals return_code $return_code "1"

test_case "Save a preset over a symlink"
source "$yazpt_default_preset_file"
unset YAZPT_VCS_WRAPPER_CHARS
echo "# Dummy" > dummy.zsh
ln -sv dummy.zsh link
yazpt_make_preset -f ./link
cat link
file_contains link "unset YAZPT_VCS_WRAPPER_CHARS"

test_case "Save a new preset with various changes"
source "$yazpt_default_preset_file"
YAZPT_CWD_COLOR=75             # Change a value
YAZPT_EXIT_ERROR_CHAR=''       # Change a value to empty string
YAZPT_VCS_WRAPPER_CHARS=( )    # Change a value's type -> array
YAZPT_VCS_GIT_WHITELIST=''     # Change an array value's type -> empty string
unset YAZPT_EXIT_ERROR_COLOR   # Unset a value
unset YAZPT_VCS_SVN_WHITELIST  # Unset an array value
YAZPT_EXTRA_STRING=foobar      # Add an extra value
YAZPT_EXTRA_ARRAY=( foo bar )  # Add an extra array
YAZPT_EXTRA_EMPTY_STRING=''    # Add an extra empty string
YAZPT_EXTRA_EMPTY_ARRAY=( )    # Add an extra empty array
touch test.zsh
yazpt_make_preset -f ./test.zsh
cat test.zsh
file_contains test.zsh "YAZPT_CWD_COLOR=75"$'\n'
file_contains test.zsh "YAZPT_EXIT_ERROR_CHAR=''"$'\n'
file_contains test.zsh "YAZPT_VCS_WRAPPER_CHARS=(  )"$'\n'
file_contains test.zsh "YAZPT_VCS_GIT_WHITELIST=''"$'\n'
file_contains test.zsh "unset YAZPT_EXIT_ERROR_COLOR"$'\n'
file_contains test.zsh "unset YAZPT_VCS_SVN_WHITELIST"$'\n'
file_contains test.zsh "YAZPT_EXTRA_STRING=foobar"$'\n'
file_contains test.zsh "YAZPT_EXTRA_ARRAY=( foo bar )"$'\n'
file_contains test.zsh "YAZPT_EXTRA_EMPTY_STRING=''"$'\n'
file_contains test.zsh "YAZPT_EXTRA_EMPTY_ARRAY=(  )"$'\n'

# Clean up
after_tests
