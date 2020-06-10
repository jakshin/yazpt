#!/bin/zsh
# Tests for operation while zsh is emulating other shells.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
test_dir="$(pwd -P)"
source ./utils.zsh
before_tests $script_name

# Test
function test_under_emulation() {
	local emulate=$1
	local preset=$2  # Optional

	unload
	emulate -L $emulate
	# echo "Emulating $(emulate)"

	source "$test_dir/../yazpt.zsh-theme"
	[[ $? == 0 ]] || echo "Sourcing yazpt.zsh-theme exited with code $?"

	if [[ -n $preset ]]; then
		yazpt_load_preset $preset
		[[ $? == 0 ]] || echo "Loading preset $preset exited with code $?"
	fi

	yazpt_precmd
	[[ $? == 0 ]] || echo "yazpt_precmd exited with code $?"

	yazpt_preexec
	[[ $? == 0 ]] || echo "yazpt_preexec exited with code $?"
}

function unload() {
	# Unload yazpt completely, but preserve $YAZPT_COMPILE and $YAZPT_READ_RC_FILE
	local saved_compile=$YAZPT_COMPILE saved_read_rc_file=$YAZPT_READ_RC_FILE
	functions yazpt_plugin_unload > /dev/null && yazpt_plugin_unload
	YAZPT_COMPILE=$saved_compile
	YAZPT_READ_RC_FILE=$saved_read_rc_file
}

test_case "Emulating zsh (basic sanity check)"
test_under_emulation zsh > output 2>&1
equals "Output/errors" "$(<output)" ""
test_under_emulation zsh yolo > output 2>&1
equals "Output/errors" "$(<output)" ""

test_case "Emulating sh"
test_under_emulation sh > output 2>&1
equals "Output/errors" "$(<output)" ""
test_under_emulation sh yolo > output 2>&1
equals "Output/errors" "$(<output)" ""

test_case "Emulating ksh"
test_under_emulation ksh > output 2>&1
equals "Output/errors" "$(<output)" ""
test_under_emulation ksh yolo > output 2>&1
equals "Output/errors" "$(<output)" ""

test_case "Emulating csh"
test_under_emulation csh > output 2>&1
equals "Output/errors" "$(<output)" ""
test_under_emulation csh yolo > output 2>&1
equals "Output/errors" "$(<output)" ""

# Clean up
after_tests
