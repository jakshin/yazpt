# Yet another zsh prompt theme with git awareness
# https://github.com/jakshin/yazpt
#
# Copyright (c) 2020 Jason Jackson <jasonjackson@pobox.com>
# Based on https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
# Distributed under the GNU General Public License, version 2.0

# Layout: prompt segments, separators, etc.
YAZPT_LAYOUT=$'\n[<cwd><? ><result><? ><git_branch><? ><git_status>]\n%# '

# Settings for the "cwd" prompt segment, which shows the current working directory.
YAZPT_CWD_COLOR=226                       # Yellow

# Settings for the "git_branch" prompt segment.
YAZPT_GIT_BRANCH_COLOR=255                # Bright white
YAZPT_GIT_BRANCH_GIT_DIR_COLOR=240        # Dark gray; used when the CWD is in/under the .git directory
YAZPT_GIT_BRANCH_IGNORED_DIR_COLOR=240    # Dark gray; used when the CWD is in/under a directory ignored by git

# Settings for the "git_status" prompt segment.
YAZPT_GIT_STATUS_CLEAN_CHAR="●"           # Used when the repo is clean (no changes, nothing staged, no need to push/pull)
YAZPT_GIT_STATUS_CLEAN_CHAR_COLOR=28      # Dark green
YAZPT_GIT_STATUS_DIRTY_CHAR="⚑"           # Used when there are untracked files, unstaged or uncommitted changes
YAZPT_GIT_STATUS_DIRTY_CHAR_COLOR=166     # Reddish orange
YAZPT_GIT_STATUS_DIVERGED_CHAR="◆"        # Used when the local branch's commits don't match its remote/upstream branch's
YAZPT_GIT_STATUS_DIVERGED_CHAR_COLOR=208  # Orange
YAZPT_GIT_STATUS_NO_REMOTE_CHAR="◆"       # Used when the local branch has no remote/upstream branch
YAZPT_GIT_STATUS_NO_REMOTE_CHAR_COLOR=30  # Dark cyan (leaning greenish)
YAZPT_GIT_STATUS_UNKNOWN_CHAR="?"         # Used when the repo's status can't be determined
YAZPT_GIT_STATUS_UNKNOWN_CHAR_COLOR=45    # Bright blue

# Settings for the "result" prompt segment, which shows the previous command's exit code.
YAZPT_RESULT_ERROR_CHAR="✘"               # Set to empty string for no error indicator character
YAZPT_RESULT_ERROR_CHAR_COLOR=166         # Reddish orange
YAZPT_RESULT_ERROR_CODE_COLOR=166         # Reddish orange
YAZPT_RESULT_ERROR_CODE_VISIBLE=true      # Display the command's numeric exit code if it's non-zero?
YAZPT_RESULT_OK_CHAR=""                   # Set to empty string for no success indicator character
YAZPT_RESULT_OK_CHAR_COLOR=28             # Dark green
YAZPT_RESULT_OK_CODE_COLOR=28             # Dark green
YAZPT_RESULT_OK_CODE_VISIBLE=false        # Display the command's numeric exit code if it's zero?

# Unloads yazpt. Removes all of yazpt's functions from memory,
# so you'll need to source this file again to use yazpt again.
#
function yazpt_plugin_unload() {
	add-zsh-hook -d precmd yazpt_precmd
	unfunction -m 'yazpt_*'
	unset -m 'YAZPT_*' 'yazpt_*'
	PS1='%n@%m %1~ %# '
}

# Sets $PS1, just before the shell uses it.
#
function yazpt_precmd() {
	local exit_code=$?
	local escaped=false
	local last_was_segment=false  # Was the last character appended to PS1 from a segment?
	local parsing_segment=false   # Are we parsing a segment right now?
	local segment=""              # The segment we've parsed so far, if any
	local separator=""            # The pending segment separator, if any

	PS1=""
	typeset -Ag yazpt_state=(exit_code $exit_code)  # State shared across segment functions

	YAZPT_LAYOUT="${YAZPT_LAYOUT:-<cwd> %# }"
	local len=${#YAZPT_LAYOUT}

	for (( i=1; i <= len; i++ )); do
		local ch=$YAZPT_LAYOUT[$i]

		if [[ $parsing_segment == true ]]; then
			if [[ $escaped == true ]]; then
				# The previous character escaped this one
				segment+="$ch"
				escaped=false
			elif [[ $ch == '<' ]]; then
				if [[ -z $segment ]]; then
					# If the first character of a segment is another angle-bracket,
					# it was actually just an escaped angle-bracket, not a segment at all
					last_was_segment=false
					parsing_segment=false
					PS1+='<'
				else
					# An angle-bracket inside a segment/separator is an escape character;
					# drop the angle-bracket, and set a flag so we handle the next character literally
					escaped=true
				fi
			elif [[ $ch == '>' ]]; then
				# Ending the segment (which might be a separator, and/or might be empty)
				if [[ $segment[1] == '?' ]]; then
					if [[ $last_was_segment == true && -z $separator ]]; then
						separator="$segment"
					fi
				elif which "yazpt_segment_$segment" > /dev/null; then
					"yazpt_segment_$segment"  # Execute the segment's function

					if [[ -n $yazpt_state[output] ]]; then
						# If we have a pending separator, append it before the new segment (without its question mark)
						[[ -z $separator ]] || PS1+="${separator[2,-1]}"

						last_was_segment=true
						PS1+="$yazpt_state[output]"
						yazpt_state[output]=""
					fi

					separator=""  # Clear any pending separator (whether we appended it just above or not)
				else
					# We don't have a function for this segment;
					# just append it verbatim, i.e. treat it as not a segment after all
					last_was_segment=false
					separator=""
					PS1+="<$segment>"
				fi

				parsing_segment=false
				segment=""
			else
				# Keep collecting characters into the segment, until it's closed with an angle-bracket
				segment+="$ch"
			fi
		elif [[ $ch == '<' ]]; then
			parsing_segment=true  # Starting a segment; discard the opening angle-bracket
		else
			# Just a normal character, and we're not in a segment, so append it to the prompt
			last_was_segment=false
			separator=""
			PS1+="$ch"
		fi
	done

	if [[ -n $segment ]]; then
		# We were in a segment, but it never ended;
		# just append it verbatim, i.e. treat it as not a segment after all
		PS1+="<$segment"
	fi

	unset yazpt_state
}

# Reads the first line of the given path into the given variable.
#
function yazpt_read_line() {
	local path="$1"
	local var="$2"
	[[ -r "$path" ]] && IFS=$'\r\n' read "$var" < "$path"
}

# Implements the "cwd" prompt segment.
#
function yazpt_segment_cwd() {
	YAZPT_CWD_COLOR=${YAZPT_CWD_COLOR:-default}
	yazpt_state[output]="%{%F{$YAZPT_CWD_COLOR}%}%~%{%f%}"
}

# Implements the "git_branch" prompt segment, which also shows any in-progress activity, e.g. rebasing.
# The branch's color can vary based on whether the CWD is the .git directory or an ignored directory.
#
function yazpt_segment_git_branch() {
	local info=(${(f)"$(git rev-parse --git-dir --is-inside-git-dir --is-inside-work-tree --short HEAD 2> /dev/null)"})
	if [[ $info == "" ]]; then
		yazpt_state[git]=false  # Either the CWD isn't in a git repo, or we can't run git
		return
	fi

	local git_dir="$info[1]"       # Relative or absolute path
	local in_git_dir="$info[2]"    # Boolean
	local in_work_tree="$info[3]"  # Boolean
	local sha="$info[4]"           # Empty if new repo with no commits (but we'll have .git/HEAD to read)
	local branch="" activity="" step="" steps=""

	yazpt_state[in_git_dir]=$in_git_dir

	if [[ -d "$git_dir/rebase-merge" ]]; then
		activity="|REBASING"
		yazpt_read_line "$git_dir/rebase-merge/head-name" branch
		yazpt_read_line "$git_dir/rebase-merge/msgnum" step
		yazpt_read_line "$git_dir/rebase-merge/end" steps
	elif [[ -d "$git_dir/rebase-apply" ]]; then
		activity="|REBASING"
		yazpt_read_line "$git_dir/rebase-apply/next" step
		yazpt_read_line "$git_dir/rebase-apply/last" steps

		if [[ -f "$git_dir/rebase-apply/rebasing" ]]; then
			yazpt_read_line "$git_dir/rebase-apply/head-name" branch
		elif [[ -f "$git_dir/rebase-apply/applying" ]]; then
			activity="|AM"
		fi
	elif [[ -f "$git_dir/MERGE_HEAD" ]]; then
		activity="|MERGING"
	elif [[ -f "$git_dir/BISECT_LOG" ]]; then
		activity="|BISECTING"
	elif [[ -f "$git_dir/CHERRY_PICK_HEAD" ]]; then
		activity="|CHERRY-PICKING"
	elif [[ -f "$git_dir/REVERT_HEAD" ]]; then
		activity="|REVERTING"
	else
		local todo
		if yazpt_read_line "$git_dir/sequencer/todo" todo; then
			if [[ $todo == p* ]]; then
				activity="|CHERRY-PICKING"
			elif [[ $todo == r* ]]; then
				activity="|REVERTING"
			fi
		fi
	fi

	if [[ -n $step && -n $steps ]]; then
		activity+=" $step/$steps"
	fi

	if [[ -z $branch ]]; then
		local head
		yazpt_read_line "$git_dir/HEAD" head

		if [[ $head == ref:* ]]; then
			branch="${head#ref: }"
		else
			branch="$(git describe --tags --exact-match HEAD 2> /dev/null || echo $sha)"
		fi
	fi

	if [[ $in_git_dir == true ]]; then
		YAZPT_GIT_BRANCH_GIT_DIR_COLOR=${YAZPT_GIT_BRANCH_GIT_DIR_COLOR:-default}
		color="$YAZPT_GIT_BRANCH_GIT_DIR_COLOR"
	elif [[ $in_work_tree == true ]] && git check-ignore -q .; then
		YAZPT_GIT_BRANCH_IGNORED_DIR_COLOR=${YAZPT_GIT_BRANCH_IGNORED_DIR_COLOR:-default}
		color="$YAZPT_GIT_BRANCH_IGNORED_DIR_COLOR"
	else
		YAZPT_GIT_BRANCH_COLOR=${YAZPT_GIT_BRANCH_COLOR:-default}
		color="$YAZPT_GIT_BRANCH_COLOR"
	fi

	branch="${branch//\%/%%}"  # Escape percent signs from prompt expansion, by doubling them
	branch="%{%F{$color}%}${branch#refs/heads/}${activity}%{%f%}"

	if [[ -o prompt_subst ]]; then
		yazpt_git_branch="$branch"
		yazpt_state[output]='$yazpt_git_branch'
	else
		unset yazpt_git_branch
		yazpt_state[output]="$branch"
	fi
}

# Implements the "git_status" prompt segment.
#
function yazpt_segment_git_status() {
	if [[ $yazpt_state[git] == false ]]; then
		return # We already know we won't be able get git status here, so don't even try
	fi

	local info
	if [[ $yazpt_state[in_git_dir] == true ]] ||
			! info=(${(f)"$(git status --branch --porcelain --ignore-submodules 2> /dev/null)"}); then

		if [[ $yazpt_state[in_git_dir] == true || ${PWD:t} == ".git" ]]; then
			YAZPT_GIT_STATUS_UNKNOWN_CHAR="${YAZPT_GIT_STATUS_UNKNOWN_CHAR:-?}"
			YAZPT_GIT_STATUS_UNKNOWN_CHAR_COLOR=${YAZPT_GIT_STATUS_UNKNOWN_CHAR_COLOR:-default}
			yazpt_state[output]="%{%F{$YAZPT_GIT_STATUS_UNKNOWN_CHAR_COLOR}%}$YAZPT_GIT_STATUS_UNKNOWN_CHAR%{%f%}"
		fi

		return
	fi

	local stat=""
	if (( ${#info} > 1 )); then
		YAZPT_GIT_STATUS_DIRTY_CHAR="${YAZPT_GIT_STATUS_DIRTY_CHAR:-⚑}"
		YAZPT_GIT_STATUS_DIRTY_CHAR_COLOR=${YAZPT_GIT_STATUS_DIRTY_CHAR_COLOR:-default}
		stat="%{%F{$YAZPT_GIT_STATUS_DIRTY_CHAR_COLOR}%}$YAZPT_GIT_STATUS_DIRTY_CHAR%{%f%}"
	fi

	if [[ ! $info[1] =~ "no branch" ]]; then
		if [[ $info[1] =~ "\[" ]]; then
			# Neither branch names nor git's brief status text will contain `[`, so its presence indicates
			# that git has put "[ahead N]" or "[behind N]" or "[ahead N, behind N]" on the line
			YAZPT_GIT_STATUS_DIVERGED_CHAR="${YAZPT_GIT_STATUS_DIVERGED_CHAR:-◆}"
			YAZPT_GIT_STATUS_DIVERGED_CHAR_COLOR=${YAZPT_GIT_STATUS_DIVERGED_CHAR_COLOR:-default}
			stat+="%{%F{$YAZPT_GIT_STATUS_DIVERGED_CHAR_COLOR}%}$YAZPT_GIT_STATUS_DIVERGED_CHAR%{%f%}"
		elif [[ ! $info[1] =~ "\.\.\." ]]; then
			# Branch names can't contain "...", so its presence indicates there's a remote/upstream branch
			YAZPT_GIT_STATUS_NO_REMOTE_CHAR="${YAZPT_GIT_STATUS_NO_REMOTE_CHAR:-◆}"
			YAZPT_GIT_STATUS_NO_REMOTE_CHAR_COLOR=${YAZPT_GIT_STATUS_NO_REMOTE_CHAR_COLOR:-default}
			stat+="%{%F{$YAZPT_GIT_STATUS_NO_REMOTE_CHAR_COLOR}%}$YAZPT_GIT_STATUS_NO_REMOTE_CHAR%{%f%}"
		fi
	fi

	if [[ -z $stat ]]; then
		YAZPT_GIT_STATUS_CLEAN_CHAR="${YAZPT_GIT_STATUS_CLEAN_CHAR:-●}"
		YAZPT_GIT_STATUS_CLEAN_CHAR_COLOR=${YAZPT_GIT_STATUS_CLEAN_CHAR_COLOR:-default}
		stat="%{%F{$YAZPT_GIT_STATUS_CLEAN_CHAR_COLOR}%}$YAZPT_GIT_STATUS_CLEAN_CHAR%{%f%}"
	fi

	yazpt_state[output]="$stat"
}

# Implements the "result" prompt segment (the exit code of the last command).
#
function yazpt_segment_result() {
	local exit_code=$yazpt_state[exit_code]

	if [[ $exit_code == 0 ]]; then
		if [[ -n $YAZPT_RESULT_OK_CHAR ]]; then
			YAZPT_RESULT_OK_CHAR_COLOR=${YAZPT_RESULT_OK_CHAR_COLOR:-default}
			yazpt_state[output]+="%{%F{$YAZPT_RESULT_OK_CHAR_COLOR}%}$YAZPT_RESULT_OK_CHAR%{%f%}"
		fi

		if [[ ${YAZPT_RESULT_OK_CODE_VISIBLE:l} == true ]]; then
			YAZPT_RESULT_OK_CODE_COLOR=${YAZPT_RESULT_OK_CODE_COLOR:-default}
			yazpt_state[output]+="%{%F{$YAZPT_RESULT_OK_CODE_COLOR}%}$exit_code%{%f%}"
		fi
	else
		if [[ -n $YAZPT_RESULT_ERROR_CHAR ]]; then
			YAZPT_RESULT_ERROR_CHAR_COLOR=${YAZPT_RESULT_ERROR_CHAR_COLOR:-default}
			yazpt_state[output]+="%{%F{$YAZPT_RESULT_ERROR_CHAR_COLOR}%}$YAZPT_RESULT_ERROR_CHAR%{%f%}"
		fi

		if [[ ${YAZPT_RESULT_ERROR_CODE_VISIBLE:l} == true ]]; then
			YAZPT_RESULT_ERROR_CODE_COLOR=${YAZPT_RESULT_ERROR_CODE_COLOR:-default}
			yazpt_state[output]+="%{%F{$YAZPT_RESULT_ERROR_CODE_COLOR}%}$exit_code%{%f%}"
		fi
	fi
}

# Begin using the yazpt prompt theme as soon as this file is sourced.
autoload -U add-zsh-hook
add-zsh-hook precmd yazpt_precmd
