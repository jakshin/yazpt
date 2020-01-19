# Yet another zsh prompt theme with git awareness
#
# Copyright (c) 2020 Jason Jackson <jasonjackson@pobox.com>
# Based on https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
# Distributed under the GNU General Public License, version 2.0

function yazpt_precmd() {
	# Sets $PS1, just before the shell uses it.
	local git_display  # Branch/tag/hash, any "activity" in progress, and a clean/dirty state indicator
	local info=(${(f)"$(git rev-parse --git-dir --is-inside-git-dir --is-inside-work-tree --short HEAD 2> /dev/null)"})

	if [[ $info != "" ]]; then
		local git_dir="$info[1]"
		local in_git_dir="$info[2]"
		local in_work_tree="$info[3]"
		local sha="$info[4]"  # Empty if new repo with no commits (but we'll have .git/HEAD to read)
		local activity="" step="" steps=""

		if [[ -d "$git_dir/rebase-merge" ]]; then
			activity="|REBASING"
			yazpt_read_line "$git_dir/rebase-merge/head-name" git_display
			yazpt_read_line "$git_dir/rebase-merge/msgnum" step
			yazpt_read_line "$git_dir/rebase-merge/end" steps
		elif [[ -d "$git_dir/rebase-apply" ]]; then
			activity="|REBASING"
			yazpt_read_line "$git_dir/rebase-apply/next" step
			yazpt_read_line "$git_dir/rebase-apply/last" steps

			if [[ -f "$git_dir/rebase-apply/rebasing" ]]; then
				yazpt_read_line "$git_dir/rebase-apply/head-name" git_display
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

		if [[ -z $git_display ]]; then
			local head
			yazpt_read_line "$git_dir/HEAD" head
	
			if [[ $head == ref:* ]]; then
				git_display="${head#ref: }"
			else
				git_display="$(git describe --tags --exact-match HEAD 2> /dev/null || echo $sha)"
			fi
		fi

		local dim="$in_git_dir"
		local color
		[[ $in_work_tree == true ]] && git check-ignore -q . && dim=true
		[[ $dim == true ]] && color=240 || color=255  # 240 = dark gray, 255 = bright white
		git_display="%{%F{$color}%}${git_display#refs/heads/}${activity}"

		local stat
		if ! stat=(${(f)"$(git status --branch --porcelain --ignore-submodules 2> /dev/null)"}); then
			git_display+=" %{%F{45}?%f%} "   # We must be in/under the .git directory; 45 = blue
		elif (( ${#stat} > 1 )); then
			git_display+=" %{%F{160}⚑%f%} "  # 160 = red
		elif [[ $stat[1] =~ "\[" ]]; then
			# Neither branch names nor git's brief status text will contain `[`, so its presence indicates
			# that git has put "[ahead N]" or "[behind N]" or "[ahead N, behind N]" on the line
			git_display+=" %{%F{208}◆%f%} "  # 208 = orange
		else
			git_display+=" %{%F{28}●%f%} "   # 28 = dark green
		fi
	fi

	if [[ -o prompt_subst ]]; then
		__yazpt_git_display="$git_display"
		PS1=$'\n[$__yazpt_git_display%{%F{226}%}%~%{%f%}]\n%# '  # 226 = yellow
	else
		unset __yazpt_git_display
		PS1=$'\n['"$git_display"$'%{%F{226}%}%~%{%f%}]\n%# '  # 226 = yellow
	fi
}

function yazpt_read_line() {
	# Reads the first line of the given path into the given variable.
	local path="$1"
	local var="$2"
	[[ -r "$path" ]] && IFS=$'\r\n' read "$var" < "$path"
}

function yazpt_plugin_unload() {
	# Unloads yazpt.
	add-zsh-hook -d precmd yazpt_precmd

	for func in yazpt_precmd yazpt_read_line yazpt_plugin_unload; do
		if type -f $func > /dev/null; then
			unfunction $func
		fi
	done
}

autoload -U add-zsh-hook
add-zsh-hook precmd yazpt_precmd
