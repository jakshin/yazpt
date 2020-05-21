# A preset favoring shades of blue, with colors are defined in 16-color mode
# so they match the ANSI color palette set up in your terminal emulator.

source "$yazpt_default_preset_file"

YAZPT_LAYOUT=$'\n[<exit><? ><cwd><? ><vcs>]\n<char> '
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
	if [[ $OS == "Windows"* || -n $WSL_DISTRO_NAME ]]; then
		functions .yazpt_tweak_checkmark > /dev/null || source "$yazpt_base_dir/functions/tweaks-for-windows.zsh"
		.yazpt_tweak_checkmark

	elif [[ $OSTYPE == "linux-gnu" ]]; then
		functions .yazpt_tweak_checkmark > /dev/null || source "$yazpt_base_dir/functions/tweaks-for-linux.zsh"
		.yazpt_tweak_checkmark
	fi
fi
