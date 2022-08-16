# Tweaks to make yazpt look better in various GNU/Linux environments (hopefully).
# Copyright (c) 2020 Jason Jackson <jasonjackson@pobox.com>. Distributed under GPL v2.0, see LICENSE for details.

function .yazpt_tweak_checkmark() {
	emulate -L zsh
	.yazpt_detect_terminal

	if [[ $yazpt_terminal == "konsole" ]]; then
		# Konsole doesn't display the default checkmark nicely in Kubuntu or KDE neon
		[[ $VENDOR != "ubuntu" ]] || YAZPT_EXIT_OK_CHAR="✓"

	elif [[ $yazpt_terminal == "xterm" ]]; then
		# On a couple distros, XTerm doesn't display the default checkmark nicely
		.yazpt_detect_linux_distro

		if [[ $yazpt_linux_distro_name == "fedora" || $VENDOR == "suse" ]]; then
			YAZPT_EXIT_OK_CHAR="✓"
		fi
	fi
}

function .yazpt_tweak_emoji() {
	emulate -L zsh
	.yazpt_detect_linux_distro
	.yazpt_detect_terminal

	if [[ $yazpt_terminal == "konsole" ]]; then

		if [[ $yazpt_linux_distro_name == "kali" ]]; then
			# Emoji are awful in Kali's QTerminal (detected as Konsole), not worth displaying at all,
			# unless the Noto Color Emoji font is installed, and even then only one face renders well
			.yazpt_detect_font "Noto Color Emoji" && YAZPT_EXIT_ERROR_CHAR="😬" || .yazpt_use_emoticons

		elif [[ $VENDOR == "slackware" || $VENDOR == "suse" ]]; then
			# With Noto Color Emoji installed, we have decent color emoji (except only one "sad" face renders properly),
			# UNLESS Noto Emoji is installed, in which case emoji are monochrome, and only a couple are worth displaying
			if .yazpt_detect_font "Noto Emoji"; then
				.yazpt_use_safe_emoji
			elif .yazpt_detect_font "Noto Color Emoji"; then
				YAZPT_EXIT_ERROR_CHAR="😬"
			else
				.yazpt_use_emoticons
			fi

		elif [[ $yazpt_linux_distro_name == "ubuntu" && $XDG_CURRENT_DESKTOP == "LXQt" ]]; then
			# Lubuntu's QTerminal only handles some monochrome emoji,
			# and only if the Noto Emoji font has been manually installed
			.yazpt_detect_font "Noto Emoji" && .yazpt_use_safe_emoji || .yazpt_use_emoticons
		fi

	elif [[ $yazpt_terminal == "xterm" ]]; then
		.yazpt_detect_xterm_emoji_support && .yazpt_use_safe_emoji || .yazpt_use_emoticons

	elif [[ $yazpt_linux_distro_name == "amzn" || $yazpt_linux_distro_name == "bodhi" ]]; then
		.yazpt_use_emoticons

	elif [[ $yazpt_linux_distro_name == "antix" ||
			$yazpt_linux_distro_name == "endeavouros" ||
			$yazpt_linux_distro_name == "kali" ]]
	then
		.yazpt_detect_font "Noto Color Emoji" || .yazpt_use_emoticons
	fi
}

# -------------------------------------------------------------------------------------------------

# Tries to identify the running GNU/Linux distro and its version.
# Sets its results into the global $yazpt_linux_distro_name & $yazpt_linux_distro_version variables.
#
function .yazpt_detect_linux_distro() {
	setopt extended_glob

	if [[ -z $yazpt_linux_distro_name || $yazpt_linux_distro_name == "unknown" ||
				-z $yazpt_linux_distro_version || $yazpt_linux_distro_version == "-1" ]]; then
		typeset +r -g yazpt_linux_distro_name yazpt_linux_distro_version
		local name version desc

		eval "$(source /etc/lsb-release &> /dev/null && \
				echo name=\"${DISTRIB_ID:l}\" && \
				echo version=\"$DISTRIB_RELEASE\" && \
				echo desc=\"$DISTRIB_DESCRIPTION\")"

		if [[ -z $name || -z $version ]]; then
			eval "$(source /etc/os-release &> /dev/null && \
					echo name=\"${ID:l}\" && \
					echo version=\"${VERSION_ID:-$IMAGE_VERSION}\")"
		fi

		if [[ -z $name ]]; then
			yazpt_linux_distro_name="unknown"
			yazpt_linux_distro_version=""
			return 1
		fi

		if [[ $VENDOR == "ubuntu" && $desc == *"Bodhi"* ]]; then
			name="bodhi"
			version="${desc/* /}"
		fi

		# Version might not be numeric (e.g. "rolling"), but if it is, allow one dot at most
		while [[ $version == *.*.* ]]; do
			version=${version%%.[[:digit:]]#}
		done

		yazpt_linux_distro_name="$name"
		yazpt_linux_distro_version="$version"
		typeset -rg yazpt_linux_distro_name yazpt_linux_distro_version
	fi
}

# Tries to figure out whether we're in a GNU/Linux environment where XTerm can handle a few emoji,
# just monochrome but nice enough to display; everywhere else, we'll fall back to emoticons.
#
function .yazpt_detect_xterm_emoji_support() {
	local xterm_version=${XTERM_VERSION/*\(/}
	xterm_version=${xterm_version/)/}

	if [[ -z $xterm_version ]] || (( $xterm_version < 330 )); then
		return 1
	fi

	if .yazpt_detect_linux_distro; then
		local distro=$yazpt_linux_distro_name version=$yazpt_linux_distro_version

		if	( [[ $distro == "bodhi" ]] && (( $version >= 6 )) ) ||
				( [[ $distro == "debian" ]] && (( $version >= 10 )) ) ||
				( [[ $distro == "linuxmint" ]] && (( $version >= 20.1 )) ) ||
				( [[ $distro == "manjarolinux" ]] && (( $version >= 20 )) ) ||
				( [[ $distro == "opensuse-tumbleweed" ]] && (( $version >= 20200500 )) ) ||
				( [[ $distro == "pop" ]] && (( $version >= 20.10 )) ) ||
				( [[ $distro == "slackware" ]] && (( $version >= 14.2 )) ) ||
				( [[ $distro == "ubuntu" && $XDG_CURRENT_DESKTOP != "KDE" ]] && (( $version >= 19.10 )) ) ||
				( [[ $distro == "ubuntu" ]] && (( $version >= 21.04 )) ) ||
				( [[ $distro == "zorin" ]] && (( $version >= 16 )) )
		then
			# We can use some emoji if the Noto Emoji font is installed
			.yazpt_detect_font "Noto Emoji" && return 0
		fi
	fi

	return 1
}

# Tweaks the yolo preset's settings to replace emoji hand/face with emoticons.
#
function .yazpt_use_emoticons() {
	YAZPT_EXIT_ERROR_CHAR=":("
	YAZPT_EXIT_OK_CHAR=":)"
	YAZPT_EXECTIME_CHAR="$yazpt_clock"
}

# Tweaks the yolo preset's settings to use only hand/face emoji which are widely supported.
#
function .yazpt_use_safe_emoji() {
	YAZPT_EXIT_ERROR_CHAR="😬"
	YAZPT_EXIT_OK_CHAR="👊"
}
