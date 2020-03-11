function yazpt_explain_git() {
	emulate -L zsh

	if [[ $1 != '' ]]; then
		echo "Explains yazpt's git status characters and their meanings"
		echo "Usage: $0"
		return
	fi

	if [[ -z $YAZPT_LAYOUT ]] || ! which yazpt_precmd &> /dev/null || ! which yazpt_segment_git_status &> /dev/null; then
		echo "Error: Yazpt must be loaded for $0 to run"
		return 1
	fi

	{
		local width=$(( $COLUMNS - 8 ))
		(( $width >= 50 )) || width=50
		(( $width <= 100 )) || width=100

		if which "fmt" &> /dev/null; then
			local wrap_cmd="fmt -w $width"
		elif which "fold" &> /dev/null; then
			local wrap_cmd="fold -sw $width"
		fi

		function yazpt_wrap() {
			if [[ -n $wrap_cmd ]]; then
				yazpt_wrapped=(${(f)"$(echo "$1" | ${=wrap_cmd})"})
			else
				yazpt_wrapped=("$1")
			fi
		}

		function yazpt_print_wrapped() {
			yazpt_wrap $1  # Sets $yazpt_wrapped
			local tab_indent=$2

			local i
			for (( i=1; i <= $#yazpt_wrapped; i++ )); do
				local line=$yazpt_wrapped[$i]
				[[ $i == 1 || $tab_indent != true ]] || echo -n "\t"
				echo $line
			done

			unset yazpt_wrapped
		}

		function yazpt_print_git_status() {
			local ch=$1 color=$2 var=$3 desc=$4
			[[ -z $5 ]] || desc+=" $5"

			if [[ -n $ch ]]; then
				print -Pn "\n   %{%F{${color:-default}}%}${ch}%{%f%}\t"
			else
				print -Pn "\n  %{%F{240}%}n/a%{%f%}\t"
			fi

			if [[ -z $ch ]]; then
				desc+=" $var is empty, so this status isn't shown."
			else
				desc+=" Unset $var to keep this status from showing."
			fi

			yazpt_print_wrapped $desc true
		}

		echo -n "\e[1m"
		yazpt_print_wrapped "Status characters which can be shown in the prompt while the working directory is in a git repo:"
		echo -n "\e[0m"

		yazpt_print_git_status "$YAZPT_GIT_STATUS_CLEAN_CHAR" "$YAZPT_GIT_STATUS_CLEAN_CHAR_COLOR" '$YAZPT_GIT_STATUS_CLEAN_CHAR' \
			"The repo is clean. No files have been modified or deleted, and there are no new untracked files." \
			"No changes are staged. The commits on this branch match its remote/upstream branch. None of the statuses below applies."

		yazpt_print_git_status "$YAZPT_GIT_STATUS_DIRTY_CHAR" "$YAZPT_GIT_STATUS_DIRTY_CHAR_COLOR" '$YAZPT_GIT_STATUS_DIRTY_CHAR' \
			"The repo's working tree is dirty. Files have been modified or deleted, and/or there are new untracked files," \
			"and/or changes have been staged."

		yazpt_print_git_status "$YAZPT_GIT_STATUS_DIVERGED_CHAR" "$YAZPT_GIT_STATUS_DIVERGED_CHAR_COLOR" \
			'$YAZPT_GIT_STATUS_DIVERGED_CHAR' "The commits on this branch don't match the commits on its remote/upstream branch."

		yazpt_print_git_status "$YAZPT_GIT_STATUS_NO_UPSTREAM_CHAR" "$YAZPT_GIT_STATUS_NO_UPSTREAM_CHAR_COLOR" \
			'$YAZPT_GIT_STATUS_NO_UPSTREAM_CHAR' "This branch doesn't have a remote/upstream branch."

		yazpt_print_git_status "$YAZPT_GIT_STATUS_LINKED_BARE_CHAR" "$YAZPT_GIT_STATUS_LINKED_BARE_CHAR_COLOR" \
			'$YAZPT_GIT_STATUS_LINKED_BARE_CHAR' "The current directory is in a bare repo's linked working tree," \
			"so git doesn't report its remote/upstream branch (up to at least v2.25.0)."

		yazpt_print_git_status "$YAZPT_GIT_STATUS_UNKNOWN_CHAR" "$YAZPT_GIT_STATUS_UNKNOWN_CHAR_COLOR" \
			'$YAZPT_GIT_STATUS_UNKNOWN_CHAR' "The repo's status can't be determined," \
			"because an unexpected and unhandled error occurred while running 'git status'."

		if [[ -n $YAZPT_GIT_STATUS_DIRTY_CHAR ]]; then
			local dirty="%{%F{${YAZPT_GIT_STATUS_DIRTY_CHAR_COLOR:-default}}%}$YAZPT_GIT_STATUS_DIRTY_CHAR%{%f%}"

			local ss=()
			[[ -z $YAZPT_GIT_STATUS_DIVERGED_CHAR ]] || \
				ss+="%{%F{${YAZPT_GIT_STATUS_DIVERGED_CHAR_COLOR:-default}}%}${YAZPT_GIT_STATUS_DIVERGED_CHAR}%{%f%}"
			[[ -z $YAZPT_GIT_STATUS_NO_UPSTREAM_CHAR ]] || \
				ss+="%{%F{${YAZPT_GIT_STATUS_NO_UPSTREAM_CHAR_COLOR:-default}}%}${YAZPT_GIT_STATUS_NO_UPSTREAM_CHAR}%{%f%}"
			[[ -z $YAZPT_GIT_STATUS_LINKED_BARE_CHAR ]] || \
				ss+="%{%F{${YAZPT_GIT_STATUS_LINKED_BARE_CHAR_COLOR:-default}}%}${YAZPT_GIT_STATUS_LINKED_BARE_CHAR}%{%f%}"

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

		if [[ $YAZPT_LAYOUT != *"<git>"* && $YAZPT_LAYOUT != *"<git_status>"* ]]; then
			echo "\e[1m"
			yazpt_print_wrapped "\$YAZPT_LAYOUT doesn't contain either <git> or <git_status>, so git status won't be shown in the prompt."
			echo -n "\e[0m"
		fi
	} always {
		unfunction yazpt_wrap yazpt_print_wrapped yazpt_print_git_status
		unset yazpt_wrapped
	}
}
