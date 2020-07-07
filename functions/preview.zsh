# FIXME header comment & copyright

source /Users/jason/Settings/zsh/themes/yazpt/yazpt.zsh-theme  # FIXME remove

# FIXME special consideration for spearmint's bright white input
# FIXME special consideration for yolo's random colors, monochrome emoji colors

function .yazpt_preview() {
	{
		emulate -L zsh
		setopt no_prompt_subst

		# Save current settings before we overwrite them
		# FIXME also save/restore $_yazpt_cmd_exec_start
		local state_stash=$(typeset -m 'YAZPT_*' | tr '\n' ';')

		# mock @yazpt_segment_git so it shows all statuses and "feature-branch"
		# then show again with an error and "feature-branch" in $YAZPT_VCS_CONTEXT_META_COLOR

		local preset presets=(${(f)"$(yazpt_list_presets)"})
		for preset in $presets; do
			[[ $preset == "dense" || $preset == "elementary" ]] && continue
			yazpt_load_preset $preset

			YAZPT_LAYOUT=${YAZPT_LAYOUT//$'\n'/}
			YAZPT_LAYOUT=${YAZPT_LAYOUT//<char>/}

			if [[ -n $YAZPT_RLAYOUT ]]; then
				YAZPT_LAYOUT+=$'\t'$YAZPT_RLAYOUT
				YAZPT_RLAYOUT=""
			fi

			echo "\n\t$preset:"

			_yazpt_cmd_exec_start=$(( SECONDS - 7242 ))
			yazpt_precmd
			PS1=${PS1//\%~/"~/Documents/Foo"}
			print -P "\t$PS1"

			(exit 123)
			yazpt_precmd
			PS1=${PS1//\%~/"~/Documents/Foo"}
			print -P "\t$PS1"

		done

	} always {
		# FIXME clean up
		# unfunction ...
		eval "$state_stash"  # Restore saved settings
	}
}

.yazpt_preview # FIXME for testing
