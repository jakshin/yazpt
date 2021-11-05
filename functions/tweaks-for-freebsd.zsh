# Tweaks to make yazpt look better in various FreeBSD-derived environments (hopefully).
# Copyright (c) 2020 Jason Jackson <jasonjackson@pobox.com>. Distributed under GPL v2.0, see LICENSE for details.

function .yazpt_tweak_emoji() {
	emulate -L zsh

	if .yazpt_detect_font "Noto Emoji"; then
		.yazpt_detect_terminal

		if [[ $yazpt_terminal == "xterm" ]]; then
			YAZPT_EXIT_ERROR_CHAR="😬"
			YAZPT_EXIT_OK_CHAR="👊"
			return
		fi

		.yazpt_detect_freebsd_derivative
		if [[ $yazpt_freebsd_derivative != "FuryBSD" && $yazpt_freebsd_derivative != "unknown" ]]; then
			return  # Emoji will likely work
		fi
	fi

	YAZPT_EXIT_ERROR_CHAR=":("
	YAZPT_EXIT_OK_CHAR=":)"
	YAZPT_EXECTIME_CHAR="$yazpt_clock"
}

# -------------------------------------------------------------------------------------------------

# Tries to figure out whether we're running on a FreeBSD derivative, and which one.
# Sets its result into the readonly global $yazpt_freebsd_derivative variable.
# It's probably best to only call this if $OSTYPE begins with "freebsd".
#
function .yazpt_detect_freebsd_derivative() {
	if [[ -z $yazpt_freebsd_derivative ]]; then
		if [[ -d /usr/local/share/ghostbsd ]]; then
			yazpt_freebsd_derivative="GhostBSD"

		elif [[ -x /bin/midnightbsd-version ]]; then
			yazpt_freebsd_derivative="MidnightBSD"

		elif [[ -n "$(find /usr/bin -name "nomadbsd-*" -maxdepth 1 -print -quit)" ]]; then
			yazpt_freebsd_derivative="NomadBSD"

		elif [[ -n "$(find /opt/local/bin -name "furybsd-*" -maxdepth 1 -print -quit)" ]]; then
			yazpt_freebsd_derivative="FuryBSD"

		else
			yazpt_freebsd_derivative="unknown"
		fi
	fi

	typeset -rg yazpt_freebsd_derivative
	[[ $yazpt_freebsd_derivative != "unknown" ]]
}
