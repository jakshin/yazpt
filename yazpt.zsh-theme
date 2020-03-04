# Yet another zsh prompt theme with git awareness
# https://github.com/jakshin/yazpt
#
# Copyright (c) 2020 Jason Jackson <jasonjackson@pobox.com>
# Based on https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
# Distributed under the GNU General Public License, version 2.0

# Set up our defaults.
# Any other preset file can be sourced to customize the configuration,
# or loaded with yazpt_load_preset (run yazpt_list_presets to see the options),
# or of course the YAZPT_* environment variables can be tweaked individually.
yazpt_base_dir=${${(%):-%x}:A:h}
yazpt_default_preset_file="$yazpt_base_dir/presets/default-preset.zsh"
source "$yazpt_default_preset_file"

# Lists all yazpt presets which can be loaded by yazpt_load_preset.
#
function yazpt_list_presets() {
	emulate -L zsh

	if [[ $1 != '' ]]; then
		echo "Lists all available presets; load one using the yazpt_load_preset function"
		echo "Usage: $0"
		return
	fi

	local i presets=(${(f)"$(command ls -1 "$yazpt_base_dir"/presets/*-preset.zsh 2> /dev/null)"})
	for (( i=1; i <= ${#presets}; i++ )); do
		echo ${${presets[$i]:t}%%-preset.zsh}
	done
}

# Loads one of the yazpt presets (use yazpt_list_presets to get a list of them).
#
function yazpt_load_preset() {
	emulate -L zsh

	if [[ $1 == '' || $1 == '-h' || $1 == '--help' ]]; then
		echo "Loads an available preset; list them using the yazpt_list_presets function"
		echo "Usage: $0 <preset-name>"
		return
	fi

	local preset="$1"
	local preset_file="$yazpt_base_dir/presets/$preset-preset.zsh"

	if [[ -r $preset_file ]]; then
		source "$preset_file"
	else
		echo "Error: Can't find preset '$preset'"
		echo "Run the yazpt_list_presets function for a complete list"
		return 1
	fi
}

# Performs tab completion for the yazpt_load_preset function.
#
function _yazpt_load_preset() {
	emulate -L zsh
	local presets=(${(f)"$(yazpt_list_presets)"})
	compadd -a presets
}

autoload -Uz compinit &> /dev/null
compinit -u &> /dev/null
compdef _yazpt_load_preset yazpt_load_preset

# Unloads yazpt. Removes all of yazpt's functions from memory,
# so you'll need to source this file again to use yazpt again.
#
function yazpt_plugin_unload() {
	emulate -L zsh
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

	emulate -L zsh
	typeset -Ag yazpt_state=(exit_code $exit_code)  # State shared across segment functions

	PS1=""
	: ${YAZPT_LAYOUT:=<cwd> %# }
	local i len=${#YAZPT_LAYOUT}

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

					if [[ -n $yazpt_state[$segment] ]]; then
						# If we have a pending separator, append it before the new segment (without its question mark)
						[[ -z $separator ]] || PS1+="${separator[2,-1]}"

						last_was_segment=true
						PS1+="$yazpt_state[$segment]"
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
	: ${YAZPT_CWD_COLOR:=default}
	yazpt_state[cwd]="%{%F{$YAZPT_CWD_COLOR}%}%~%{%f%}"
}

# Implements the "git" prompt segment, which shows either git_branch and git_status,
# separated by a space and optionally surrounded by configured characters, or nothing.
# Also implements the "git_branch" segment (which also shows any in-progress activity)
# and "git_status" segment; each is a subset of the "git" segment, separated out
# so they can be displayed separately if desired.
#
function yazpt_segment_git() {
	# Calculate git_branch first
	local info git_result args=(--is-bare-repository --git-dir --is-inside-git-dir --is-inside-work-tree)
	info=(${(f)"$(git rev-parse $args --short HEAD 2> /dev/null)"})
	git_result=$?

	if [[ $info == "" ]]; then
		yazpt_state[git_error]=$git_result  # Either the CWD isn't in a git repo, or we can't run git
		return
	fi

	local bare_repo="$info[1]"     # Boolean
	local git_dir="$info[2]"       # Relative or absolute path, "." if in a bare repo
	local in_git_dir="$info[3]"    # Boolean, true if in a bare repo
	local in_work_tree="$info[4]"  # Boolean
	local sha="$info[5]"           # Empty if new repo with no commits (but we'll have $git_dir/HEAD to read)
	local branch="" activity="" step="" steps=""

	if [[ $bare_repo == true ]]; then
		activity="BARE-REPO"
	elif [[ -d "$git_dir/rebase-merge" ]]; then
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

	if [[ -z $branch && $bare_repo == false ]]; then
		local head
		yazpt_read_line "$git_dir/HEAD" head

		if [[ $head == ref:* ]]; then
			branch="${head#ref: }"
		else
			branch="$(git describe --tags --exact-match HEAD 2> /dev/null || echo $sha)"
		fi
	fi

	local color
	if [[ $in_git_dir == true ]]; then
		: ${YAZPT_GIT_BRANCH_GIT_DIR_COLOR:=default}
		color="$YAZPT_GIT_BRANCH_GIT_DIR_COLOR"
	elif [[ $in_work_tree == true ]] && git check-ignore -q .; then
		: ${YAZPT_GIT_BRANCH_IGNORED_DIR_COLOR:=default}
		color="$YAZPT_GIT_BRANCH_IGNORED_DIR_COLOR"
	else
		: ${YAZPT_GIT_BRANCH_COLOR:=default}
		color="$YAZPT_GIT_BRANCH_COLOR"
	fi

	branch="${branch//\%/%%}"  # Escape percent signs from prompt expansion, by doubling them
	branch="%{%F{$color}%}${branch#refs/heads/}${activity}%{%f%}"

	if [[ -o prompt_subst ]]; then
		yazpt_git_branch="$branch"
		yazpt_state[git_branch]='$yazpt_git_branch'
	else
		unset yazpt_git_branch
		yazpt_state[git_branch]="$branch"
	fi

	# Calculate git_status 
	local info=() stat=""

	if [[ $bare_repo == false ]]; then
		if [[ $in_git_dir == true ]]; then
			# FIXME: tests aren't updated to match this change yet;
			# - does it work when multiple work trees use the same .git directory?
			info=(${(f)"$(cd ..; git status --branch --porcelain --ignore-submodules 2> /dev/null)"})
			git_result=$?
		else
			info=(${(f)"$(git status --branch --porcelain --ignore-submodules 2> /dev/null)"})
			git_result=$?
		fi

		if [[ $git_result != 0 || -z $info ]]; then
			if [[ -n $YAZPT_GIT_STATUS_UNKNOWN_CHAR ]]; then
				: ${YAZPT_GIT_STATUS_UNKNOWN_CHAR_COLOR:=default}
				stat="%{%F{$YAZPT_GIT_STATUS_UNKNOWN_CHAR_COLOR}%}$YAZPT_GIT_STATUS_UNKNOWN_CHAR%{%f%}"
			fi
		else
			if (( ${#info} > 1 && ${#YAZPT_GIT_STATUS_DIRTY_CHAR} > 0 )); then
				: ${YAZPT_GIT_STATUS_DIRTY_CHAR_COLOR:=default}
				stat="%{%F{$YAZPT_GIT_STATUS_DIRTY_CHAR_COLOR}%}$YAZPT_GIT_STATUS_DIRTY_CHAR%{%f%}"
			fi

			if [[ ! $info[1] =~ "no branch" ]]; then
				if [[ $info[1] =~ "\[" ]]; then
					# Neither branch names nor git's brief status text will contain `[`, so its presence indicates
					# that git has put "[ahead N]" or "[behind N]" or "[ahead N, behind N]" on the line
					if [[ -n $YAZPT_GIT_STATUS_DIVERGED_CHAR ]]; then
						: ${YAZPT_GIT_STATUS_DIVERGED_CHAR_COLOR:=default}
						stat+="%{%F{$YAZPT_GIT_STATUS_DIVERGED_CHAR_COLOR}%}$YAZPT_GIT_STATUS_DIVERGED_CHAR%{%f%}"
					fi
				elif [[ ! $info[1] =~ "\.\.\." ]]; then
					# Branch names can't contain "...", so its presence indicates there's a remote/upstream branch
					if [[ -n $YAZPT_GIT_STATUS_NO_REMOTE_CHAR ]]; then
						: ${YAZPT_GIT_STATUS_NO_REMOTE_CHAR_COLOR:=default}
						stat+="%{%F{$YAZPT_GIT_STATUS_NO_REMOTE_CHAR_COLOR}%}$YAZPT_GIT_STATUS_NO_REMOTE_CHAR%{%f%}"
					fi
				fi
			fi

			if [[ -z $stat && -n $YAZPT_GIT_STATUS_CLEAN_CHAR ]]; then
				: ${YAZPT_GIT_STATUS_CLEAN_CHAR_COLOR:=default}
				stat="%{%F{$YAZPT_GIT_STATUS_CLEAN_CHAR_COLOR}%}$YAZPT_GIT_STATUS_CLEAN_CHAR%{%f%}"
			fi
		fi

		yazpt_state[git_status]="$stat"
	fi

	# Combine git_branch and git_status
	local combined="$yazpt_state[git_branch]"
	if [[ -n $yazpt_state[git_status] ]]; then
		combined+=" $yazpt_state[git_status]"
	fi

	if (( ${#YAZPT_GIT_WRAPPER_CHARS} >= 2 )); then
		local before="%{%F{$color}%}$YAZPT_GIT_WRAPPER_CHARS[1]%{%f%}"
		local after="%{%F{$color}%}$YAZPT_GIT_WRAPPER_CHARS[2]%{%f%}"
		combined="${before}${combined}${after}"
	fi

	yazpt_state[git]="$combined"
}

# Implements the "git_branch" prompt segment, which also shows any in-progress git activity,
# e.g. rebasing, and which is actually part of the "git" segment.
#
function yazpt_segment_git_branch() {
	if [[ -z $yazpt_state[git] && -z $yazpt_state[git_error] ]]; then
		yazpt_segment_git
	fi
}

# Implements the "git_status" prompt segment,
# which is actually part of the "git" segment.
#
function yazpt_segment_git_status() {
	if [[ -z $yazpt_state[git] && -z $yazpt_state[git_error] ]]; then
		yazpt_segment_git
	fi
}

# Implements the "result" prompt segment (the exit code of the last command).
#
function yazpt_segment_result() {
	local exit_code=$yazpt_state[exit_code]

	if [[ $exit_code == 0 ]]; then
		if [[ -n $YAZPT_RESULT_OK_CHAR ]]; then
			: ${YAZPT_RESULT_OK_CHAR_COLOR:=default}
			yazpt_state[result]+="%{%F{$YAZPT_RESULT_OK_CHAR_COLOR}%}$YAZPT_RESULT_OK_CHAR%{%f%}"
		fi

		if [[ ${YAZPT_RESULT_OK_CODE_VISIBLE:l} == true ]]; then
			: ${YAZPT_RESULT_OK_CODE_COLOR:=default}
			yazpt_state[result]+="%{%F{$YAZPT_RESULT_OK_CODE_COLOR}%}$exit_code%{%f%}"
		fi
	else
		if [[ -n $YAZPT_RESULT_ERROR_CHAR ]]; then
			: ${YAZPT_RESULT_ERROR_CHAR_COLOR:=default}
			yazpt_state[result]+="%{%F{$YAZPT_RESULT_ERROR_CHAR_COLOR}%}$YAZPT_RESULT_ERROR_CHAR%{%f%}"
		fi

		if [[ ${YAZPT_RESULT_ERROR_CODE_VISIBLE:l} == true ]]; then
			: ${YAZPT_RESULT_ERROR_CODE_COLOR:=default}
			yazpt_state[result]+="%{%F{$YAZPT_RESULT_ERROR_CODE_COLOR}%}$exit_code%{%f%}"
		fi
	fi
}

# Begin using the yazpt prompt theme as soon as this file is sourced.
autoload -U add-zsh-hook
add-zsh-hook precmd yazpt_precmd
