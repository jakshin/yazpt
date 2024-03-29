# A preset favoring shades of blue, with colors are defined in 16-color mode
# so they match the ANSI color palette set up in your terminal emulator.

source "$yazpt_default_preset_file"

YAZPT_LAYOUT=$'<blank>[<exit><? ><cwd><? ><vcs>]\n<char> '
YAZPT_CWD_COLOR=4
YAZPT_EXECTIME_COLOR=12  # 123 is another good choice

YAZPT_EXIT_ERROR_CHAR="✘"
YAZPT_EXIT_ERROR_COLOR=15
YAZPT_EXIT_OK_CHAR="✔︎"
YAZPT_EXIT_OK_COLOR=8

YAZPT_VCS_CONTEXT_COLOR=12
YAZPT_VCS_CONTEXT_META_COLOR=8
YAZPT_VCS_CONTEXT_IGNORED_COLOR=8
YAZPT_VCS_CONTEXT_UNVERSIONED_COLOR=8

YAZPT_VCS_STATUS_CLEAN_CHAR=""
YAZPT_VCS_STATUS_CLEAN_COLOR=6
YAZPT_VCS_STATUS_CONFLICT_COLOR=15
YAZPT_VCS_STATUS_DIRTY_COLOR=15
YAZPT_VCS_STATUS_DIVERGED_COLOR=15
YAZPT_VCS_STATUS_LOCKED_COLOR=15
YAZPT_VCS_STATUS_NO_UPSTREAM_COLOR=8
YAZPT_VCS_STATUS_UNKNOWN_CHAR=""
YAZPT_VCS_STATUS_UNKNOWN_COLOR=15

# Tweaks and fixups for various environments
if [[ -z $YAZPT_NO_TWEAKS ]]; then
	.yazpt_load_tweaks
	if functions .yazpt_tweak_checkmark > /dev/null; then
		.yazpt_tweak_checkmark
	fi

	if [[ $OSTYPE == "haiku" ]]; then
		YAZPT_CWD_COLOR=110
		YAZPT_EXECTIME_COLOR=67
		YAZPT_EXIT_OK_COLOR=250
		YAZPT_VCS_CONTEXT_COLOR=81
		YAZPT_VCS_CONTEXT_META_COLOR=243
		YAZPT_VCS_CONTEXT_IGNORED_COLOR=243
		YAZPT_VCS_CONTEXT_UNVERSIONED_COLOR=243
		YAZPT_VCS_STATUS_NO_UPSTREAM_COLOR=245

	elif [[ $OS == "Windows"* || -n $WSL_DISTRO_NAME ]]; then
		.yazpt_detect_terminal

		if [[ $yazpt_terminal == "vscode" ]]; then
			# We can't currently detect VS Code when running on WSL, sadly,
			# but you can still invoke this function manually there
			.yazpt_tweak_for_vscode
		fi
	fi
fi
