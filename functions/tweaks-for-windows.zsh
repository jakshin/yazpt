# Tweaks to make yazpt look better in various Windows environments (hopefully).
# On WSL, we detect only Mintty/WSLtty, MobaXterm, and Windows Terminal,
# and Tabby iff $TERM_PROGRAM is manually set; we can't detect ConEmu or MS console.
# Copyright (c) 2020 Jason Jackson <jasonjackson@pobox.com>. Distributed under GPL v2.0, see LICENSE for details.

function .yazpt_tweak_checkmark() {
	emulate -L zsh
	.yazpt_detect_terminal

	if [[ $yazpt_terminal == "mintty" ]]; then
		# Mintty can have issues with the default checkmark, depending on its configuration
		# (It does render fine with both DejaVu Sans Mono and color emoji support enabled)
		YAZPT_EXIT_OK_CHAR="✓"

	elif [[ $yazpt_terminal == "windows-terminal" ]]; then
		# The default checkmark is rendered in green, which is kinda cool, but eh
		YAZPT_EXIT_OK_CHAR="✓"

	elif [[ $yazpt_terminal == "ms-console" ]]; then
		# The default checkmark gets rendered nicely, but with an empty tofu box just after it
		YAZPT_EXIT_OK_CHAR="✓"

	elif [[ -n $WSL_DISTRO_NAME && $yazpt_terminal == "unknown" ]]; then
		YAZPT_EXIT_OK_CHAR="✓"
	fi
}

function .yazpt_tweak_emoji() {
	emulate -L zsh
	.yazpt_detect_terminal

	local downgrade=false
	if [[ $yazpt_terminal == "mintty" ]]; then
		.yazpt_detect_mintty_emoji_support || downgrade=true

	elif [[ $yazpt_terminal == "conemu" || $yazpt_terminal == "ms-console" ]]; then
		downgrade=true  # ConEmu and MS console can't display our emoji

	elif [[ -n $WSL_DISTRO_NAME && $yazpt_terminal == "unknown" ]]; then
		downgrade=true
	fi

	if [[ $downgrade == true ]]; then
		YAZPT_EXIT_ERROR_CHAR=":("
		YAZPT_EXIT_OK_CHAR=":)"
		YAZPT_EXECTIME_CHAR="$yazpt_clock"
	fi
}

function .yazpt_tweak_for_vscode() {
	# Some of yazpt's Unicode is rendered awkwardly in VS Code's terminal's default font on Windows

	emulate -L zsh

	[[ $YAZPT_VCS_STATUS_DIRTY_CHAR == "⚑" ]] && \
		YAZPT_VCS_STATUS_DIRTY_CHAR="⛿ "

	[[ $YAZPT_VCS_STATUS_DIVERGED_CHAR == "◆" ]] && \
		YAZPT_VCS_STATUS_DIVERGED_CHAR="♦"

	[[ $YAZPT_VCS_STATUS_NO_UPSTREAM_CHAR == "◆" ]] && \
		YAZPT_VCS_STATUS_NO_UPSTREAM_CHAR="♦"

	[[ $YAZPT_EXIT_ERROR_CHAR == "✘" ]] && \
		YAZPT_EXIT_ERROR_CHAR+=" "

	[[ $YAZPT_VCS_STATUS_LINKED_BARE_CHAR == "↪" ]] && \
		YAZPT_VCS_STATUS_LINKED_BARE_CHAR+=" "

	[[ $YAZPT_VCS_STATUS_LOCKED_CHAR == "⊠" ]] && \
		YAZPT_VCS_STATUS_LOCKED_CHAR+=" "
}

# -------------------------------------------------------------------------------------------------

# Tries to figure out whether Mintty/WSLtty has emoji support installed.
# Doesn't cache its result (a preset load should update the value).
#
function .yazpt_detect_mintty_emoji_support() {
	if [[ -n $WSL_DISTRO_NAME ]]; then
		local appdata_path="$(wslpath "$APPDATA" 2> /dev/null)"
		local cfg_path="$appdata_path/wsltty/config"
		[[ -f $cfg_path ]] || cfg_path=""
	fi

	if [[ -z $cfg_path ]]; then
		local cfg_path=~/.minttyrc
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

	return 1  # No emoji support, or we couldn't find Mintty's/WSLtty's config file
}

# Tries to figure out which major version of Windows we're running on.
# Sets its result into the readonly global $yazpt_windows_version variable.
#
function .yazpt_detect_windows_version() {
	[[ -n $yazpt_windows_version ]] && return

	local os="$(uname -s)"
	local os_parts=(${(s:-:)os})

	if [[ $os_parts[2] == "10."* ]]; then
		# Distinguish between Windows 10 and Windows 11
		yazpt_windows_version="$(wmic os get Caption | grep -Eo "[[:digit:]]+")"
	elif [[ $os_parts[2] == "6.3" ]]; then
		yazpt_windows_version=8
	elif [[ $os_parts[2] == "6.1" ]]; then
		yazpt_windows_version=7
	fi

	typeset -rg yazpt_windows_version  # Cache indefinitely
}
