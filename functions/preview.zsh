source /Users/jason/Settings/zsh/themes/yazpt/yazpt.zsh-theme  # FIXME for testing

# FIXME special consideration for spearmint's bright white input
# FIXME special consideration for yolo's random colors, monochrome emoji colors

# Previews yazpt's presets, to make it easier to see how each looks in any given terminal theme.
# Copyright (c) 2020 Jason Jackson <jasonjackson@pobox.com>. Distributed under GPL v2.0, see LICENSE for details.
#
function .yazpt_preview() {
	{
		emulate -L zsh
		setopt no_prompt_subst

		# Save current settings before we overwrite them
		local state_stash=$(typeset -m 'YAZPT_*' | tr '\n' ';')
		local _yazpt_cmd_exec_start_backup=$_yazpt_cmd_exec_start
		eval ".yazpt_segment_git_backup() { $(functions @yazpt_segment_git | tail -n +2)"

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

		local preset presets=(${(f)"$(yazpt_list_presets)"})
		for preset in $presets; do
			[[ $preset == "dense" || $preset == "elementary" ]] && continue  # Too much like default to bother
			#[[ $preset == "yolo" ]] && continue  # FIXME

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

	} always {
		eval "$state_stash"  # Restore saved settings

		eval "@yazpt_segment_git() { $(functions .yazpt_segment_git_backup | tail -n +2)"
		unfunction .yazpt_segment_git_backup

		_yazpt_cmd_exec_start=$_yazpt_cmd_exec_start_backup
		unset _yazpt_cmd_exec_start_backup _yazpt_preview_in_meta_dir
	}
}

.yazpt_preview # FIXME for testing
