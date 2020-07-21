#!/usr/bin/env zsh

emulate -L zsh
script_dir="${${(%):-%x}:A:h}"
script_name="${${(%):-%x}:A:t}"

function usage() {
	echo "Previews yazpt's presets on different background colors\n"
	echo "Usage: $script_name [options]\n"
	echo "Options:"
	echo "  --bg=value, --backgrounds=value"
	echo "    Allowed values: all (default), numbered, rgbcube, grayscale, NUM (0-255)"
	echo "  --presets=value"
	echo "    Allowed values: all (default), yolo"
	exit 1
}

# Parse the command line
# FIXME ability to run without color adjustments?
backgrounds="all"
presets="all"

for arg; do
	if [[ $arg == "--bg="* || $arg == "--backgrounds="* ]]; then
		backgrounds=${arg//*=/}
	elif [[ $arg == "--preset="* || $arg == "--presets="* ]]; then
		presets=${arg//*=/}
	else
		usage
	fi
done

if [[ $backgrounds == "all" ]]; then
	bg_colors=({0..255})
elif [[ $backgrounds == "numbered" ]]; then
	bg_colors=({0..15})
elif [[ $backgrounds == "rgbcube" ]]; then
	bg_colors=({16..231})
elif [[ $backgrounds == "grayscale" ]]; then
	bg_colors=({232..255})
elif [[ $backgrounds == <-> ]] && (( 0 <= backgrounds && backgrounds <= 255 )); then
	bg_colors=($backgrounds)  # Single numeric background color
else
	usage
fi

if [[ $presets == "all" ]]; then
	preview_script="preview-presets.zsh"
elif [[ $presets == "yolo" ]]; then
	preview_script="preview-yolo.zsh"
else
	usage
fi

# Do the things
function echo_readable() {
	local bg=$1
	shift

	if (( (0 <= bg && bg <= 9) || (16 <= bg && bg <= 33) || (52 <= bg && bg <= 63) || (88 <= bg && bg <= 99) ||
		(124 <= bg && bg <= 135) || (160 <= bg && bg <= 165) || (196 <= bg && bg <= 201) || (232 <= bg && bg <= 245) ))
	then
		local fg=255
	else
		local fg=0
	fi

	echo -e "\e[38;5;${fg}m"
	echo "$@"
}

for bg_color in $bg_colors; do
	clear
	echo -n "\e[48;5;${bg_color}m\e[J"
	echo_readable $bg_color " Background color $bg_color"

	[[ $preview_script == *"yolo"* ]] && echo
	"$script_dir/$preview_script"

	echo_readable $bg_color -n ' Press a key to continue, or Ctrl+C to exit... '
	read -rs -k1
done

clear
