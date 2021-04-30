# Checks the parts of yazpt's rendering that are prone to weirdness/wackiness, or often need tweaking,
# by displaying the relevant Unicode/emoji characters and environment-detection results.
# Run `YAZPT_NO_TWEAKS=true .yazpt_check` if you want to see what yazpt'd do without tweaks applied.
#
# Copyright (c) 2020 Jason Jackson <jasonjackson@pobox.com>. Distributed under GPL v2.0, see LICENSE for details.
#
function .yazpt_check() {
	{
		emulate -L zsh
		local bright='\e[38;5;151m'
		local normal='\e[0m'

		function .yazpt_check_font() {
			local font=$1
			setopt local_options extended_glob

			if .yazpt_detect_font "${font//# #/}"; then
				echo -n " $font: "
				fc-list "$font"
			else
				echo " $font: Not installed"
			fi
		}

		function .yazpt_check_rprompt() {
			local preset=$1

			yazpt_load_preset ${preset// /}
			YAZPT_EXECTIME_MIN_SECONDS=1
			yazpt_preexec
			sleep 1
			yazpt_precmd
			print -P "$preset: $RPS1"  # Should already be escaped
		}

		function .yazpt_check_variables() {
			local vars=(${(f)"$(declare -m "$@")"})
			vars=(${(i)vars})  # Sort alphabetically

			local i max=0
			declare -A lengths=()

			for (( i=1; i <= $#vars; i++ )); do
				local var=$vars[$i]
				[[ $var == *= ]] && continue

				local var_name=${var%%=*}
				lengths[$var_name]=$#var_name
				(( $#var_name > $max )) && max=$#var_name
			done

			for (( i=1; i <= $#vars; i++ )); do
				local var=${vars[$i]//[$\']/}
				[[ $var == *= ]] && continue

				local var_name=${var%%=*}
				if [[ $var_name == *"_CHARS" ]]; then
					var=${var/\( /}; var=${var/ \)/}; var=${var// /}  # Prep the array for nice display
				fi

				local length=$lengths[$var_name]
				echo "${(l:$max - $length:)} $var"
			done
		}

		# Try to detect some stuffs, and report what we've found
		echo -n "${bright}Operating system:  ${normal}"

		if [[ $OSTYPE == "darwin"* ]]; then
			echo "macOS"

		elif [[ $OS == "Windows"* ]]; then
			source "$yazpt_base_dir/functions/tweaks-for-windows.zsh"
			.yazpt_detect_windows_version
			echo "Windows, NT version = $yazpt_windows_version"

		elif [[ -n $WSL_DISTRO_NAME ]]; then
			echo "Windows Subsystem for Linux ($VENDOR)"

		elif [[ $OSTYPE == "linux-gnu" ]]; then
			source "$yazpt_base_dir/functions/tweaks-for-linux.zsh"
			.yazpt_detect_linux_distro
			echo "GNU/Linux (distro = $yazpt_linux_distro_name, version $yazpt_linux_distro_version)"

		elif [[ $OSTYPE == "freebsd"* ]]; then
			source "$yazpt_base_dir/functions/tweaks-for-freebsd.zsh"
			.yazpt_detect_ghostbsd && os="GhostBSD" || os="FreeBSD (or a derivative)"
			echo "$os"

		elif [[ $OSTYPE == "haiku" ]]; then
			echo "Haiku"
		else
			echo "unknown"
		fi

		echo "${bright}Zsh shell version: ${normal}${ZSH_VERSION}"

		echo -n "${bright}Terminal emulator: ${normal}"
		typeset +r -g yazpt_terminal="" yazpt_terminal_info=""
		.yazpt_detect_terminal
		echo "$yazpt_terminal ($yazpt_terminal_info)"

		if [[ $OSTYPE != "darwin"* && $OS != "Windows"* ]]; then
			echo "\n${bright}Checking the Noto emoji fonts...${normal}"

			if ! which fc-list > /dev/null; then
				echo " [Check failed: the fc-list program wasn't found]"
			else
				.yazpt_check_font "      Noto Emoji"
				.yazpt_check_font "Noto Color Emoji"
			fi
		fi

		if [[ $yazpt_terminal == "xterm" ]] && functions .yazpt_detect_xterm_emoji_support > /dev/null; then
			echo "\n${bright}Checking $XTERM_VERSION's minimal monochrome emoji support...${normal}"

			if .yazpt_detect_xterm_emoji_support; then
				echo " We think it'll work (👊 😬)"
			else
				echo " We don't think it'll work (👊 😬)"
			fi
		fi

		if [[ $yazpt_terminal == "mintty" ]]; then
			echo "\n${bright}Checking Mintty's color emoji support...${normal}"

			if .yazpt_detect_mintty_emoji_support; then
				echo " Enabled 🎉"
			else
				echo " Disabled (or Mintty's config file wasn't found) 😞"
			fi
		fi

		# Save current settings before we overwrite them
		local state_stash=$(typeset -m 'YAZPT_*' -m '_yazpt_*' | tr '\n' ';')

		# Preview Unicode and emoji characters
		echo "\n${bright}Special characters used by the default preset:${normal}"
		yazpt_load_preset default
		.yazpt_check_variables 'YAZPT_*_CHAR'

		echo "\n${bright}Special characters used by the sapphire preset:${normal}"
		yazpt_load_preset sapphire
		.yazpt_check_variables 'YAZPT_EXIT_*_CHAR'

		echo "\n${bright}Special characters used by the yolo preset:${normal}"
		yazpt_load_preset yolo
		.yazpt_check_variables 'YAZPT_EXECTIME_CHAR' 'YAZPT_VCS_WRAPPER_CHARS'

		eval "$(grep -aE "(happy|sad)_chars=" "$yazpt_base_dir/presets/yolo-preset.zsh")"
		echo "  hands: $_yazpt_yolo_happy_chars"
		echo "  faces: $_yazpt_yolo_sad_chars"

		declare -a chosen_hands=() chosen_faces=()
		for (( i=1; i <= 5; i++ )); do
			(( i == 1 )) || yazpt_load_preset yolo
			chosen_hands+=($YAZPT_EXIT_OK_CHAR)
			chosen_faces+=($YAZPT_EXIT_ERROR_CHAR)
		done

		echo " chosen: $chosen_hands $chosen_faces"

		echo "\n${bright}Hourglass characters:${normal}"
		echo " Unicode: [$yazpt_hourglass]"
		echo "   Emoji: [$yazpt_hourglass_emoji]"

		echo "\n${bright}Previewing the right-hand prompt...${normal}"
		.yazpt_check_rprompt " default"
		.yazpt_check_rprompt "    yolo"

	} always {
		unfunction .yazpt_check_font .yazpt_check_rprompt .yazpt_check_variables
		eval "$state_stash"  # Restore saved settings
	}
}
