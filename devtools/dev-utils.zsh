# Utility declarations and functions, for use in devtool scripts.

# Colors.
local header='\e[38;5;151m'
local normal='\e[0m'

# Saves yazpt's current settings, so they can be be restored later,
# after being manipulated for testing, debugging, previewing, etc.
# Run `eval "$_yazpt_state_stash"` to restore any saved settings.
#
function .yazpt_stash_settings() {
	_yazpt_state_stash=$(typeset -m 'YAZPT_*' | tr '\n' ';')
}

# Mock's the git prompt segment's function, for previewing layouts.
#
function .yazpt_mock_git_segment() {
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
}
