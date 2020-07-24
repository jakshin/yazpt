# Returns RGB for colors 16 through 255 in the 256-color palette.
# Based on https://stackoverflow.com/a/27165165, verified with https://jonasjacek.github.io/colors.
#
function .yazpt_rgb() {
	local index=$1
	local var=$2

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
