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
for bg in $bg_colors; do
	clear
	echo "\e[48;5;${bg}m\e[J"

	echo "Background color $bg"
	[[ $preview_script == *"yolo"* ]] && echo
	"$script_dir/$preview_script"

	echo -n '\nPress a key to continue, or Ctrl+C to exit... '
	read -rs -k1
done

clear
