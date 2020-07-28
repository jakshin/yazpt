#!/usr/bin/env zsh
# Shows shades and tints of a given color; pass either an index 16-255, or RGB using hex values.
# Based on https://stackoverflow.com/questions/6615002/given-an-rgb-value-how-do-i-create-a-tint-or-shade.

script_dir="${${(%):-%x}:A:h}"
source "$script_dir/../detect-bg.zsh"  # FIXME yazpt.zsh-theme

.yazpt_detect_terminal_truecolor || zmodload zsh/nearcolor  # Run with COLORTERM=24bit to force truecolor on
zmodload zsh/mathfunc  # For int(), rint(), sqrt()

if echo "$1" | grep -Eq '^#?[0-9a-f]{6}$'; then
	hex="${1//\#/}"
	base_color=( $(printf "%d %d %d" "0x$hex[1,2]" "0x$hex[3,4]" "0x$hex[5,6]") )
elif [[ $1 == <-> ]] && (( 16 <= $1 && $1 <= 255 )); then
	.yazpt_rgb $1 base_color
else
	less "$0"
	exit 1
fi

# Apply multiples of the shading/tinting factor to the base color, generating shades & tints
echo "Showing shades and tints of base color $base_color[1] $base_color[2] $base_color[3]\n"
factor=0.027

shades=()
shade=($base_color)

for (( shade_num=0; $shade[1] || $shade[2] || $shade[3]; shade_num++ )); do
	shade_hex="#"

	for i in 1 2 3; do
		shade[$i]=$(( int(rint( $base_color[$i] * (1 - $factor * $shade_num) )) ))
		printf -v hex "%.2x" $shade[$i]
		shade_hex+=$hex
	done

	shades+=($shade_hex)
done

tints=()
tint=($base_color)

for (( tint_num=0; $tint[1] < 255 || $tint[2] < 255 || $tint[3] < 255; tint_num++ )); do
	tint_hex="#"

	for i in 1 2 3; do
		tint[$i]=$(( int(rint( $base_color[$i] + ((255 - $base_color[$i]) * $factor * $tint_num) )) ))
		printf -v hex "%.2x" $tint[$i]
		tint_hex+=$hex
	done

	tints+=($tint_hex)
done

# Display
(( $+yazpt_terminal_bg )) || .yazpt_detect_terminal_bg
bg_brightness_percent=$(( 100 * ${yazpt_terminal_bg[brightness]} / 255 ))

function calc_brightness_difference() {
	local hex=$1
	local var=$2

	local rgb=($hex[2,3] $hex[4,5] $hex[6,7])
	local -F brightness=$(( sqrt( (0.241 * 0x${rgb[1]}**2) + (0.691 * 0x${rgb[2]}**2) + (0.068 * 0x${rgb[3]}**2) ) ))

	local brightness_percent=$(( 100 * $brightness / 255 ))
	local diff=$(( abs(int( $bg_brightness_percent - $brightness_percent )) ))
	(( $diff >= 10 )) || diff="0$diff"

	eval "$var=$diff"
}

for (( i=1; i <= $#shades; i++ )); do
	shade_hex=$shades[$i]
	calc_brightness_difference $shade_hex shade_brightness_diff
	print -Pn "%F{${shade_hex}}\u2588\u2588\u2588\u2588\u2588  ${shade_hex} ($shade_brightness_diff%%)%f"

	tint_hex=$tints[$i]
	calc_brightness_difference $tint_hex tint_brightness_diff
	print -P "\t%F{${tint_hex}}\u2588\u2588\u2588\u2588\u2588  ${tint_hex} ($tint_brightness_diff%%)%f"
done
