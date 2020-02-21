# Yet another zsh prompt theme with git awareness
# https://github.com/jakshin/yazpt
#
# Copyright (c) 2020 Jason Jackson <jasonjackson@pobox.com>
# Based on https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
# Distributed under the GNU General Public License, version 2.0

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
	PS1=""

	yazpt_segment_git_branch
	if [[ -n $PS1 ]]; then
		PS1+=" "
		yazpt_segment_git_status
		PS1+=" "
	fi

	yazpt_segment_cwd
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
	PS1+='%{%F{226}%}%~%{%f%}'  # 226 = yellow
}

# Implements the "git_branch" prompt segment, which also shows any in-progress activity, e.g. rebasing.
# The branch's color can vary based on whether the CWD is the .git directory or an ignored directory.
#
function yazpt_segment_git_branch() {
	local info=(${(f)"$(git rev-parse --git-dir --is-inside-git-dir --is-inside-work-tree --short HEAD 2> /dev/null)"})
	if [[ $info == "" ]]; then
		return
	fi

	local git_dir="$info[1]"
	local in_git_dir="$info[2]"
	local in_work_tree="$info[3]"
	local sha="$info[4]"  # Empty if new repo with no commits (but we'll have .git/HEAD to read)
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

	local dim="$in_git_dir"
	local color
	[[ $in_work_tree == true ]] && git check-ignore -q . && dim=true
	[[ $dim == true ]] && color=240 || color=255  # 240 = dark gray, 255 = bright white
	branch="%{%F{$color}%}${branch#refs/heads/}${activity}"

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
		PS1+="%{%F{45}?%f%}"  # We must be in/under the .git directory; 45 = blue
		return
	fi

	local stat=""
	if (( ${#info} > 1 )); then
		stat="%{%F{166}⚑%f%}"  # 166 = reddish orange
	fi

	if [[ ! $info[1] =~ "no branch" ]]; then
		if [[ $info[1] =~ "\[" ]]; then
			# Neither branch names nor git's brief status text will contain `[`, so its presence indicates
			# that git has put "[ahead N]" or "[behind N]" or "[ahead N, behind N]" on the line
			stat+="%{%F{208}◆%f%}"  # 208 = orange
		elif [[ ! $info[1] =~ "\.\.\." ]]; then
			# Branch names can't contain "...", so its presence indicates there's a remote/upstream branch
			stat+="%{%F{30}◆%f%}"   # 30 = dark cyan (leaning greenish)
		fi
	fi

	[[ -n $stat ]] || stat="%{%F{28}●%f%}"  # 28 = dark green
	PS1+="$stat"
}

# Implements the "result" prompt segment (the exit code of the last command).
#
function yazpt_segment_result() {
	PS1+='%{%F{121}%}$?%{%f%}'  # 121 = cyan (leaning bluish)
}

# Begin using the yazpt prompt as soon as this file is sourced.
autoload -U add-zsh-hook
add-zsh-hook precmd yazpt_precmd
