#!/usr/bin/env zsh
# Checks parts of yazpt's rendering that are prone to weirdness/wackiness, or often need tweaking,
# by displaying the relevant Unicode/emoji characters and various environment-detection results.
# Run like `YAZPT_NO_TWEAKS=true check-rendering.zsh` to see what yazpt'd do without tweaks applied.

emulate -L zsh

script_dir="${${(%):-%x}:A:h}"
source "$script_dir/../yazpt.zsh-theme"
source "$script_dir/dev-utils.zsh"

# Utility functions
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
	_yazpt_cmd_exec_start=$(( SECONDS - 1 ))
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
echo -n "${header}Operating system:  ${normal}"

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
	linux_or_bsd=true

elif [[ $OSTYPE == "freebsd"* ]]; then
	source "$yazpt_base_dir/functions/tweaks-for-freebsd.zsh"
	.yazpt_detect_ghostbsd && os="GhostBSD" || os="FreeBSD (or a derivative)"
	echo "$os"
	linux_or_bsd=true

else
	echo "unknown"
fi

echo "${header}Zsh shell version: ${normal}${ZSH_VERSION}"

echo -n "${header}Terminal emulator: ${normal}"
typeset +r -g yazpt_terminal="" yazpt_terminal_info=""
.yazpt_detect_terminal
echo "$yazpt_terminal ($yazpt_terminal_info)"

if [[ $linux_or_bsd == true ]]; then
	echo "\n${header}Checking the Noto emoji fonts...${normal}"

	if ! which fc-list > /dev/null; then
		echo " [Check failed: the fc-list program wasn't found]"
	else
		.yazpt_check_font "      Noto Emoji"
		.yazpt_check_font "Noto Color Emoji"
	fi
fi

if [[ $yazpt_terminal == "mintty" ]]; then
	echo "\n${header}Checking Mintty's color emoji support...${normal}"

	if .yazpt_detect_mintty_emoji_support; then
		echo " Enabled 🎉"
	else
		echo " Disabled (or Mintty's config file wasn't found) 😞"
	fi
elif [[ $yazpt_terminal == "xterm" ]] && functions .yazpt_detect_xterm_emoji_support > /dev/null; then
	echo "\n${header}Checking $XTERM_VERSION's minimal monochrome emoji support...${normal}"

	if .yazpt_detect_xterm_emoji_support; then
		echo " We think it'll work (👊 😬)"
	else
		echo " We don't think it'll work (👊 😬)"
	fi
fi

# Preview Unicode and emoji characters
echo "\n${header}Special characters used by the default preset:${normal}"
yazpt_load_preset default
.yazpt_check_variables 'YAZPT_*_CHAR'

echo "\n${header}Special characters used by the sapphire preset:${normal}"
yazpt_load_preset sapphire
.yazpt_check_variables 'YAZPT_EXIT_*_CHAR'

echo "\n${header}Special characters used by the yolo preset:${normal}"
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

echo "\n${header}Hourglass characters:${normal}"
echo " Unicode: [$yazpt_hourglass]"
echo "   Emoji: [$yazpt_hourglass_emoji]"

echo "\n${header}Previewing the right-hand prompt...${normal}"
.yazpt_check_rprompt " default"
.yazpt_check_rprompt "    yolo"
