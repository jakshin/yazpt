#!/usr/bin/env zsh
# Previews (most of) yazpt's presets, using synthetic values for cwd, git branch and status,
# to make it easier to see how they look in any given terminal theme.

emulate -L zsh
setopt no_prompt_subst

script_dir="${${(%):-%x}:A:h}"
source "$script_dir/../yazpt.zsh-theme"

# FIXME special consideration for spearmint's bright white input
# FIXME special consideration for yolo's random colors, monochrome emoji colors

# Tweak some settings and override the "git" segment's function
YAZPT_VCS_ORDER=(git)
YAZPT_GIT_PATHS=()

function @yazpt_segment_git() {
	local color=$YAZPT_VCS_CONTEXT_COLOR
	[[ $_yazpt_preview_in_meta_dir == true ]] && color=$YAZPT_VCS_CONTEXT_META_COLOR
	yazpt_state[git]="%{%F{$color}%}feature-branch%{%f%}"

	local char
	for char in $(typeset -m 'YAZPT_VCS_*_CHAR' | sort | tr '\n' ' '); do
		local char_color="${char//_CHAR=*/_COLOR}"
		eval "char_color=${(P)char_color}"

		eval "${char//*=/char=}"
		[[ -z $char ]] || yazpt_state[git]+=" %{%F{$char_color}%}$char%{%f%}"
	done

	local extra=""
	if [[ $_yazpt_terminus_hacks == true ]]; then
		extra=" "
		yazpt_state[git]+="$extra"
	fi

	.yazpt_add_vcs_wrapper_chars "git" "$color" "$extra"
}

# Show a synthetic preview of the presets
local preset presets=(${(f)"$(yazpt_list_presets)"})

for preset in $presets; do
	[[ $preset == "dense" || $preset == "elementary" ]] && continue  # Too much like "default" to bother
	[[ $preset == "yolo" ]] && continue  # See preview-yolo.zsh

	yazpt_load_preset $preset
	echo "\n\t$preset:"

	YAZPT_LAYOUT=${YAZPT_LAYOUT//$'\n'/}
	YAZPT_LAYOUT=${YAZPT_LAYOUT//<char>/}

	if [[ -n $YAZPT_RLAYOUT ]]; then
		[[ $preset == "sapphire" ]] && YAZPT_LAYOUT+=$'\t'
		YAZPT_LAYOUT+=$'\t'$YAZPT_RLAYOUT
		YAZPT_RLAYOUT=""
	fi

	_yazpt_cmd_exec_start=$(( SECONDS - 7242 ))
	_yazpt_preview_in_meta_dir=false
	yazpt_precmd
	PS1=${PS1//\%~/"~/Documents/Foo"}
	print -P "\t$PS1"

	_yazpt_preview_in_meta_dir=true
	(exit 123)
	yazpt_precmd
	PS1=${PS1//\%~/"~/Documents/Foo"}
	print -P "\t$PS1"
done
