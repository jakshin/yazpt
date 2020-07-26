#!/usr/bin/env zsh

script_dir="${${(%):-%x}:A:h}"
source "$script_dir/yazpt.zsh-theme"

# Adjusts yazpt's current colors, if the relevant zsh and terminal support is available,
# so they contrast well against the terminal emulator's current background color.
# Some parts are based loosely on https://github.com/rocky/shell-term-background (GPL v2+).
#
.yazpt_adjust_colors() {
	emulate -L zsh

	# Zsh added true color support and the nearcolor module in v5.7 (see http://zsh.sourceforge.net/releases.html),
	# so on lower versions we won't be able to use a "#rgb" color
	yazpt_zsh_ver=(${(s:.:)ZSH_VERSION})

	if (( $yazpt_zsh_ver[1] < 5 || ($yazpt_zsh_ver[1] == 5 && $yazpt_zsh_ver[2] < 7) )); then
		echo "Not supported on zsh v$ZSH_VERSION"
		return 1
	fi

	# Determine whether we need to use nearcolor for this terminal
	local truecolor=false

	if [[ $COLORTERM == *(24bit|truecolor)* ]]; then
		truecolor=true
	else
		[[ -n $yazpt_terminal ]] || .yazpt_detect_terminal

		if [[ $yazpt_terminal == "mintty" ]]; then
			truecolor=true
		elif [[ $yazpt_terminal == "xterm" ]] && (( ${XTERM_VERSION//[a-zA-Z()]/} >= 331 )); then
			truecolor=true
		fi
	fi

	if [[ $truecolor == true ]]; then
		echo "This terminal supports true color"
	else
		echo "This terminal isn't known to support true color; loading zsh's nearcolor module"
		zmodload zsh/nearcolor
	fi

	# Get colors from the terminal
	local bg_rgb fg_rgb

	if [[ $TERM_PROGRAM == 'Apple_Terminal' ]] && (( $TERM_PROGRAM_VERSION < 430 )); then
		# Terminal.app before Catalina doesn't answer XTerm-style queries about foreground/background color
		local arr=("${(s:, :)"$(osascript -e "tell application \"Terminal\"
			set myTab to the selected tab of the front window
			set mySettings to myTab's current settings
			copy mySettings's background color & mySettings's normal text color to stdout
			end tell"
			)"}")

		bg_rgb=( $(printf "%.4x %.4x %.4x" $arr[1,3]) )
		fg_rgb=( $(printf "%.4x %.4x %.4x" $arr[4,6]) )
	else
		if [[ -t 0 ]]; then
			local tty_settings="$(stty -g)"  # Save TTY settings
			stty -echo                       # Turn echo to TTY off
		fi

		# Get background color, and if that worked, then foreground color
		echo -en '\e]11;?\a'; .yazpt_read_term_color bg_rgb
		[[ $#bg_rgb == 3 ]] && echo -en '\e]10;?\a'; .yazpt_read_term_color fg_rgb

		[[ -z $tty_settings ]] || stty "$tty_settings"  # Restore TTY settings
	fi

	if [[ $#bg_rgb != 3 ]]; then
		echo "Couldn't get the terminal's background color"
		return 1
	elif [[ $#fg_rgb != 3 ]]; then
		echo "Couldn't get the terminal's foreground color, using midpoint"
		fg_rgb=(7fff 7fff 7fff)
	fi

	echo "bg_rgb: $bg_rgb"
	echo "fg_rgb: $fg_rgb"

	local bg_brightness=0 fg_brightness=0 i=1

	for (( i=1; i <= 3; i++ )); do
		[[ $#$bg_rgb[$i] == 2 ]] && bg_rgb[$i]+="00"
		[[ $#$fg_rgb[$i] == 2 ]] && fg_rgb[$i]+="00"

		# FIXME https://www.nbdtech.com/Blog/archive/2008/04/27/Calculating-the-Perceived-Brightness-of-a-Color.aspx
		(( bg_brightness+=16#${bg_rgb[$i]} ))
		(( fg_brightness+=16#${fg_rgb[$i]} ))
	done

	echo "Background brightness: $bg_brightness"
	echo "Foreground brightness: $fg_brightness"

	if (( bg_brightness > fg_brightness )); then
		echo "Background is light"
	else
		echo "Background is dark"
	fi
}

# \e]10;rgb:c10a/c10b/c10a\a
# \e]10;rgb:eeee/eeee/ecec\e\
function .yazpt_read_term_color() {
	local var=$1  # The array variable to store the terminal's response in

	local ch colon=false str
	while read -t 0.1 -k ch; do
		if [[ $ch == $'\a' || $ch == '\' ]]; then
			break
		elif [[ $colon == true ]]; then
			[[ $ch == $'\e' ]] || str+="$ch"
		elif [[ $ch == ':' ]]; then
			colon=true
		fi
	done

	eval "$var=(\${(s:/:)str})"
}

.yazpt_adjust_colors
