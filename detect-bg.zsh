#!/usr/bin/env zsh

script_dir="${${(%):-%x}:A:h}"
source "$script_dir/yazpt.zsh-theme"

# Adjusts yazpt's current colors, if the relevant zsh and terminal support is available,
# so they contrast well against the terminal emulator's current background color.
#
.yazpt_adjust_colors() {
	emulate -L zsh
	local debug=$1  # Any value except empty string turns debug output on

	# Zsh added true color support and the nearcolor module in v5.7 (see http://zsh.sourceforge.net/releases.html),
	# so on lower versions we won't be able to use "#rgb" colors like we need to
	yazpt_zsh_ver=(${(s:.:)ZSH_VERSION})

	if (( $yazpt_zsh_ver[1] < 5 || ($yazpt_zsh_ver[1] == 5 && $yazpt_zsh_ver[2] < 7) )); then
		[[ -n $debug ]] && echo "Not supported on zsh version $ZSH_VERSION"
		return 1
	fi

	[[ -n $yazpt_terminal_truecolor ]] || .yazpt_detect_terminal_truecolor $debug

	(( $+yazpt_terminal_bg )) || .yazpt_detect_terminal_bg $debug
	(( $+yazpt_terminal_bg )) || return 1

	if [[ $yazpt_terminal_truecolor == false ]]; then
		[[ -n $debug ]] && echo "This terminal isn't known to support true color; loading zsh's nearcolor module"
		zmodload zsh/nearcolor
	fi

	# FIXME actually adjust colors...
}

# Tries to figure out the terminal's current background color (based on its theme),
# and whether it's darker or lighter than the default foreground/text color.
# Sets the global readonly $yazpt_terminal_bg associative array.
#
# Some parts are based loosely on https://github.com/rocky/shell-term-background (GPL v2+),
# and https://gist.github.com/XVilka/8346728 was used as a reference.
#
.yazpt_detect_terminal_bg() {
	local debug=$1  # Any value except empty string turns debug output on

	if (( $+yazpt_terminal_bg )); then
		[[ -n $debug ]] && echo "Keeping existing yazpt_terminal_bg: ${(kv)yazpt_terminal_bg}"
		return 0
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

		[[ -n $debug ]] && echo "Got Terminal.app colors with AppleScript: $arr"
		bg_rgb=( $(printf "%.4x %.4x %.4x" $arr[1,3]) )
		fg_rgb=( $(printf "%.4x %.4x %.4x" $arr[4,6]) )
	else
		function .yazpt_read_term_color() {
			# Reads the terminal's response, if any, to a bg/fg color query just sent to it.
			# All terminals I've tested either don't respond, or respond with an Esc, "]10;rgb:", then color info,
			# but some terminate the response with ^G, others with an Esc and backslash. This handles both cases.

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

			local arr=(${(s:/:)str}) i
			for (( i=1; i <= $#arr; i++ )); do
				# Normalize to 4 hex characters for each component of RGB, e.g. for iTerm
				[[ $#arr[$i] == 2 ]] && arr[$i]+="00"
			done

			eval "$var=(\$arr)"
		}

		if [[ -t 0 ]]; then
			local tty_settings="$(stty -g)"  # Save TTY settings
			stty -echo                       # Turn echo to TTY off
		fi

		# Get background color, and if that worked, then foreground color
		echo -en '\e]11;?\a'; .yazpt_read_term_color bg_rgb
		if [[ $#bg_rgb == 3 ]] && echo -en '\e]10;?\a'; .yazpt_read_term_color fg_rgb

		[[ -z $tty_settings ]] || stty "$tty_settings"  # Restore TTY settings
	fi

	if [[ $#bg_rgb != 3 ]]; then
		[[ -n $debug ]] && echo "Couldn't get the terminal's background color"
		return 1
	elif [[ $#fg_rgb != 3 ]]; then
		[[ -n $debug ]] && echo "Couldn't get the terminal's foreground color, using midpoint"
		fg_rgb=(7fff 7fff 7fff)
	fi

	if [[ -n $debug ]]; then
		echo "bg_rgb: $bg_rgb"
		echo "fg_rgb: $fg_rgb"
	fi

	# Calculate the perceived brightness of the bg/fg colors
	# (See https://www.nbdtech.com/Blog/archive/2008/04/27/Calculating-the-Perceived-Brightness-of-a-Color.aspx)
	zmodload -af zsh/mathfunc sqrt
	local -F bg_brightness=$(( sqrt( (0.241 * 0x${bg_rgb[1]}**2) + (0.691 * 0x${bg_rgb[2]}**2) + (0.068 * 0x${bg_rgb[3]}**2) ) ))
	local -F fg_brightness=$(( sqrt( (0.241 * 0x${fg_rgb[1]}**2) + (0.691 * 0x${fg_rgb[2]}**2) + (0.068 * 0x${fg_rgb[3]}**2) ) ))

	if [[ -n $debug ]]; then
		echo "Background brightness: $bg_brightness"
		echo "Foreground brightness: $fg_brightness"
	fi

	local light_bg=false
	(( bg_brightness > fg_brightness )) && light_bg=true

	declare -rgA yazpt_terminal_bg=('rgb' "$bg_rgb" 'brightness' "$bg_brightness" 'light' "$light_bg")
	[[ -n $debug ]] && echo "${(kv)yazpt_terminal_bg}"
}

# Tries to figure out whether the terminal supports 24bit/"true" color.
# Sets its result into the readonly global $yazpt_terminal_truecolor variable.
#
function .yazpt_detect_terminal_truecolor() {
	[[ -n $yazpt_terminal_truecolor ]] && return 0
	yazpt_terminal_truecolor=false  # Pessimism

	if [[ $COLORTERM == *(24bit|truecolor)* ]]; then
		yazpt_terminal_truecolor=true
	else
		[[ -n $yazpt_terminal ]] || .yazpt_detect_terminal

		if [[ $yazpt_terminal == "mintty" ]]; then
			yazpt_terminal_truecolor=true
		elif [[ $yazpt_terminal == "xterm" ]] && (( ${XTERM_VERSION//[a-zA-Z()]/} >= 331 )); then
			yazpt_terminal_truecolor=true
		fi
	fi

	typeset -rg yazpt_terminal_truecolor
	[[ $yazpt_terminal_truecolor == "true" ]]
}

# Returns RGB for a color in the 256-color palette (16 through 255).
# Based on https://stackoverflow.com/a/27165165 and https://jonasjacek.github.io/colors.
#
function .yazpt_rgb() {
	local index=$1  # A number in [16-255]
	local var=$2    # Name of the array variable to assign RGB values to

	if (( 16 <= index && index <= 255 )); then
		if (( index < 232 )); then
			declare -a rgb
			rgb[1]=$(( (index - 16) / 36 ))
			rgb[2]=$(( ((index - 16) % 36) / 6 ))
			rgb[3]=$(( (index - 16) % 6 ))

			local n
			for n in 1 2 3; do
				(( $rgb[$n] == 0 )) || rgb[$n]=$(( $rgb[$n] * 40 + 55 ))
			done

			eval "$var=($rgb)"
		else
			local val=$(( (index - 232) * 10 + 8 ))
			eval "$var=($val $val $val)"
		fi
	fi
}

.yazpt_adjust_colors true
