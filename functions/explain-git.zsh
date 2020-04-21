# Explains yazpt's Git status characters and their meanings.
# Copyright (c) 2020 Jason Jackson <jasonjackson@pobox.com>. Distributed under GPL v2.0, see LICENSE for details.
#
function yazpt_explain_git() {
	emulate -L zsh

	if [[ $1 != '' ]]; then
		echo "Explains yazpt's Git status characters and their meanings"
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
	.yazpt_print_wrapped_header "Statuses which can appear in the prompt while the working directory is in a Git repo:"

	.yazpt_detail_vcs_status "$YAZPT_VCS_STATUS_CLEAN_COLOR" "$YAZPT_VCS_STATUS_CLEAN_CHAR" '$YAZPT_VCS_STATUS_CLEAN_CHAR' \
		"The repo is clean. No files have been modified or deleted, and there are no new untracked files." \
		"No changes are staged. The commits on this branch match its remote/upstream branch. None of the statuses below applies."

	.yazpt_detail_vcs_status "$YAZPT_VCS_STATUS_DIRTY_COLOR" "$YAZPT_VCS_STATUS_DIRTY_CHAR" '$YAZPT_VCS_STATUS_DIRTY_CHAR' \
		"The repo's working tree is dirty. Files have been modified or deleted, and/or there are new untracked files," \
		"and/or changes have been staged."

	.yazpt_detail_vcs_status "$YAZPT_VCS_STATUS_DIVERGED_COLOR" "$YAZPT_VCS_STATUS_DIVERGED_CHAR" \
		'$YAZPT_VCS_STATUS_DIVERGED_CHAR' "The commits on this branch don't match the commits on its remote/upstream branch."

	.yazpt_detail_vcs_status "$YAZPT_VCS_STATUS_NO_UPSTREAM_COLOR" "$YAZPT_VCS_STATUS_NO_UPSTREAM_CHAR" \
		'$YAZPT_VCS_STATUS_NO_UPSTREAM_CHAR' "This branch doesn't have a remote/upstream branch."

	.yazpt_detail_vcs_status "$YAZPT_VCS_STATUS_LINKED_BARE_COLOR" "$YAZPT_VCS_STATUS_LINKED_BARE_CHAR" \
		'$YAZPT_VCS_STATUS_LINKED_BARE_CHAR' "The current directory is in a bare repo's linked working tree," \
		"so Git doesn't report its remote/upstream branch (up to at least v2.25.0)."

	.yazpt_detail_vcs_status "$YAZPT_VCS_STATUS_UNKNOWN_COLOR" "$YAZPT_VCS_STATUS_UNKNOWN_CHAR" \
		'$YAZPT_VCS_STATUS_UNKNOWN_CHAR' "The repo's status can't be determined," \
		"because an unexpected and unhandled error occurred while running 'git status'."

	if [[ -n $YAZPT_VCS_STATUS_DIRTY_CHAR ]]; then
		local dirty="%{%F{${YAZPT_VCS_STATUS_DIRTY_COLOR:-default}}%}$YAZPT_VCS_STATUS_DIRTY_CHAR%{%f%}"

		local ss=()
		[[ -z $YAZPT_VCS_STATUS_DIVERGED_CHAR ]] || \
			ss+="%{%F{${YAZPT_VCS_STATUS_DIVERGED_COLOR:-default}}%}${YAZPT_VCS_STATUS_DIVERGED_CHAR}%{%f%}"
		[[ -z $YAZPT_VCS_STATUS_NO_UPSTREAM_CHAR ]] || \
			ss+="%{%F{${YAZPT_VCS_STATUS_NO_UPSTREAM_COLOR:-default}}%}${YAZPT_VCS_STATUS_NO_UPSTREAM_CHAR}%{%f%}"
		[[ -z $YAZPT_VCS_STATUS_LINKED_BARE_CHAR ]] || \
			ss+="%{%F{${YAZPT_VCS_STATUS_LINKED_BARE_COLOR:-default}}%}${YAZPT_VCS_STATUS_LINKED_BARE_CHAR}%{%f%}"

		if [[ -n $ss ]]; then
			local i sstr=""

			for (( i=1; i <= $#ss; i++ )); do
				if [[ -n $sstr ]]; then
					if (( $i == $#ss )); then
						sstr+=" or "
					else
						sstr+=", "
					fi
				fi

				sstr+=$ss[$i]
			done

			print -P "\nNote that $dirty can combine with ${sstr}"
			print -P "Otherwise only one status character is shown at a time."
		fi
	fi

	if [[ $YAZPT_LAYOUT != *"<vcs>"* && $YAZPT_LAYOUT != *"<git>"* ]]; then
		echo
		.yazpt_print_wrapped_warning "\$YAZPT_LAYOUT doesn't contain '<vcs>' or '<git>', so Git status won't be shown in the prompt."
	fi

	unset _yazpt_wrap_cmd
}
