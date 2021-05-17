# Tweaks to make yazpt look better in various FreeBSD-derived environments (hopefully).
# Copyright (c) 2020 Jason Jackson <jasonjackson@pobox.com>. Distributed under GPL v2.0, see LICENSE for details.

function .yazpt_tweak_emoji() {
	emulate -L zsh
	.yazpt_detect_terminal

	if [[ $yazpt_terminal == "xterm" ]] && .yazpt_detect_font "Noto Emoji"; then
		YAZPT_EXIT_ERROR_CHAR="😬"
		YAZPT_EXIT_OK_CHAR="👊"
	else
		YAZPT_EXIT_ERROR_CHAR=":("
		YAZPT_EXIT_OK_CHAR=":)"
		YAZPT_EXECTIME_CHAR="$yazpt_clock"
	fi
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
