# Tweaks to make yazpt look better in various FreeBSD-derived environments (hopefully).
# Copyright (c) 2020 Jason Jackson <jasonjackson@pobox.com>. Distributed under GPL v2.0, see LICENSE for details.

# Changes the hand and face emoji to happy/sad emoticons,
# unless we're in XTerm on GhostBSD with the Noto Emoji font installed.
#
function .yazpt_tweak_emoji() {
	emulate -L zsh
	.yazpt_detect_terminal

	if [[ $yazpt_terminal == "xterm" ]] && .yazpt_detect_xterm_emoji_support; then
		YAZPT_EXIT_ERROR_CHAR="😬"
		YAZPT_EXIT_OK_CHAR="👊"
	else
		YAZPT_EXIT_ERROR_CHAR=":("
		YAZPT_EXIT_OK_CHAR=":)"
	fi
}

# Changes the hourglass character for better rendering.
#
function .yazpt_tweak_hourglass() {
	emulate -L zsh

	if .yazpt_detect_font "Noto Emoji"; then
		YAZPT_EXECTIME_CHAR+=" "
	elif ! .yazpt_detect_ghostbsd; then
		YAZPT_EXECTIME_CHAR=""
	fi
}

# Changes the hourglass emoji, which gets mangled, to the Unicode version (which doesn't).
#
function .yazpt_tweak_hourglass_emoji() {
	YAZPT_EXECTIME_CHAR="$yazpt_hourglass"
	.yazpt_tweak_hourglass
}

# -------------------------------------------------------------------------------------------------

# Tries to figure out whether we're running on GhostBSD.
# Sets its result into the readonly global $yazpt_ghostbsd variable.
#
function .yazpt_detect_ghostbsd() {
	if [[ -z $yazpt_ghostbsd ]]; then
		local ghostbsd=false
		[[ -d /usr/local/share/ghostbsd ]] && ghostbsd=true
		declare -rg yazpt_ghostbsd=$ghostbsd  # Cache indefinitely
	fi

	[[ $yazpt_ghostbsd == true ]]
}

# Tries to figure out whether we're in a BSD environment where XTerm can handle a few emoji,
# just monochrome but nice enough to display; everywhere else, we'll fall back to emoticons.
#
function .yazpt_detect_xterm_emoji_support() {
	.yazpt_detect_font "Noto Emoji"
}
