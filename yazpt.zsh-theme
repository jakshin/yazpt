# Yet another zsh prompt theme, with Git/Subversion/TFVC awareness
# https://github.com/jakshin/yazpt
#
# Copyright (c) 2020 Jason Jackson <jasonjackson@pobox.com>
# Based initially on https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
#
# This program is free software; you can redistribute it and/or modify it under the terms
# of the GNU General Public License version 2 as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# A copy of the GNU General Public License should accompany this program; if not,
# see http://www.gnu.org/licenses/gpl-2.0.html or write to the Free Software Foundation,
# 59 Temple Place, Suite 330, Boston, MA 02111.

# Try to ensure we're running in a compatible environment.
if [[ -z $ZSH_VERSION ]]; then
	echo "Sorry, the yazpt prompt theme only works on zsh."
	return 1
fi

{
	yazpt_zsh_ver=(${(s:.:)ZSH_VERSION})
	if (( $yazpt_zsh_ver[1] < 5 || ($yazpt_zsh_ver[1] == 5 && $yazpt_zsh_ver[2] < 1) )); then
		echo "Sorry, the yazpt prompt theme only works on zsh version 5.1 or later."
		return 1
	fi
} always {
	unset yazpt_zsh_ver
}

# Set up our defaults. Any other preset file can be sourced to customize the configuration,
# or loaded with yazpt_load_preset (run yazpt_list_presets to see the list of presets),
# or of course the YAZPT_* environment variables can be tweaked individually.
# The YAZPT_* environment variables are listed and described in presets/default-preset.zsh.
#
[[ -n $yazpt_base_dir ]] || declare -rg yazpt_base_dir=${${(%):-%x}:A:h}
[[ -n $yazpt_default_preset_file ]] || declare -rg yazpt_default_preset_file="$yazpt_base_dir/presets/default-preset.zsh"
source "$yazpt_default_preset_file"
setopt prompt_percent

# Explains yazpt's Git status characters and their meanings.
#
function yazpt_explain_git() {
	emulate -L zsh
	local src="$yazpt_base_dir/functions/explain-git.zsh"

	if [[ -r $src ]]; then
		source $src
		yazpt_explain_git "$@"
	else
		echo "Error: Can't find explain-git.zsh"
		return 1
	fi
}

# Explains yazpt's Subversion status characters and their meanings.
#
function yazpt_explain_svn() {
	emulate -L zsh
	local src="$yazpt_base_dir/functions/explain-svn.zsh"

	if [[ -r $src ]]; then
		source $src
		yazpt_explain_svn "$@"
	else
		echo "Error: Can't find explain-svn.zsh"
		return 1
	fi
}

# Explains yazpt's Team Foundation Version Control status characters and their meanings.
#
function yazpt_explain_tfvc() {
	emulate -L zsh
	local src="$yazpt_base_dir/functions/explain-tfvc.zsh"

	if [[ -r $src ]]; then
		source $src
		yazpt_explain_tfvc "$@"
	else
		echo "Error: Can't find explain-tfvc.zsh"
		return 1
	fi
}

# Lists all yazpt presets which can be loaded by yazpt_load_preset.
#
function yazpt_list_presets() {
	emulate -L zsh

	if [[ $1 != '' ]]; then
		echo "Lists all available presets; load one using the yazpt_load_preset function."
		echo "You can also load an arbitrary preset by passing an absolute/relative path."
		echo "Usage: $0"
		return
	fi

	local i presets=(${(f)"$(command ls -1 "$yazpt_base_dir"/presets/*-preset.zsh 2> /dev/null)"})
	for (( i=1; i <= ${#presets}; i++ )); do
		echo ${${presets[$i]:t}%%-preset.zsh}
	done
}

# Loads one of the yazpt presets (use yazpt_list_presets to get a list of them).
# If you have a ~/.yazptrc, it's sourced after loading the preset.
#
function yazpt_load_preset() {
	emulate -L zsh

	if [[ $1 == '' || $1 == '-h' || $1 == '--help' ]]; then
		echo "Loads an available preset; list them using the yazpt_list_presets function."
		echo "You can also load an arbitrary preset by passing a path containing a slash."
		echo "Usage: $0 <preset-name>"
		return
	fi

	local preset="$1" preset_file

	if [[ $preset == */* ]]; then
		preset_file="$preset"
	else
		preset_file="$yazpt_base_dir/presets/$preset-preset.zsh"
	fi

	if [[ -r $preset_file && ! -d $preset_file ]]; then
		local valid=true

		if which file > /dev/null; then
			[[ "$(file -L -- "$preset_file")" == *text* ]] || valid=false
		fi
	fi

	if [[ $valid == true ]]; then
		source "$preset_file"
		[[ -e ~/.yazptrc ]] && source ~/.yazptrc

		if [[ $YAZPT_PREVIEW != true && $prompt_theme[1] == "yazpt" ]]; then
			prompt_theme[2]=$preset  # So `prompt -h yazpt` will restore the right preset
		fi
	else
		echo "Error: Can't find or read preset '$preset'\n"
		echo "Run the yazpt_list_presets function for a list,"
		echo "or pass a path to a preset file, containing a slash."
		return 1
	fi
}

# Performs tab completion for the yazpt_load_preset function.
# Completes path/file names if it looks like you're entering one,
# or otherwise preset names based on the files in the presets directory.
#
function _yazpt_load_preset() {
	emulate -L zsh
	setopt local_options extended_glob

	local last_word=$words[$#words]
	if [[ $last_word == */* || $last_word == "~"/ ]]; then
		_files
	else
		local presets=(${(f)"$(yazpt_list_presets)"})
		compadd -a presets
	fi
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
	unfunction -m 'yazpt_*' '.yazpt_*' '@yazpt_*'
	typeset +r -m 'yazpt_*'
	unset -m 'YAZPT_*' 'yazpt_*' '_yazpt_*'

	# This isn't ideal, but if we don't reset PS1 to something generic,
	# we can leave the last PS1 calculated by yazpt in place indefinitely,
	# including zombie current working directory & Git/Subversion/TFVC info :-/
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
	declare -Ag yazpt_state=(exit_code $exit_code)  # State shared across segment functions

	PS1=""
	: ${YAZPT_LAYOUT:=<cwd> %# }
	local layout=$YAZPT_LAYOUT
	[[ $YAZPT_PREVIEW == true && $layout[1] == $'\n' ]] && layout=$layout[2,-1]
	local i len=${#layout}

	for (( i=1; i <= len; i++ )); do
		local ch=$layout[$i]

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
				elif functions "@yazpt_segment_$segment" > /dev/null; then
					"@yazpt_segment_$segment"  # Execute the segment's function

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

# Checks whether the current directory is allowed by the given whitelist,
# which is an array of path prefixes (pass the name of the array, without a '$').
# An empty whitelist allows any value.
#
function .yazpt_check_whitelist() {
	local whitelist_name=$1
	local whitelist=(${(P)${whitelist_name}})

	if [[ -n $whitelist ]]; then
		local i
		for (( i=1; i <= $#whitelist; i++ )); do
			local prefix=$whitelist[$i]
			[[ $PWD == "$prefix"* ]] && return 0
		done

		return 1  # No configured path prefix matches the current directory
	fi
}

# Reads the first line of the given path into the given variable.
#
function .yazpt_read_line() {
	local from_path="$1"
	local into_var="$2"
	[[ -r "$from_path" ]] && IFS=$'\r\n' read "$into_var" < "$from_path"
}

# Implements the "char" prompt segment,
# which shows either a '#' (root/Administrator) or '%' (for all other users).
#
function @yazpt_segment_char() {
	if [[ $OS == "Windows"* ]]; then
		if [[ -z $_yazpt_char ]]; then
			if net session &> /dev/null; then
				_yazpt_char='#'  # Running as Administrator
			else
				_yazpt_char='%#'
			fi
		fi

		yazpt_state[char]=$_yazpt_char
	else
		yazpt_state[char]='%#'
	fi
}

# Implements the "cwd" prompt segment.
#
function @yazpt_segment_cwd() {
	local cwd="" pwd_length
	if [[ -n $ZPREZTODIR ]] && \
			zstyle -g pwd_length ':prezto:module:prompt' 'pwd-length' && \
			[[ -n $pwd_length ]] && \
			functions "prompt-pwd" &> /dev/null; then
		cwd="$(prompt-pwd)"

		# Escape things as needed
		[[ -o prompt_bang ]] && cwd=${cwd//'!'/'!!'}
		[[ -o prompt_percent ]] && cwd="${cwd//\%/%%}"

		if [[ -o prompt_subst ]]; then
			_yazpt_cwd="$cwd"
			cwd='$_yazpt_cwd'
		fi
	fi

	[[ -n $cwd ]] || cwd='%~'
	yazpt_state[cwd]="%{%F{${YAZPT_CWD_COLOR:=default}}%}${cwd}%{%f%}"
}

# Implements the "exit" prompt segment (reflecting the exit code of the last command).
#
function @yazpt_segment_exit() {
	local exit_code=$yazpt_state[exit_code]

	if [[ $YAZPT_IGNORE_NEXT_EXIT_ERROR == true ]]; then
		unset YAZPT_IGNORE_NEXT_EXIT_ERROR
		exit_code=0
	fi

	if [[ $exit_code == 0 ]]; then
		if [[ -n $YAZPT_EXIT_OK_CHAR ]]; then
			yazpt_state[exit]+="%{%F{${YAZPT_EXIT_OK_COLOR:=default}}%}$YAZPT_EXIT_OK_CHAR%{%f%}"
		fi

		if [[ ${YAZPT_EXIT_OK_CODE_VISIBLE:l} == true ]]; then
			if [[ -z $ZPREZTODIR ]] || zstyle -T ':prezto:module:prompt' show-return-val; then
				yazpt_state[exit]+="%{%F{${YAZPT_EXIT_OK_COLOR:=default}}%}$exit_code%{%f%}"
			fi
		fi
	else
		if [[ -n $YAZPT_EXIT_ERROR_CHAR ]]; then
			yazpt_state[exit]+="%{%F{${YAZPT_EXIT_ERROR_COLOR:=default}}%}$YAZPT_EXIT_ERROR_CHAR%{%f%}"
		fi

		if [[ ${YAZPT_EXIT_ERROR_CODE_VISIBLE:l} == true ]]; then
			if [[ -z $ZPREZTODIR ]] || zstyle -T ':prezto:module:prompt' show-return-val; then
				yazpt_state[exit]+="%{%F{${YAZPT_EXIT_ERROR_COLOR:=default}}%}$exit_code%{%f%}"
			fi
		fi
	fi
}

# Implements the "git" prompt segment, which shows the Git branch/tag/SHA, any 'activity' in progress,
# such as rebasing or merging, and 1-2 characters indicating the current status of the working tree.
#
function @yazpt_segment_git() {
	# Check the whitelist
	if [[ ${(t)YAZPT_VCS_GIT_WHITELIST} == array ]] && ! .yazpt_check_whitelist YAZPT_VCS_GIT_WHITELIST; then
		return
	fi

	# Ignore $GIT_DIR in this function, including subshells launched from it
	local GIT_DIR; unset GIT_DIR

	# Calculate Git context first (branch/tag/SHA, and any in-flight activity, such as rebasing)
	local info git_exit_code
	info=(${(f)"$(git rev-parse --is-bare-repository --git-dir --is-inside-git-dir --short HEAD 2> /dev/null)"})
	git_exit_code=$?

	if [[ $info == "" ]]; then
		yazpt_state[git_error]=$git_exit_code  # Either the working directory isn't in a Git repo, or we can't run git
		return
	fi

	local bare_repo="$info[1]"     # Boolean
	local git_dir="$info[2]"       # Relative or absolute path, "." if in a bare repo
	local in_git_dir="$info[3]"    # Boolean, true if in a bare repo
	local sha="$info[4]"           # Empty if new repo with no commits (but we'll have $git_dir/HEAD to read)
	local context="" activity="" step="" steps=""

	if [[ $bare_repo == true ]]; then
		activity="BARE-REPO"
	elif [[ -d "$git_dir/rebase-merge" ]]; then
		activity="|REBASING"
		.yazpt_read_line "$git_dir/rebase-merge/head-name" context
		.yazpt_read_line "$git_dir/rebase-merge/msgnum" step
		.yazpt_read_line "$git_dir/rebase-merge/end" steps
	elif [[ -d "$git_dir/rebase-apply" ]]; then
		activity="|REBASING"
		.yazpt_read_line "$git_dir/rebase-apply/next" step
		.yazpt_read_line "$git_dir/rebase-apply/last" steps

		if [[ -f "$git_dir/rebase-apply/rebasing" ]]; then
			.yazpt_read_line "$git_dir/rebase-apply/head-name" context
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
		if .yazpt_read_line "$git_dir/sequencer/todo" todo; then
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

	if [[ -z $context && $bare_repo == false ]]; then
		local head
		.yazpt_read_line "$git_dir/HEAD" head

		if [[ $head == ref:* ]]; then
			context="${head#ref: }"
		else
			context="$(git describe --tags --exact-match HEAD 2> /dev/null || echo $sha)"
		fi
	fi

	local color
	if [[ $in_git_dir == true ]]; then
		color="${YAZPT_VCS_CONTEXT_META_COLOR:=default}"
		: ${activity:=|IN-GIT-DIR}
	elif git check-ignore -q .; then
		color="${YAZPT_VCS_CONTEXT_IGNORED_COLOR:=default}"
		: ${activity:=|IGNORED}
	else
		color="${YAZPT_VCS_CONTEXT_COLOR:=default}"
	fi

	if [[ -o prompt_bang ]]; then
		# Escape exclamation marks from prompt expansion, by doubling them
		context=${context//'!'/'!!'}
	fi

	context="${context//\%/%%}"  # Escape percent signs from prompt expansion
	context="%{%F{$color}%}${context#refs/heads/}${activity}%{%f%}"

	if [[ -o prompt_subst ]]; then
		_yazpt_context="$context"
		context='$_yazpt_context'
	else
		unset _yazpt_context
	fi

	# Calculate Git status
	local info=() statuses=()

	if [[ $bare_repo == false ]]; then
		if [[ $in_git_dir == true ]]; then
			# If the repo has linked worktrees, and we're in/under the subdirectory of .git for one,
			# show the linked worktree's status, else show the main worktree's status
			info=(${(f)"$(
				git_dir=${git_dir:a}
				[[ ${git_dir:h:t} != "worktrees" ]] || .yazpt_read_line "$git_dir/gitdir" git_dir
				cd ${git_dir:h}
				git status --branch --porcelain --ignore-submodules 2> /dev/null
				)"})
			git_exit_code=$?
		else
			info=(${(f)"$(git status --branch --porcelain --ignore-submodules 2> /dev/null)"})
			git_exit_code=$?
		fi

		if [[ $git_exit_code != 0 || -z $info ]]; then
			statuses+="UNKNOWN"
		else
			if (( ${#info} > 1 )); then
				statuses+="DIRTY"
			fi

			if [[ ! $info[1] =~ "no branch" ]]; then
				if [[ $info[1] =~ "\[" ]]; then
					# Neither branch names nor Git's brief status text will contain `[`, so its presence indicates
					# that Git has put "[ahead N]" or "[behind N]" or "[ahead N, behind N]" on the line
					statuses+="DIVERGED"
				elif [[ ! $info[1] =~ "\.\.\." ]]; then
					# Branch names can't contain "...", so its presence indicates there's a remote/upstream branch

					# Through at least version 2.25.0, `git status` doesn't seem to know whether a branch
					# in a bare repo's linked worktree has an upstream, so we always end up in this code path;
					# often, showing a no-upstream status is a lie, and we should show diverged or clean instead
					(( $+_yazpt_worktrees )) || declare -Ag _yazpt_worktrees
					local abs_git_dir=${git_dir:a}  # Cache key

					if [[ -z $_yazpt_worktrees[$abs_git_dir] ]]; then
							if [[ -f "$abs_git_dir/gitdir" ]]; then
							local linked_to_bare_repo=$(cd $abs_git_dir; git rev-parse --is-bare-repository)
							_yazpt_worktrees[$abs_git_dir]=$linked_to_bare_repo
						else
							_yazpt_worktrees[$abs_git_dir]="n/a"  # Not a linked worktree
						fi
					fi

					if [[ $_yazpt_worktrees[$abs_git_dir] == true ]]; then
						statuses+="LINKED_BARE"
					else
						statuses+="NO_UPSTREAM"
					fi
				fi
			fi

			if [[ -z $statuses ]]; then
				statuses+="CLEAN"
			fi
		fi

		local i git_status=""
		for (( i=1; i <= $#statuses; i++ )); do
			local char_var="YAZPT_VCS_STATUS_${statuses[$i]}_CHAR"
			local color_var="${char_var%_CHAR}_COLOR"
			[[ -z ${(P)${char_var}} ]] || git_status+="%{%F{${(P)${color_var}:=default}}%}${(P)${char_var}}%{%f%}"
		done
	fi

	# Combine Git context and status
	local combined="$context"
	if [[ -n $git_status ]]; then
		combined+=" $git_status"
	fi

	if (( ${#YAZPT_VCS_WRAPPER_CHARS} >= 2 )); then
		local before="%{%F{$color}%}$YAZPT_VCS_WRAPPER_CHARS[1]%{%f%}"
		local after="%{%F{$color}%}$YAZPT_VCS_WRAPPER_CHARS[2]%{%f%}"
		combined="${before}${combined}${after}"
	fi

	yazpt_state[git]="$combined"
}

# Stub/loader for the real @yazpt_segment_svn function in segment-svn.zsh,
# which implements the "svn" prompt segment.
#
function @yazpt_segment_svn() {
	# Check the whitelist
	if [[ ${(t)YAZPT_VCS_SVN_WHITELIST} == array ]] && ! .yazpt_check_whitelist YAZPT_VCS_SVN_WHITELIST; then
		return
	fi

	# Source and execute the real version of this function
	local src="$yazpt_base_dir/functions/segment-svn.zsh"

	if [[ -r $src ]]; then
		source $src
		@yazpt_segment_svn
	fi
}

# Stub/loader for the real @yazpt_segment_tfvc function in segment-tfvc.zsh,
# which implements the "tfvc" prompt segment.
#
# Note that the segment works only in local TFVC workspaces, not server workspaces.
#
function @yazpt_segment_tfvc() {
	# Check the whitelist
	if [[ ${(t)YAZPT_VCS_TFVC_WHITELIST} == array ]] && ! .yazpt_check_whitelist YAZPT_VCS_TFVC_WHITELIST; then
		return
	fi

	# Source and execute the real version of this function
	local src="$yazpt_base_dir/functions/segment-tfvc.zsh"

	if [[ -r $src ]]; then
		source $src
		@yazpt_segment_tfvc
	fi
}

# Implements the "vcs" prompt segment, which shows one or none of the "git", "svn" or "tfvc" prompt segments,
# as dictated by $YAZPT_VCS_ORDER and VCS-specific whitelists.
#
function @yazpt_segment_vcs() {
	local i
	for (( i=1; i <= $#YAZPT_VCS_ORDER; i++ )); do
		local vcs=$YAZPT_VCS_ORDER[$i]

		if functions @yazpt_segment_$vcs > /dev/null; then
			@yazpt_segment_$vcs
			yazpt_state[vcs]=$yazpt_state[$vcs]
			[[ -n $yazpt_state[vcs] ]] && return
		fi
	done
}

# Begin using the yazpt prompt theme as soon as this file is sourced.
autoload -Uz add-zsh-hook
add-zsh-hook precmd yazpt_precmd
