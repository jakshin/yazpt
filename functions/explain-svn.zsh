function yazpt_explain_svn() {
	emulate -L zsh

	if [[ $1 != '' ]]; then
		echo "Explains yazpt's Subversion status characters and their meanings"
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
	.yazpt_print_wrapped_header "Statuses which can appear in the prompt while the current directory is in a Subversion working copy:"

	.yazpt_detail_vcs_status "$YAZPT_VCS_STATUS_CLEAN_COLOR" "$YAZPT_VCS_STATUS_CLEAN_CHAR" '$YAZPT_VCS_STATUS_CLEAN_CHAR' \
		"The working copy is clean. No files or directories have been added, modified or deleted," \
		"and there are no new unversioned files/directories, and no properties have been changed. None of the statuses below applies."

	.yazpt_detail_vcs_status "$YAZPT_VCS_STATUS_LOCKED_COLOR" "$YAZPT_VCS_STATUS_LOCKED_CHAR" '$YAZPT_VCS_STATUS_LOCKED_CHAR' \
		"An item is locked for exclusive commit somewhere in the working copy."

	.yazpt_detail_vcs_status "$YAZPT_VCS_STATUS_DIRTY_COLOR" "$YAZPT_VCS_STATUS_DIRTY_CHAR" '$YAZPT_VCS_STATUS_DIRTY_CHAR' \
		"The working copy is dirty. Files or directories have been added, modified or deleted," \
		"and/or there are unversioned files/directories, and/or properties have been changed."

	.yazpt_detail_vcs_status "$YAZPT_VCS_STATUS_CONFLICT_COLOR" "$YAZPT_VCS_STATUS_CONFLICT_CHAR" '$YAZPT_VCS_STATUS_CONFLICT_CHAR' \
		"There is a conflict - file, tree, or property - somewhere in the working copy."

	.yazpt_detail_vcs_status "$YAZPT_VCS_STATUS_UNKNOWN_COLOR" "$YAZPT_VCS_STATUS_UNKNOWN_CHAR" \
		'$YAZPT_VCS_STATUS_UNKNOWN_CHAR' "The working copy's status can't be determined," \
		"because an unexpected and unhandled error occurred while running 'svn status'."

	local ss=()
	[[ -z $YAZPT_VCS_STATUS_LOCKED_CHAR ]] || \
		ss+="%{%F{${YAZPT_VCS_STATUS_LOCKED_COLOR:-default}}%}${YAZPT_VCS_STATUS_LOCKED_CHAR}%{%f%}"
	[[ -z $YAZPT_VCS_STATUS_DIRTY_CHAR ]] || \
		ss+="%{%F{${YAZPT_VCS_STATUS_DIRTY_COLOR:-default}}%}${YAZPT_VCS_STATUS_DIRTY_CHAR}%{%f%}"
	[[ -z $YAZPT_VCS_STATUS_CONFLICT_CHAR ]] || \
		ss+="%{%F{${YAZPT_VCS_STATUS_CONFLICT_COLOR:-default}}%}${YAZPT_VCS_STATUS_CONFLICT_CHAR}%{%f%}"

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

	if [[ $YAZPT_LAYOUT != *"<vcs>"* && $YAZPT_LAYOUT != *"<svn>"* ]]; then
		echo
		.yazpt_print_wrapped_warning "\$YAZPT_LAYOUT doesn't contain '<vcs>' or '<svn>', so Subversion status won't be shown in the prompt."
	fi

	unset _yazpt_wrap_cmd
}
