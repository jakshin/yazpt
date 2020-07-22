#!/usr/bin/env zsh
# Shows shades of a given color.
# Based on https://stackoverflow.com/questions/6615002/given-an-rgb-value-how-do-i-create-a-tint-or-shade.
# FIXME this is only a stub so far

color_str="00d7ff"
color=("00" "d7" "ff")

print -P "%F{#$color_str}This is the base color%f ($color_str)"

shade90r=$(( 0x$color[1] * (1 - 0.1) ))
shade90g=$(( 0x$color[2] * (1 - 0.1) ))
shade90b=$(( 0x$color[3] * (1 - 0.1) ))

shade90r=$(printf "%.0f" "$shade90r")
shade90g=$(printf "%.0f" "$shade90g")
shade90b=$(printf "%.0f" "$shade90b")

echo "shade 90% = $shade90r $shade90g $shade90b"

shade90r=$(printf "%02x" "$shade90r")
shade90g=$(printf "%02x" "$shade90g")
shade90b=$(printf "%02x" "$shade90b")
shade90="$shade90r$shade90g$shade90b"

print -P "%F{#$shade90}This is the shaded color%f ($shade90)"
