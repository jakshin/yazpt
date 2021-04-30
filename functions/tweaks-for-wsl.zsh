# Tweaks to make yazpt look better in Windows Subsystem for Linux (hopefully).
# On WSL, we detect only Mintty/WSLtty, MobaXterm, and Windows Terminal,
# and Terminus iff $TERM_PROGRAM is manually set; we can't detect ConEmu or MS console.
# Copyright (c) 2021 Jason Jackson <jasonjackson@pobox.com>. Distributed under GPL v2.0, see LICENSE for details.

# Changes the checkmark character for better rendering, if needed.
#
function .yazpt_tweak_checkmark() {
	emulate -L zsh
	.yazpt_detect_terminal

	if [[ $yazpt_terminal == "mintty" || $yazpt_terminal == "windows-terminal" || $yazpt_terminal == "unknown" ]]; then
		YAZPT_EXIT_OK_CHAR="✓"
	fi
}

# Changes the hand and face emoji to happy/sad emoticons, if needed.
#
function .yazpt_tweak_emoji() {
	emulate -L zsh
	.yazpt_detect_terminal

	if [[ $yazpt_terminal == "unknown" ]]; then
		YAZPT_EXIT_ERROR_CHAR=":("
		YAZPT_EXIT_OK_CHAR=":)"
	fi
}

# Changes the hourglass character to a "clock" character, if needed.
#
function .yazpt_tweak_hourglass() {
	emulate -L zsh
	.yazpt_detect_terminal

	if [[ $yazpt_terminal == "unknown" ]]; then
		YAZPT_EXECTIME_CHAR="◷ "  # Looks like a clock, if you squint
	fi
}

# Changes the hourglass emoji to the Unicode hourglass or a "clock" character, if needed.
#
function .yazpt_tweak_hourglass_emoji() {
	emulate -L zsh
	.yazpt_detect_terminal

	if [[ $yazpt_terminal == "mintty" ]]; then
		# We get better spacing with the default Unicode hourglass, iff WSLtty's color emoji support isn't enabled;
		# when emoji support is enabled/disabled, the change won't be noticed until the yolo preset is reloaded
		.yazpt_detect_wsltty_emoji_support || YAZPT_EXECTIME_CHAR="$yazpt_hourglass"

	elif [[ $yazpt_terminal == "mobaxterm" || $yazpt_terminal == "terminus" ]]; then
		YAZPT_EXECTIME_CHAR="$yazpt_hourglass"

	elif [[ $yazpt_terminal == "unknown" ]]; then
		YAZPT_EXECTIME_CHAR="◷ "
	fi
}

# -------------------------------------------------------------------------------------------------

# Tries to figure out whether WSLtty has emoji support installed.
# Doesn't cache its result (a preset load should update the value).
#
function .yazpt_detect_wsltty_emoji_support() {
	local appdata_path="$(wslpath "$APPDATA" 2> /dev/null)"
	local cfg_path="$appdata_path/wsltty/config"

	if [[ -f $cfg_path && -r $cfg_path ]]; then
		local cfg_lines=(${(f)"$(< $cfg_path)"}) emoji=false i=1

		for (( i=1; i <= $#cfg_lines; i++ )); do
			local line=$cfg_lines[$i]
			if [[ $line == "Emojis="* ]]; then
				[[ $line == "Emojis=none" ]] || return 0
			fi
		done
	fi

	return 1  # No emoji support, or we couldn't find WSLtty's config file
}
