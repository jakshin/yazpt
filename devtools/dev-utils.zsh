# Utility declarations and functions, for use in devtool scripts.

# Colors.
local header='\e[38;5;151m'
local normal='\e[0m'

# Saves yazpt's current settings, so they can be be restored later,
# after being manipulated for testing, debugging, previewing, etc.
# Run `eval "$_yazpt_state_stash"` to restore any saved settings.
#
function .yazpt_stash_settings() {
	_yazpt_state_stash=$(typeset -m 'YAZPT_*' | tr '\n' ';')
}
