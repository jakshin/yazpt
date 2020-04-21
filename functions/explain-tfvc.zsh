# Explains yazpt's Team Foundation Version Control status characters and their meanings.
# Copyright (c) 2020 Jason Jackson <jasonjackson@pobox.com>. Distributed under GPL v2.0, see LICENSE for details.
#
function yazpt_explain_tfvc() {
	emulate -L zsh

	if [[ $1 != '' ]]; then
		echo "Explains yazpt's Team Foundation Version Control status characters and their meanings"
		echo "Usage: $0"
		return
	fi

	if [[ -z $YAZPT_LAYOUT ]] || ! which yazpt_precmd &> /dev/null; then
		echo "Error: Yazpt must be loaded for $0 to run"
		return 1
	fi

	if ! functions .yazpt_detail_vcs_status > /dev/null; then
		source "$yazpt_base_dir/functions/utils.zsh"
	fi

	.yazpt_make_wrap_cmd
	.yazpt_print_wrapped_header "Statuses which can appear in the prompt while the current directory is in a TFVC local workspace:"

	.yazpt_detail_vcs_status "$YAZPT_VCS_STATUS_CLEAN_COLOR" "$YAZPT_VCS_STATUS_CLEAN_CHAR" '$YAZPT_VCS_STATUS_CLEAN_CHAR' \
		"The workspace is clean. No files or directories have been added, modified or deleted," \
		"and no new un-added files or directories have been detected. None of the statuses below applies."

	[[ ${YAZPT_VCS_TFVC_CHECK_LOCKS:l} == true ]] && local check_locks="is" || local check_locks="ISN'T"
	.yazpt_detail_vcs_status "$YAZPT_VCS_STATUS_LOCKED_COLOR" "$YAZPT_VCS_STATUS_LOCKED_CHAR" '$YAZPT_VCS_STATUS_LOCKED_CHAR' \
		"An item is locked for exclusive commit somewhere in the workspace. Locked items are only tracked if" \
		"\$YAZPT_VCS_TFVC_CHECK_LOCKS is set to true (it currently $check_locks); see default-preset.zsh for details."

	.yazpt_detail_vcs_status "$YAZPT_VCS_STATUS_DIRTY_COLOR" "$YAZPT_VCS_STATUS_DIRTY_CHAR" '$YAZPT_VCS_STATUS_DIRTY_CHAR' \
		"The workspace is dirty, i.e. there are pending changes/ Files or directories have been added, modified or deleted," \
		"and/or new un-added files or directories have been detected."

	.yazpt_detail_vcs_status "$YAZPT_VCS_STATUS_UNKNOWN_COLOR" "$YAZPT_VCS_STATUS_UNKNOWN_CHAR" \
		'$YAZPT_VCS_STATUS_UNKNOWN_CHAR' "The workspace's status can't be determined," \
		"because an unexpected error occurred while checking or parsing pendingchanges.tf1."

	if [[ ${YAZPT_VCS_TFVC_CHECK_LOCKS:l} == true ]]; then
		local ss=()
		[[ -z $YAZPT_VCS_STATUS_LOCKED_CHAR ]] || \
			ss+="%{%F{${YAZPT_VCS_STATUS_LOCKED_COLOR:-default}}%}${YAZPT_VCS_STATUS_LOCKED_CHAR}%{%f%}"
		[[ -z $YAZPT_VCS_STATUS_DIRTY_CHAR ]] || \
			ss+="%{%F{${YAZPT_VCS_STATUS_DIRTY_COLOR:-default}}%}${YAZPT_VCS_STATUS_DIRTY_CHAR}%{%f%}"

		if (( $#ss > 1 )); then
			local i sstr=""

			for (( i=1; i <= $#ss; i++ )); do
				if [[ -n $sstr ]]; then
					if (( $i == $#ss )); then
						sstr+=" and "
					else
						sstr+=", "
					fi
				fi

				sstr+=$ss[$i]
			done

			print -P "\nNote that ${sstr} can appear together."
			print -P "Otherwise only one status character is shown at a time."
		fi
	fi

	if [[ $YAZPT_LAYOUT != *"<vcs>"* && $YAZPT_LAYOUT != *"<tfvc>"* ]]; then
		echo
		.yazpt_print_wrapped_warning "\$YAZPT_LAYOUT doesn't contain '<vcs>' or '<tfvc>', so TFVC status won't be shown in the prompt."
	fi

	unset _yazpt_wrap_cmd
}
