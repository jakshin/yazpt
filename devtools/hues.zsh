#!/usr/bin/env zsh
# Shows shades and tints of a given color; pass either an index 16-255, or RGB using hex values.
# Based on https://stackoverflow.com/questions/6615002/given-an-rgb-value-how-do-i-create-a-tint-or-shade.

zmodload zsh/mathfunc  # For int() and rint()
[[ $COLORTERM == *(24bit|truecolor)* ]] || zmodload zsh/nearcolor  # FIXME use .yazpt_adjust_colors's logic

if echo "$1" | grep -Eq '^#?[0-9a-f]{6}$'; then
	hex="${1//\#/}"
	base_color=( $(printf "%d %d %d" "0x$hex[1,2]" "0x$hex[3,4]" "0x$hex[5,6]") )
elif [[ $1 == <-> ]] && (( 16 <= $1 && $1 <= 255 )); then
	script_dir="${${(%):-%x}:A:h}"
	source "$script_dir/calc.zsh"
	.yazpt_rgb $1 base_color
else
	less "$0"
	exit 1
fi

# Apply multiples of the shading/tinting factor to the base color, generating shades & tints
echo "Showing hues of base color $base_color[1] $base_color[2] $base_color[3]\n"
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
# FIXME show each hue's percent difference from the background's brightness
(( $#shades > $#tints )) && count=$#shades || count=$#tints

for (( i=1; i <= count; i++ )); do
	shade_hex=$shades[$i]
	tint_hex=$tints[$i]

	if [[ -n $shade_hex ]]; then
		print -Pn "%F{${shade_hex}}\u2588\u2588\u2588\u2588\u2588  ${shade_hex}%f"
	else
		echo "       "
	fi

	if [[ -n $tint_hex ]]; then
		echo -n "    "
		print -P "%F{${tint_hex}}\u2588\u2588\u2588\u2588\u2588  ${tint_hex}%f"
	else
		echo
	fi
done
