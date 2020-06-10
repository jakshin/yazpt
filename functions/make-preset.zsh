# Makes a new preset file containing the current settings;
# Only settings which differ from the defaults are stored.
#
# Pass a preset name to write a preset file alongside the presets shipped with yazpt,
# and which will show up in yazpt_list_presets' output and be auto-completed for yazpt_load_preset,
# or pass a path containing a slash and ending in a filename to write an abitrary file
# wherever you'd like (yazpt_load_preset will still load it, just not auto-complete it).
#
# Copyright (c) 2020 Jason Jackson <jasonjackson@pobox.com>. Distributed under GPL v2.0, see LICENSE for details.
#
function yazpt_make_preset() {
	emulate -L zsh

	# Parse arguments
	declare -a opts=()
	zmodload -F zsh/zutil b:zparseopts
	zparseopts -D -E -a opts e f h -help

	if [[ $opts[(Ie)-h] != 0 || $opts[(Ie)--help] != 0 || $#@ != 1 || $@[1] == "-"* ]]; then
		echo "Makes a new preset file containing the current settings."
		echo "Only settings which differ from defaults are saved.\n"

		echo "Writes a preset file in $yazpt_base_dir/presets,"
		echo "or a file anywhere if you pass a path containing a slash and filename.\n"

		echo "Usage: $0 [options] <preset-name-or-path>\n"
		echo "Options:"
		echo "  -e  Exclude VCS settings which control behavior, not appearance,"
		echo '      i.e. $YAZPT_VCS_ORDER, $YAZPT*_PATHS, $YAZPT*_LOCKS'
		echo "  -f  Overwrite an existing preset file without asking"
		return
	fi

	local preset="$@[1]"	# A preset name, or path to the preset file to write

	# Stash the current settings
	local zle_stash=($zle_highlight)
	local stash=(${(f)"$(typeset -m 'YAZPT_*')"})
	stash=(${${(i)stash}#*:})	# Sort

	# Load the default preset's settings
	unset -m 'YAZPT_*'
	source $yazpt_default_preset_file

	local defaults i setting var val
	declare -A defaults_map=()

	defaults=(${(f)"$(typeset -m 'YAZPT_*')"})
	defaults=(${${(i)defaults}#*:})	# Sort

	for (( i=1; i <= $#defaults; i++ )); do
		setting=$defaults[$i]
		setting=(${(s:=:)setting})	# Split on "="

		var="$setting[1]"
		val="${(j:=:)setting[@]:1}"

		defaults_map[$var]="$val"
	done

	# Restore the stashed settings
	zle_highlight=($zle_stash)
	eval "${(j:; :)stash}"

	# Compare the stashed settings with the defaults, storing any which differ
	local default_val differences="" layouts="" unset=""
	declare -A stash_map=()

	for (( i=1; i <= $#stash; i++ )); do
		setting=$stash[$i]
		setting=(${(s:=:)setting})	# Split on "="

		var="$setting[1]"
		val="${(j:=:)setting[@]:1}"
		default_val="$defaults_map[$var]"
		stash_map[$var]="$val"	# For lookup while iterating $defaults_map below

		[[ $var == 'YAZPT_COMPILE' || $var == 'YAZPT_NO_TWEAKS' || $var == 'YAZPT_READ_RC_FILE' ]] && continue
		if (( $opts[(Ie)-e] )); then
			[[ $var == 'YAZPT_VCS_ORDER' || $var == *'_PATHS' || $var == *'_LOCKS' ]] && continue
		fi

		if [[ ${(t)val} != ${(t)default_val} || $val != $default_val ]]; then
			[[ $val == "$'"* ]] && val=${val//$'\n'/\n}

			if [[ $var == 'YAZPT_LAYOUT' ]]; then
				layouts="$var=$val"$'\n'"$layouts"
			elif [[ $var == 'YAZPT_RLAYOUT' ]]; then
				layouts="$layouts$var=$val"$'\n'
			else
				differences="$differences$var=$val"$'\n'
			fi
		fi
	done

	if [[ -n $layouts ]]; then
		differences="${layouts}${differences}"
		unset layouts
	fi

	local unset=""	# Settings in $defaults_map but not the stash
	for var in ${(k)defaults_map}; do
		if (( $opts[(Ie)-e] )); then
			[[ $var == 'YAZPT_VCS_ORDER' || $var == *'_PATHS' || $var == *'_LOCKS' ]] && continue
		fi

		(( $+stash_map[$var] )) || unset+="unset $var"$'\n'
	done

	# Return if there are no differences
	if [[ -z $differences && -z $unset ]]; then
		echo "You're using default settings, so there's nothing to save to the new preset file"
		return 1
	fi

	# Figure out the output file's path/name
	local preset_file preset_name

	if [[ $preset == */* ]]; then
		preset_file="$preset"
		preset_name=""
	else
		preset_file="$yazpt_base_dir/presets/$preset-preset.zsh"
		preset_name="\"$preset\" "
	fi

	# Prompt if the output file already exists
	if (( ! $opts[(Ie)-f] )) && [[ -f $preset_file ]]; then
		local desc="File"; [[ -L $preset_file ]] && desc="Symlink"
		echo -n "${desc} \"$preset_file\" exists.\nReplace it [y|n]? "
		read -rq
		echo

		[[ $REPLY == "y" ]] || return 0

		if [[ -L $preset_file ]]; then
			# If we just pipe to this symlink below, we'll actually overwrite its target,
			# which seems deceptive, so explicitly remove it before continuing
			rm -f "$preset_file" || return
		fi
	fi

	# Make the new preset file
	echo "# Custom ${preset_name}preset created $(date)" > $preset_file || return
	echo 'source "$yazpt_default_preset_file"\n' >> $preset_file
	[[ -z $differences ]] || echo -En "$differences" >> $preset_file
	[[ -z $differences || -z $unset ]] || echo >> $preset_file
	[[ -z $unset ]] || echo -En "$unset" >> $preset_file
}
