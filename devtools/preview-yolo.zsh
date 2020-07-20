#!/usr/bin/env zsh
# Previews yazpt's yolo preset, showing each possible randomized color set,
# to make it easier to see how they look in any given terminal theme.
# FIXME ability to run without color adjustments?

emulate -L zsh
setopt no_prompt_subst

script_dir="${${(%):-%x}:A:h}"
source "$script_dir/../yazpt.zsh-theme"
source "$script_dir/dev-utils.zsh"
.yazpt_mock_git_segment

big_space="${(l.8.. .)}"
small_space="${(l.4.. .)}"

yazpt_load_preset "yolo"
YAZPT_LAYOUT=${YAZPT_LAYOUT//$'\n'/}
YAZPT_LAYOUT=${YAZPT_LAYOUT//<char>/}

if [[ -n $YAZPT_RLAYOUT ]]; then
	YAZPT_LAYOUT+="${small_space}${YAZPT_RLAYOUT}"
	YAZPT_RLAYOUT=""
fi

color_ranges="$(grep "declare .* _yazpt_yolo_color_ranges" "$script_dir/../presets/yolo-preset.zsh")"
eval "$color_ranges"

for range in $_yazpt_yolo_color_ranges; do
	echo $range | IFS=- read -A range

	for (( color=range[1]; color <= range[2]; color++ )); do
		YAZPT_CWD_COLOR=$color
		YAZPT_VCS_CONTEXT_COLOR=$(( color + 6 ))
		YAZPT_EXECTIME_COLOR=$(( color + 12 ))

		_yazpt_preview_in_meta_dir=false
		_yazpt_cmd_exec_start=$(( SECONDS - 7242 ))
		[[ -z $newline ]] || false
		yazpt_precmd
		PS1=${PS1//\%~/"~/Documents"}
		print -Pn "${big_space}${PS1}${newline}"
		[[ -z $newline ]] && newline="\n" || newline=""
	done
done

# Preview emoticons (the same colors are used with monochrome emoji)
YAZPT_CWD_COLOR=7
YAZPT_EXECTIME_CHAR="$yazpt_hourglass"
YAZPT_EXECTIME_COLOR=7
YAZPT_EXIT_ERROR_CHAR=":("
YAZPT_EXIT_OK_CHAR=":)"
YAZPT_VCS_CONTEXT_COLOR=7

_yazpt_cmd_exec_start=$(( SECONDS - 7242 )) yazpt_precmd
PS1=${PS1//\%~/"~/Documents"}
print -Pn "${big_space}${PS1}"

false
_yazpt_cmd_exec_start=$(( SECONDS - 7242 )) yazpt_precmd
PS1=${PS1//\%~/"~/Documents"}
print -P " ${big_space}${PS1}"
