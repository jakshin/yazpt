#!/usr/bin/env zsh
# Previews (most of) yazpt's presets, using synthetic values for cwd, git branch and status,
# to make it easier to see how they look in any given terminal theme.
# FIXME ability to run without color adjustments?
# FIXME special consideration for spearmint's bright white input

script_dir="${${(%):-%x}:A:h}"
source "$script_dir/../yazpt.zsh-theme"
source "$script_dir/dev-utils.zsh"
.yazpt_mock_git_segment

local preset presets=(${(f)"$(yazpt_list_presets)"})
for preset in $presets; do
	[[ $preset == "dense" || $preset == "elementary" ]] && continue  # Too much like "default" to bother

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
