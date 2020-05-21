# Tweaks to make yazpt look better in various GNU/Linux environments (hopefully).
# Copyright (c) 2020 Jason Jackson <jasonjackson@pobox.com>. Distributed under GPL v2.0, see LICENSE for details.

# Changes the checkmark character for better rendering,
# based on the detected distro and terminal emulator.
#
function .yazpt_tweak_checkmark() {
	.yazpt_detect_terminal

	if [[ $yazpt_terminal == "konsole" ]]; then
		# Kubuntu's Konsole doesn't display the default checkmark nicely
		[[ $VENDOR != "ubuntu" ]] || YAZPT_EXIT_OK_CHAR="✓"

	elif [[ $yazpt_terminal == "xterm" ]]; then
		# Only Ubuntu's XTerm displays the default checkmark nicely
		[[ $VENDOR == "ubuntu" ]] || YAZPT_EXIT_OK_CHAR="✓"
	fi
}

# Changes the hand and face emoji for better rendering, potentially to happy/sad emoticons,
# based on the detected terminal emulator.
#
function .yazpt_tweak_emoji() {
	.yazpt_detect_terminal

	if [[ $yazpt_terminal == "konsole" ]]; then
		if [[ $VENDOR == "suse" ]] && ! .yazpt_detect_noto_emoji_font; then
			YAZPT_EXIT_ERROR_CHAR="😬"  # Only one full-color face emoji renders in openSUSE Tumbleweed 20200511
		fi

	elif [[ $yazpt_terminal == "xterm" ]]; then
		if .yazpt_detect_xterm_emoji_support; then
			YAZPT_EXIT_ERROR_CHAR="😬"
			YAZPT_EXIT_OK_CHAR="👊"
		else
			YAZPT_EXIT_ERROR_CHAR=":("
			YAZPT_EXIT_OK_CHAR=":)"
		fi
	fi
}

# Changes the hourglass character for better rendering,
# based on the detected distro, terminal emulator, and emoji handling.
#
function .yazpt_tweak_hourglass() {
	emulate -L zsh
	.yazpt_detect_linux_distro

	if [[ $yazpt_linux_distro_name == "debian" ]]; then
		# Need more space after the hourglass in both GNOME Terminal and XTerm
		YAZPT_EXECTIME_CHAR+=" "

	elif [[ $yazpt_linux_distro_name == "debian" || $yazpt_linux_distro_name == "fedora" ]]; then
		# Need more space after the hourglass in GNOME Terminal (but not XTerm)
		.yazpt_detect_terminal
		[[ $yazpt_terminal == "gnome-terminal" ]] && YAZPT_EXECTIME_CHAR+=" "

	else
		.yazpt_detect_terminal

		if [[ $yazpt_terminal == "xterm" ]]; then
			if (( ${XTERM_VERSION//[a-zA-Z()]/} < 330 )); then
				YAZPT_EXECTIME_CHAR=""

			elif [[ $yazpt_linux_distro_name == "opensuse-tumbleweed" ]]; then
				# With the Noto Emoji font installed, the Unicode hourglass is rendered wrong, but the emoji hourglass looks fine
				.yazpt_detect_noto_emoji_font && YAZPT_EXECTIME_CHAR="$yazpt_hourglass_emoji"

			elif [[ $yazpt_linux_distro_name == "manjarolinux" ]]; then
				# Manjaro XFCE's XTerm is a weird special case
				YAZPT_VCS_STATUS_LOCKED_CHAR="⌧"
				YAZPT_VCS_STATUS_LINKED_BARE_CHAR="→"
			fi

		elif [[ $(echo $YAZPT_EXECTIME_CHAR | wc -L) == 1 ]]; then
			YAZPT_EXECTIME_CHAR="$yazpt_hourglass_emoji"  # The emoji is rendered monochrome, with ANSI color
		fi
	fi
}

# Changes the hourglass emoji for better rendering,
# based on the detected distro and terminal emulator.
#
function .yazpt_tweak_hourglass_emoji() {
	emulate -L zsh
	.yazpt_detect_terminal

	if [[ $yazpt_terminal == "konsole" ]]; then
		# We get better spacing with the Unicode hourglass (both hourglasses are rendered the same anyway)
		YAZPT_EXECTIME_CHAR="$yazpt_hourglass"

	elif [[ $yazpt_terminal == "xterm" ]]; then
		if (( ${XTERM_VERSION//[a-zA-Z()]/} < 330 )); then
			YAZPT_EXECTIME_CHAR=""

		elif [[ $VENDOR == "suse" ]]; then
			# Use the Unicode hourglass, unless the Noto Emoji font is installed
			.yazpt_detect_noto_emoji_font || YAZPT_EXECTIME_CHAR="$yazpt_hourglass"

		else
			# In all other distros I've tested except Debian 10, both hourglasses look identical,
			# but the spacing after the default Unicode hourglass is better (not overly large)
			if [[ $VENDOR != "debian" ]]; then
				YAZPT_EXECTIME_CHAR="$yazpt_hourglass"
			else
				# Still switch to the Unicode hourglass if we're in a Debian derivative like MX Linux
				.yazpt_detect_linux_distro; [[ $yazpt_linux_distro_name == "debian" ]] || YAZPT_EXECTIME_CHAR="$yazpt_hourglass"
			fi
		fi
	fi
}

# -------------------------------------------------------------------------------------------------

# Tries to identify the running GNU/Linux distro and its version.
# Sets its results into the global $yazpt_linux_distro_name & $yazpt_linux_distro_version variables.
#
function .yazpt_detect_linux_distro() {
	emulate -L zsh
	setopt extended_glob

	if [[ -z $yazpt_linux_distro_name || $yazpt_linux_distro_name == "unknown" ||
				-z $yazpt_linux_distro_version || $yazpt_linux_distro_version == "-1" ]]; then
		typeset +r -g yazpt_linux_distro_name yazpt_linux_distro_version
		local name version

		eval "$(source /etc/lsb-release &> /dev/null && echo name=\"${DISTRIB_ID:l}\" && echo version=\"$DISTRIB_RELEASE\")"
		[[ $version =~ "^[[:digit:].]+$" ]] || version=""

		if [[ -z $name || -z $version ]]; then
			eval "$(source /etc/os-release &> /dev/null && echo name=\"${ID:l}\" && echo version=\"$VERSION_ID\")"
			[[ $version =~ "^[[:digit:].]+$" ]] || version=""
		fi

		if [[ -z $name || -z $version ]]; then
			yazpt_linux_distro_name="unknown"
			yazpt_linux_distro_version="-1"
			return 1
		fi

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
	if .yazpt_detect_linux_distro; then
		local distro=$yazpt_linux_distro_name version=$yazpt_linux_distro_version

		if	( [[ $distro == "debian" ]] && (( $version >= 10 )) ) ||
				( [[ $distro == "manjarolinux" ]] && (( $version >= 20 )) ) ||
				( [[ $distro == "opensuse-tumbleweed" ]] && (( $version >= 20200500 )) ) ||
				( [[ $distro == "ubuntu" && $XDG_CURRENT_DESKTOP != "KDE" ]] && (( $version >= 19.10 )) )
		then
			# We can use some emoji if the Noto Emoji font is installed
			.yazpt_detect_noto_emoji_font && return 0
		fi
	fi

	return 1
}
