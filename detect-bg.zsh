#!/usr/bin/env zsh

script_dir="${${(%):-%x}:A:h}"
source "$script_dir/yazpt.zsh-theme"

# Tries to figure out whether the terminal is using dark text on a light background;
# if so, yazpt's presets will try to adjust their colors accordingly.
# Sets the readonly global $yazpt_bg variable to "dark", "light", or "hued".
# Based loosely on https://github.com/rocky/shell-term-background (GPL v2+).
#
.yazpt_detect_bg() {
  local debug=$1

	# if [[ -n $yazpt_bg ]]; then
	# 	return
	# elif [[ $COLORFGBG == "0;"* ]]; then
	# 	yazpt_bg="light"  # FIXME what about hued?
	# 	return
	# elif [[ $COLORFGBG == *";0" ]]; then
	# 	yazpt_bg="dark"
	# 	return
	# fi

	local fg bg
	if [[ $TERM_PROGRAM == 'Apple_Terminal' ]] && (( $TERM_PROGRAM_VERSION < 430 )); then
		# Terminal.app before Catalina doesn't answer xterm-style queries about foreground/background color
		local arr=("${(s:, :)"$(osascript -e "tell application \"Terminal\"
			set myTab to the selected tab of the front window
			set mySettings to myTab's current settings
			copy mySettings's normal text color & mySettings's background color & mySettings's name to stdout
			end tell"
			)"}")

		[[ -n $debug ]] && echo "arr = $arr"
		fg=$(( arr[1] + arr[2] + arr[3] ))
		bg=$(( arr[4] + arr[5] + arr[6] ))
	else
		# local delim=$'\a' fg_arr bg_arr i
		# [[ $OSTYPE == "cygwin" ]] && delim='\'  # FIXME maybe this is actually Mintty-specific?

		if [[ -t 0 ]]; then
			local tty_settings="$(stty -g)"  # Save TTY settings
			stty -echo                       # Turn echo to TTY off
		fi

		# echo -en '\e]10;?\a'; IFS=:/ read -t 0.1 -d $delim -A fg_arr  # Get foreground color
		# echo -en '\e]11;?\a'; IFS=:/ read -t 0.1 -d $delim -A bg_arr  # Get background color
		# [[ -n $debug ]] && echo "fg_arr = ${fg_arr[2,4]//$'\e'/}, bg_arr = ${bg_arr[2,4]//$'\e'/}"
		# [[ -z $tty_settings ]] || stty "$tty_settings"  # Restore TTY settings
		#
		# for (( i=2; i <= 4; i++ )); do
		# 	(( fg+=16#${fg_arr[$i]//[^a-zA-Z0-9]/} ))
		# 	(( bg+=16#${bg_arr[$i]//[^a-zA-Z0-9]/} ))
		# done

		local fg_arr bg_arr i
		echo -en '\e]10;?\a'; .yazpt_read_term_color fg_arr  # Get foreground color
		echo -en '\e]11;?\a'; .yazpt_read_term_color bg_arr  # Get background color
		[[ -z $tty_settings ]] || stty "$tty_settings"       # Restore TTY settings

		[[ -n $debug ]] && echo "fg_arr = $fg_arr, bg_arr = $bg_arr"

		for (( i=1; i <= 3; i++ )); do
			(( fg+=16#${fg_arr[$i]} ))
			(( bg+=16#${bg_arr[$i]} ))
		done
	fi

	if (( fg < bg )); then
		# FIXME declare -rg
		# FIXME what about hued?
		yazpt_bg="light"
	else
		yazpt_bg="dark"
	fi

	if [[ -n $debug ]]; then
		echo "fg: $fg, bg: $bg"
		echo "background: $yazpt_bg"
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

.yazpt_detect_bg true
