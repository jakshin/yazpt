# Tweaks to make yazpt look better in various Windows environments (hopefully).
# Copyright (c) 2020 Jason Jackson <jasonjackson@pobox.com>. Distributed under GPL v2.0, see LICENSE for details.

# Changes the checkmark character for better rendering,
# based on the detected terminal emulator.
#
function .yazpt_tweak_checkmark() {
	emulate -L zsh
	.yazpt_detect_terminal

	if [[ $yazpt_terminal == "mintty" ]]; then
		# Minty can have issues with the default checkmark, depending on its configuration
		# (It does render fine with both DejaVu Sans Mono and color emoji support enabled)
		YAZPT_EXIT_OK_CHAR="✓"
	fi
}

# Changes the hand and face emoji for better rendering, potentially to happy/sad emoticons,
# based on the detected terminal emulator.
#
function .yazpt_tweak_emoji() {
	emulate -L zsh
	.yazpt_detect_terminal

	if [[ $yazpt_terminal == "conemu" ]]; then
		YAZPT_EXIT_ERROR_CHAR=":("  # ConEmu mangles our hand/face emoji
		YAZPT_EXIT_OK_CHAR=":)"
	fi
}

# Changes the hourglass character for better rendering,
# based on the detected Windows version and/or terminal emulator.
#
function .yazpt_tweak_hourglass() {
	emulate -L zsh
	.yazpt_detect_terminal

	if [[ $yazpt_terminal == "mintty" ]]; then
		.yazpt_detect_windows_version
		[[ $yazpt_windows_version == 6.1 ]] && YAZPT_EXECTIME_CHAR=""

	elif [[ $yazpt_terminal == "conemu" ]]; then
		# The Unicode hourglass character isn't rendered right, even with the DejaVu Sans Mono font,
		# but the hourglass emoji is A-OK in Windows 10
		.yazpt_detect_windows_version
		if (( $yazpt_windows_version >= 10 )); then
			YAZPT_EXECTIME_CHAR="$yazpt_hourglass_emoji"
		else
			YAZPT_EXECTIME_CHAR=""
		fi

	elif [[ $yazpt_terminal == "terminus" ]]; then
		# We get better spacing between the hourglass and text if we use the hourglass emoji
		# (Terminus renders our default Unicode hourglass character as an emoji anyway)
		YAZPT_EXECTIME_CHAR="$yazpt_hourglass_emoji"
	fi
}

# Changes the hourglass emoji for better rendering, based on the detected terminal emulator
# (and, if it's Mintty, whether color emoji support is enabled).
#
function .yazpt_tweak_hourglass_emoji() {
	emulate -L zsh
	.yazpt_detect_terminal

	if [[ $yazpt_terminal == "mintty" ]]; then
		# We get better spacing with the default Unicode hourglass, iff Mintty's color emoji support isn't enabled;
		# when emoji support is enabled/disabled, the change won't be noticed until the yolo preset is reloaded
		.yazpt_detect_mintty_emoji_support || YAZPT_EXECTIME_CHAR="$yazpt_hourglass"

	elif [[ $yazpt_terminal == "conemu" ]]; then
		# The emoji hourglass is only rendered right in Windows 10
		# (and the Unicode hourglass isn't rendered right in any Windows version)
		.yazpt_detect_windows_version
		(( $yazpt_windows_version >= 10 )) || YAZPT_EXECTIME_CHAR=""

	elif [[ $yazpt_terminal == "mobaxterm" ]]; then
		# MobaXterm renders emoji as tiny little monochrome line drawings, which oh well,
		# and also puts the emoji hourglass too far from the related text, which we can fix
		YAZPT_EXECTIME_CHAR="$yazpt_hourglass"
	fi
}

# -------------------------------------------------------------------------------------------------

# Tries to figure out whether Mintty has emoji support installed.
# Doesn't cache its result (a preset load should update the value).
#
function .yazpt_detect_mintty_emoji_support() {
	local cfg_path=~/.minttyrc
	if [[ -n $WSL_DISTRO_NAME ]]; then
		local appdata_path="$(wslpath "$APPDATA" 2> /dev/null)"
		[[ -n $appdata_path && -f "$appdata_path/wsltty/config" ]] && cfg_path="$appdata_path/wsltty/config"
	fi

	if [[ -f $cfg_path && -r $cfg_path ]]; then
		local cfg_lines=(${(f)"$(< $cfg_path)"}) emoji=false i=1

		for (( i=1; i <= $#cfg_lines; i++ )); do
			local line=$cfg_lines[$i]
			if [[ $line == "Emojis="* ]]; then
				[[ $line == "Emojis=none" ]] || return 0
			fi
		done
	fi

	return 1  # No emoji support, or we couldn't find Mintty's config file
}

# Tries to figure out which major version of Windows we're running on.
# Sets its result into the readonly global $yazpt_windows_version variable
# (10.x means Windows 10, 6.3 means Windows 8.1, 6.1 means Windows 7).
#
function .yazpt_detect_windows_version() {
	[[ -n $yazpt_windows_version ]] && return

	if [[ -n $WSL_DISTRO_NAME ]]; then
		# In WSL, uname shows Linux info, but WSL only exists on Windows 10+
		declare -rg yazpt_windows_version=10
	else
		local os="$(uname -s)"
		local os_parts=(${(s:-:)os})
		declare -rg yazpt_windows_version=$os_parts[2]  # Cache indefinitely
	fi
}
