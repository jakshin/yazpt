# Checks the parts of yazpt's rendering that are prone to weirdness/wackiness, or often need tweaking,
# by displaying the relevant Unicode/emoji characters and environment-detection results.
# Tip: set YAZPT_NO_TWEAKS=true if you want to see what yazpt'd do without tweaks applied.
# Copyright (c) 2020 Jason Jackson <jasonjackson@pobox.com>. Distributed under GPL v2.0, see LICENSE for details.
#
function .yazpt_check() {
	{
		local bright='\e[38;5;151m'
		local normal='\e[0m'

		function .yazpt_check_rprompt() {
			local preset=$1

			yazpt_load_preset ${preset// /}
			YAZPT_EXECTIME_MIN_SECONDS=1
			yazpt_preexec
			sleep 1
			yazpt_precmd
			print -P "$preset: $RPS1"
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
				local length=$lengths[$var_name]
				echo "${(l:$max - $length:)} $var"
			done
		}

		# Try to detect some stuffs, and report what we've found
		echo -n "${bright}Operating system:  ${normal}"

		if [[ $OSTYPE == "darwin"* ]]; then
			echo "macOS"

		elif [[ $OS == "Windows"* || -n $WSL_DISTRO_NAME ]]; then
			source "$yazpt_base_dir/functions/tweaks-for-windows.zsh"
			.yazpt_detect_windows_version
			os="Windows, NT version = $yazpt_windows_version"
			[[ -n $WSL_DISTRO_NAME ]] && os+=" (Windows Subsystem for Linux, $VENDOR)"
			echo "$os"

		elif [[ $OSTYPE == "linux-gnu" ]]; then
			source "$yazpt_base_dir/functions/tweaks-for-linux.zsh"
			.yazpt_detect_linux_distro
			echo "GNU/Linux (distro = $yazpt_linux_distro_name, version $yazpt_linux_distro_version)"
			local linux_or_bsd=true

		elif [[ $OSTYPE == "freebsd"* ]]; then
			source "$yazpt_base_dir/functions/tweaks-for-freebsd.zsh"
			.yazpt_detect_ghostbsd && os="GhostBSD" || os="FreeBSD (or a derivative)"
			echo "$os"
			local linux_or_bsd=true

		else
			echo "unknown"
		fi

		echo "${bright}Zsh shell version: ${normal}${ZSH_VERSION}"
		echo -n "${bright}Terminal emulator: ${normal}"
		.yazpt_detect_terminal
		echo "$yazpt_terminal"

		if [[ $linux_or_bsd == true ]]; then
			echo "\n${bright}Checking the Noto Emoji font...${normal}"

			if ! which fc-list > /dev/null; then
				echo " [Check failed: the fc-list program wasn't found]"
			elif .yazpt_detect_noto_emoji_font; then
				echo -n " Installed: "
				fc-list "Noto Emoji"
			else
				echo " Not installed"
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
		local state_stash=$(typeset -m 'YAZPT_*' | tr '\n' ';')

		# Preview Unicode and emoji characters
		echo "\n${bright}Special characters used by the default preset:${normal}"
		yazpt_load_preset default
		.yazpt_check_variables 'YAZPT_*_CHAR'

		echo "\n${bright}Special characters used by the blues preset:${normal}"
		yazpt_load_preset blues
		.yazpt_check_variables 'YAZPT_EXIT_*_CHAR'

		echo "\n${bright}Special characters used by the yolo preset:${normal}"
		yazpt_load_preset yolo
		.yazpt_check_variables 'YAZPT_EXECTIME_CHAR' 'YAZPT_VCS_WRAPPER_CHARS'

		eval "$(grep -E "(happy|sad)_chars=" "$yazpt_base_dir/presets/yolo-preset.zsh")"
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
		unfunction .yazpt_check_rprompt .yazpt_check_variables
		eval "$state_stash"  # Restore saved settings
	}
}
