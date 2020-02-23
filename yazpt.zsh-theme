# Yet another zsh prompt theme with git awareness
# https://github.com/jakshin/yazpt
#
# Copyright (c) 2020 Jason Jackson <jasonjackson@pobox.com>
# Based on https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
# Distributed under the GNU General Public License, version 2.0

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

	for func in ${(k)functions}; do
		if [[ $func == yazpt* ]]; then
			unfunction $func
		fi
	done
}

# Sets $PS1, just before the shell uses it.
#
function yazpt_precmd() {
	local exit_code=$?
	PS1=""

	yazpt_segment_git_branch
	if [[ -n $PS1 ]]; then
		PS1+=" "
		yazpt_segment_git_status
		PS1+=" "
	fi

	yazpt_segment_cwd
	yazpt_segment_result $exit_code
	PS1=$'\n['"$PS1"$']\n%# '
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
	PS1+="%{%F{$YAZPT_CWD_COLOR}%}%~%{%f%}"
}

# Implements the "git_branch" prompt segment, which also shows any in-progress activity, e.g. rebasing.
# The branch's color can vary based on whether the CWD is the .git directory or an ignored directory.
#
function yazpt_segment_git_branch() {
	local info=(${(f)"$(git rev-parse --git-dir --is-inside-git-dir --is-inside-work-tree --short HEAD 2> /dev/null)"})
	if [[ $info == "" ]]; then
		return
	fi

	local git_dir="$info[1]"       # Relative or absolute path
	local in_git_dir="$info[2]"    # Boolean
	local in_work_tree="$info[3]"  # Boolean
	local sha="$info[4]"           # Empty if new repo with no commits (but we'll have .git/HEAD to read)
	local branch="" activity="" step="" steps=""

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

	branch="%{%F{$color}%}${branch#refs/heads/}${activity}%{%f%}"

	if [[ -o prompt_subst ]]; then
		yazpt_git_branch__="$branch"
		PS1+='$yazpt_git_branch__'
	else
		unset yazpt_git_branch__
		PS1+="$branch"
	fi
}

# Implements the "git_status" prompt segment.
# Note that this currently assumes the CWD is in a git repo.
#
function yazpt_segment_git_status() {
	local info
	if ! info=(${(f)"$(git status --branch --porcelain --ignore-submodules 2> /dev/null)"}); then
		# We must be in/under the .git directory
		YAZPT_GIT_STATUS_UNKNOWN_CHAR="${YAZPT_GIT_STATUS_UNKNOWN_CHAR:-?}"
		YAZPT_GIT_STATUS_UNKNOWN_CHAR_COLOR=${YAZPT_GIT_STATUS_UNKNOWN_CHAR_COLOR:-default}
		PS1+="%{%F{$YAZPT_GIT_STATUS_UNKNOWN_CHAR_COLOR}%}$YAZPT_GIT_STATUS_UNKNOWN_CHAR%{%f%}"
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

	PS1+="$stat"
}

# Implements the "result" prompt segment (the exit code of the last command).
#
function yazpt_segment_result() {
	local exit_code=$1

	if [[ $exit_code == 0 ]]; then
		if [[ -n $YAZPT_RESULT_OK_CHAR || ${YAZPT_RESULT_OK_CODE_VISIBLE:l} == true ]]; then
			PS1+=" "
		fi

		if [[ -n $YAZPT_RESULT_OK_CHAR ]]; then
			YAZPT_RESULT_OK_CHAR_COLOR=${YAZPT_RESULT_OK_CHAR_COLOR:-default}
			PS1+="%{%F{$YAZPT_RESULT_OK_CHAR_COLOR}%}$YAZPT_RESULT_OK_CHAR%{%f%}"
		fi

		if [[ ${YAZPT_RESULT_OK_CODE_VISIBLE:l} == true ]]; then
			YAZPT_RESULT_OK_CODE_COLOR=${YAZPT_RESULT_OK_CODE_COLOR:-default}
			PS1+="%{%F{$YAZPT_RESULT_OK_CODE_COLOR}%}$exit_code%{%f%}"
		fi
	else
		if [[ -n $YAZPT_RESULT_ERROR_CHAR || ${YAZPT_RESULT_ERROR_CODE_VISIBLE:l} == true ]]; then
			PS1+=" "
		fi

		if [[ -n $YAZPT_RESULT_ERROR_CHAR ]]; then
			YAZPT_RESULT_ERROR_CHAR_COLOR=${YAZPT_RESULT_ERROR_CHAR_COLOR:-default}
			PS1+="%{%F{$YAZPT_RESULT_ERROR_CHAR_COLOR}%}$YAZPT_RESULT_ERROR_CHAR%{%f%}"
		fi

		if [[ ${YAZPT_RESULT_ERROR_CODE_VISIBLE:l} == true ]]; then
			YAZPT_RESULT_ERROR_CODE_COLOR=${YAZPT_RESULT_ERROR_CODE_COLOR:-default}
			PS1+="%{%F{$YAZPT_RESULT_ERROR_CODE_COLOR}%}$exit_code%{%f%}"
		fi
	fi
}

# Begin using the yazpt prompt theme as soon as this file is sourced.
autoload -U add-zsh-hook
add-zsh-hook precmd yazpt_precmd
