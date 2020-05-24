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

# Loads one of the yazpt presets (use yazpt_list_presets to get a list of them),
# or an arbitrary preset file if you pass a path containing a slash.
# If you have a ~/.yazptrc, it's sourced after loading the preset.
#
function yazpt_load_preset() {
	emulate -L zsh

	if [[ $1 == '' || $1 == '-h' || $1 == '--help' ]]; then
		echo "Loads an available preset; list them using the yazpt_list_presets function."
		echo "You can also load an arbitrary preset by passing a path containing a slash."
		echo "Usage: $0 <preset-name-or-path>"
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
		[[ ${YAZPT_READ_RC_FILE:l} != false && -e ~/.yazptrc ]] && source ~/.yazptrc

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

# Makes a new preset file containing the current settings which differ from the defaults.
#
# Pass a preset name to write a preset file alongside the presets shipped with yazpt,
# and which will show up in yazpt_list_presets' output and be auto-completed for yazpt_load_preset,
# or pass a path containing a slash and ending in a filename to write an abitrary file
# wherever you'd like (yazpt_load_preset will still load it, just not auto-complete it).
#
function yazpt_make_preset() {
	emulate -L zsh

	# Parse arguments
	declare -a opts=()
	zmodload -F zsh/zutil b:zparseopts
	zparseopts -D -E -a opts e f h -help

	if [[ $opts[(Ie)-h] != 0 || $opts[(Ie)--help] != 0 || $#@ != 1 || $@[1] == "-"* ]]; then
		echo "Makes a new preset file containing the current settings."
		echo "Only settings which differ from defaults are saved.\n"

		echo "Writes a preset file in $yazpt_base_dir/presets,"
		echo "or a file anywhere if you pass a path containing a slash and filename.\n"

		echo "Usage: $0 [options] <preset-name-or-path>\n"
		echo "Options:"
		echo "  -e  Exclude VCS settings which control behavior, not appearance,"
		echo '      i.e. $YAZPT_VCS_ORDER, $YAZPT*_WHITELIST, $YAZPT*_LOCKS'
		echo "  -f  Overwrite an existing preset file without asking"
		return
	fi

	local preset="$@[1]"	# A preset name, or path to the preset file to write

	# Stash the current settings
	local zle_stash=($zle_highlight)
	local stash=(${(f)"$(typeset -m 'YAZPT_*')"})
	stash=(${${(i)stash}#*:})	# Sort

	# Load the default preset's settings
	unset -m 'YAZPT_*'
	source $yazpt_default_preset_file

	local defaults i setting var val
	declare -A defaults_map=()

	defaults=(${(f)"$(typeset -m 'YAZPT_*')"})
	defaults=(${${(i)defaults}#*:})	# Sort

	for (( i=1; i <= $#defaults; i++ )); do
		setting=$defaults[$i]
		setting=(${(s:=:)setting})	# Split on "="

		var="$setting[1]"
		val="${(j:=:)setting[@]:1}"

		defaults_map[$var]="$val"
	done

	# Restore the stashed settings
	zle_highlight=($zle_stash)
	eval "${(j:; :)stash}"

	# Compare the stashed settings with the defaults, storing any which differ
	local default_val differences="" layouts="" unset=""
	declare -A stash_map=()

	for (( i=1; i <= $#stash; i++ )); do
		setting=$stash[$i]
		setting=(${(s:=:)setting})	# Split on "="

		var="$setting[1]"
		val="${(j:=:)setting[@]:1}"
		default_val="$defaults_map[$var]"
		stash_map[$var]="$val"	# For lookup while iterating $defaults_map below

		[[ $var == 'YAZPT_COMPILE' || $var == 'YAZPT_NO_TWEAKS' || $var == 'YAZPT_READ_RC_FILE' ]] && continue
		if (( $opts[(Ie)-e] )); then
			[[ $var == 'YAZPT_VCS_ORDER' || $var == *'_WHITELIST' || $var == *'_LOCKS' ]] && continue
		fi

		if [[ ${(t)val} != ${(t)default_val} || $val != $default_val ]]; then
			[[ $val == "$'"* ]] && val=${val//$'\n'/\n}

			if [[ $var == 'YAZPT_LAYOUT' ]]; then
				layouts="$var=$val"$'\n'"$layouts"
			elif [[ $var == 'YAZPT_RLAYOUT' ]]; then
				layouts="$layouts$var=$val"$'\n'
			else
				differences="$differences$var=$val"$'\n'
			fi
		fi
	done

	if [[ -n $layouts ]]; then
		differences="${layouts}${differences}"
		unset layouts
	fi

	local unset=""	# Settings in $defaults_map but not the stash
	for var in ${(k)defaults_map}; do
		if (( $opts[(Ie)-e] )); then
			[[ $var == 'YAZPT_VCS_ORDER' || $var == *'_WHITELIST' || $var == *'_LOCKS' ]] && continue
		fi

		(( $+stash_map[$var] )) || unset+="unset $var"$'\n'
	done

	# Return if there are no differences
	if [[ -z $differences && -z $unset ]]; then
		echo "You're using default settings, so there's nothing to save to the new preset file"
		return 1
	fi

	# Figure out the output file's path/name
	local preset_file preset_name

	if [[ $preset == */* ]]; then
		preset_file="$preset"
		preset_name=""
	else
		preset_file="$yazpt_base_dir/presets/$preset-preset.zsh"
		preset_name="\"$preset\" "
	fi

	# Prompt if the output file already exists
	if (( ! $opts[(Ie)-f] )) && [[ -f $preset_file ]]; then
		local desc="File"; [[ -L $preset_file ]] && desc="Symlink"
		echo -n "${desc} \"$preset_file\" exists.\nReplace it [y|n]? "
		read -rq
		echo

		[[ $REPLY == "y" ]] || return 0

		if [[ -L $preset_file ]]; then
			# If we just pipe to this symlink below, we'll actually overwrite its target,
			# which seems deceptive, so explicitly remove it before continuing
			rm -f "$preset_file" || return
		fi
	fi

	# Make the new preset file
	echo "# Custom ${preset_name}preset created $(date)" > $preset_file || return
	echo 'source "$yazpt_default_preset_file"\n' >> $preset_file
	[[ -z $differences ]] || echo -En "$differences" >> $preset_file
	[[ -z $differences || -z $unset ]] || echo >> $preset_file
	[[ -z $unset ]] || echo -En "$unset" >> $preset_file
}

# Performs tab completion for the yazpt_load_preset and yazpt_make_preset functions.
# Completes path/file names if it looks like you're entering one,
# or otherwise preset names based on the files in the presets directory.
#
function _yazpt_preset_completion() {
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
compdef _yazpt_preset_completion yazpt_load_preset yazpt_make_preset

# Unloads yazpt. Removes all of yazpt's functions from memory,
# so you'll need to source this file again to use yazpt again.
#
function yazpt_plugin_unload() {
	emulate -L zsh

	# Not ideal, but if we don't reset yazpt-populated prompt variables to generic values,
	# we can leave the last PS1 and/or RPS1 calculated by yazpt in place indefinitely,
	# including zombie current working directory & Git/Subversion/TFVC info :-/
	[[ -z $YAZPT_LAYOUT ]] || PS1='%n@%m %1~ %# '
	[[ -z $YAZPT_RLAYOUT ]] || RPS1=''

	# Reset any zle settings we changed
	(( $+_yazpt_default_zle_highlight )) && zle_highlight=($_yazpt_default_zle_highlight)

	# Remove our hooks, functions, and environment variables
	add-zsh-hook -d precmd yazpt_precmd
	add-zsh-hook -d preexec yazpt_preexec
	unfunction -m 'yazpt_*' '.yazpt_*' '@yazpt_*'
	typeset +r -m 'yazpt_*'
	unset -m 'YAZPT_*' 'yazpt_*' '_yazpt_*'
}

# Runs just before the prompt is displayed.
# Sets $PS1 and maybe $RPS1, just before the shell uses it/them.
#
function yazpt_precmd() {
	# We want to be able to turn prompt_subst off here without affecting other options,
	# so we can't emulate zsh - meaning this function should work in sh/ksh/csh modes

	local exit_code=$?
	declare -Ag yazpt_state=(exit_code $exit_code)  # State shared across segment functions
	declare -Ag _yazpt_subst=()  # Holds values when prompt_subst is on, until the next command

	: "${YAZPT_LAYOUT:=<cwd> <char> }"
	local layout="$YAZPT_LAYOUT"
	[[ $+YAZPT_PREVIEW == 1 && "$YAZPT_PREVIEW" == true && "$layout[1]" == $'\n' ]] && layout="$layout[2,-1]"

	if [[ -o prompt_subst && ! -e ~/.yazpt_allow_subst ]]; then
		setopt no_prompt_subst
	fi

	.yazpt_parse_layout "$layout" PS1
	if [[ -n "$YAZPT_RLAYOUT" ]]; then
		.yazpt_parse_layout "$YAZPT_RLAYOUT" RPS1
	else
		RPS1=""
	fi

	unset yazpt_state
}

# Runs when Enter is pressed at a prompt, i.e. just before the command executes.
# Sets a variable containing a timestamp, so we can later tell how long the command took to run.
#
function yazpt_preexec() {
	unset _yazpt_subst
	[[ $+YAZPT_PREVIEW == 1 && "$YAZPT_PREVIEW" == true ]] || _yazpt_cmd_exec_start=$SECONDS
}

# Checks the parts of yazpt's rendering that are prone to weirdness/wackiness.
# Tip: set YAZPT_NO_TWEAKS=true if you want to see what yazpt'd do without tweaks applied.
#
function .yazpt_check() {
	# Source and execute the real version of this function
	source "$yazpt_base_dir/functions/check.zsh" && .yazpt_check
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

# Compiles a yazpt file with zcompile, if needed.
#
function .yazpt_compile() {
	local file=$1
	if [[ -s $file && (! -s $file.zwc || $file -nt $file.zwc) ]]; then
		zcompile "$file"
	fi
}

# Tries to figure out whether the Noto Emoji font is installed or not, on GNU/Linux and BSD.
# This can give incorrect results if the font was installed/removed in this session, depending on a lot of factors.
#
function .yazpt_detect_noto_emoji_font() {
	if [[ -z $yazpt_noto_emoji_font ]]; then
		local loaded=false  # We'll keep this value if fc-list isn't installed or fails to run
		fc-list -q "Noto Emoji" &> /dev/null && loaded=true

		# Cache indefinitely. Not perfect, as it's hard to know for sure when a font change will show up in the terminal
		# (e.g. Debian 10's GNOME Terminal re-renders with a font change immediately when the Files app is given focus,
		# but only in its visible tab - how could we ever track something like that here?); since perfection isn't possible,
		# let's just go with the most performant variant of kinda-correct.
		declare -rg yazpt_noto_emoji_font=$loaded
	fi

	[[ $yazpt_noto_emoji_font == true ]]
}

# Tries to figure out which terminal emulator yazpt is running under.
# Sets its result into the readonly global $yazpt_terminal variable.
# Based on https://github.com/mintty/mintty/issues/776#issuecomment-475720406.
#
function .yazpt_detect_terminal() {
	emulate -L zsh

	[[ -n $yazpt_terminal && $yazpt_terminal != "unknown" ]] && return 0
	[[ $+yazpt_terminal == 1 ]] && typeset +r -g yazpt_terminal
	yazpt_terminal="unknown"  # Pessimism

	if [[ $OSTYPE == "darwin"* && -n $TERM_PROGRAM ]]; then
		# Terminal emulators on macOS tend to set $TERM_PROGRAM (e.g. Terminal.app, iTerm, Terminus)
		yazpt_terminal=${TERM_PROGRAM:l}
	else
		if [[ -t 0 ]]; then
			local tty_settings="$(stty -g)"  # Save TTY settings
			stty -echo                       # Turn echo to TTY off
		fi

		local info
		echo -n "\033[>c" > /dev/tty           # Request secondary device attributes
		read -s -t 0.1 -d ">" info < /dev/tty  # Read and discard the prefix
		read -s -t -d "c" info < /dev/tty      # Read the rest of the response

		[[ -z $tty_settings ]] || stty "$tty_settings"  # Restore TTY settings
		info=(${(s.;.)info})

		if (( $#info == 3 )); then
			if [[ $info[1] == 0 && $info[2] == 115 ]]; then
				yazpt_terminal="konsole"
			elif [[ $info[1] == 41 ]]; then
				yazpt_terminal="xterm"
			elif (( ($info[1] == 1 && $info[2] >= 2000) || $info[1] == 65 )); then
				# Could be GNOME Terminal, MATE Terminal, or Xfce Terminal (and maybe others?)
				local desktop=$XDG_CURRENT_DESKTOP
				[[ -n $GNOME_TERMINAL_SCREEN || $desktop == *"GNOME"* || $desktop == "X-Cinnamon" || $desktop == "Unity" ]] && \
					yazpt_terminal="gnome-terminal"
				[[ $XDG_CURRENT_DESKTOP == "MATE" ]] && yazpt_terminal="mate-terminal"
				[[ $XDG_CURRENT_DESKTOP == "XFCE" ]] && yazpt_terminal="xfce4-terminal"
			elif [[ $info[1] == 67 && $TERM_PROGRAM == "Terminus" ]]; then
				yazpt_terminal="terminus"  # Only seen on MSYS2
			elif [[ $info[1] == 77 ]]; then
				yazpt_terminal="mintty"
			elif [[ $info == "0 136 0" && -n $ConEmuBuild ]]; then
				yazpt_terminal="conemu"
			elif [[ $info == "0 136 0" && $PATH == *"/MobaXterm/"* ]]; then
				yazpt_terminal="mobaxterm"
			fi
		elif (( $#info == 0 )); then
			[[ -n $TERM_PROGRAM ]] && yazpt_terminal=${TERM_PROGRAM:l}  # Including Terminus
		fi
	fi

	typeset -rg yazpt_terminal
	[[ $yazpt_terminal != "unknown" ]]
}

# Parses the given layout into the given variable, intended to be $PS1 or $RPS1.
# This is called from yazpt_precmd (possibly twice).
#
function .yazpt_parse_layout() {
	local layout=$1
	local var=$2

	emulate -L zsh
	local output=""               # Stand-in for PS1 or RPS1; copied into $var at the end
	local escaped=false           # Did the previous character escape this one?
	local last_was_segment=false  # Was the last character appended to the output from a segment?
	local parsing_segment=false   # Are we parsing a segment right now?
	local segment=""              # The segment we've parsed so far, if any
	local separator=""            # The pending segment separator, if any

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
					output+='<'
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
						[[ -z $separator ]] || output+="${separator[2,-1]}"

						last_was_segment=true
						output+="$yazpt_state[$segment]"
					fi

					separator=""  # Clear any pending separator (whether we appended it just above or not)
				else
					# We don't have a function for this segment;
					# just append it verbatim, i.e. treat it as not a segment after all
					last_was_segment=false
					separator=""
					output+="<$segment>"
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
			output+="$ch"
		fi
	done

	if [[ -n $segment ]]; then
		# We were in a segment, but it never ended;
		# just append it verbatim, i.e. treat it as not a segment after all
		output+="<$segment"
	fi

	eval "$var=${(q)output}"
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
		[[ -o prompt_bang ]] && cwd=${cwd//'!'/'!!'}    # Escape exclamation marks from prompt expansion
		[[ -o prompt_percent ]] && cwd="${cwd//\%/%%}"  # Escape percent signs from prompt expansion
		[[ -o prompt_subst ]] && _yazpt_subst[cwd]="$cwd" && cwd='$_yazpt_subst[cwd]'
	fi

	[[ -n $cwd ]] || cwd='%~'
	[[ $_yazpt_terminus_hacks == true ]] && cwd=" $cwd "
	yazpt_state[cwd]="%{%F{${YAZPT_CWD_COLOR:=default}}%}${cwd}%{%f%}"
}

# Implements the "exectime" prompt segment, which shows the previous command's execution time,
# formatted with hours/minutes/seconds, eliding any values which are zeros.
#
function @yazpt_segment_exectime() {
	[[ -n $_yazpt_cmd_exec_start ]] || return
	local secs=$(( SECONDS - _yazpt_cmd_exec_start ))
	unset _yazpt_cmd_exec_start
	(( secs >= YAZPT_EXECTIME_MIN_SECONDS )) || return

	# Format as hours/minutes/seconds
	local minutes=$(( secs / 60 )) && secs=$(( secs % 60 ))
	local hours=$(( minutes / 60 )) && minutes=$(( minutes % 60 ))

	local fmt=""
	(( hours > 0 )) && fmt+="${hours}h"

	if (( minutes > 0 )); then
		[[ -n $fmt ]] && fmt+=" "
		fmt+="${minutes}m"
	fi

	if (( secs > 0 )); then
		[[ -n $fmt ]] && fmt+=" "
		fmt+="${secs}s"
	fi

	[[ -o prompt_bang ]] && local char=${YAZPT_EXECTIME_CHAR//'!'/'!!'} || local char=$YAZPT_EXECTIME_CHAR
	[[ -o prompt_percent ]] && char=${char//\%/%%}

	# zsh 5.3 renders slightly wrong if the Unicode hourglass is used in either prompt,
	# apparently because it doesn't realize it's two characters wide (at least on macOS);
	# we can fix the problem by telling zsh an inverse untruth
	if [[ $char == *"$yazpt_hourglass"* && $OSTYPE == "darwin"* ]]; then
		local zsh_ver_parts=(${(s:.:)ZSH_VERSION})
		local zsh_ver="$zsh_ver_parts[1].$zsh_ver_parts[2]"
		(( $zsh_ver <= 5.3 )) && char=$'  %{\b\b'"${char}%}"  # (Only accounting for one hourglass)
	fi

	yazpt_state[exectime]="%{%F{${YAZPT_EXECTIME_COLOR:=default}}%}${char}${fmt}%{%f%}"
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
			[[ -o prompt_bang ]] && local char=${YAZPT_EXIT_OK_CHAR//'!'/'!!'} || local char=$YAZPT_EXIT_OK_CHAR
			[[ -o prompt_percent ]] && char=${char//\%/%%}
			yazpt_state[exit]="%{%F{${YAZPT_EXIT_OK_COLOR:=default}}%}$char%{%f%}"
			[[ $_yazpt_terminus_hacks == true ]] && yazpt_state[exit]="$char"$'\b '
		fi

		if [[ ${YAZPT_EXIT_OK_CODE_VISIBLE:l} == true ]]; then
			if [[ -z $ZPREZTODIR ]] || zstyle -T ':prezto:module:prompt' show-return-val; then
				[[ $_yazpt_terminus_hacks == true ]] && yazpt_state[exit]+=" " && YAZPT_EXIT_OK_COLOR=7
				yazpt_state[exit]+="%{%F{${YAZPT_EXIT_OK_COLOR:=default}}%}$exit_code%{%f%}"
			fi
		fi
	else
		if [[ -n $YAZPT_EXIT_ERROR_CHAR ]]; then
			[[ -o prompt_bang ]] && local char=${YAZPT_EXIT_ERROR_CHAR//'!'/'!!'} || local char=$YAZPT_EXIT_ERROR_CHAR
			[[ -o prompt_percent ]] && char=${char//\%/%%}
			yazpt_state[exit]="%{%F{${YAZPT_EXIT_ERROR_COLOR:=default}}%}$char%{%f%}"
			[[ $_yazpt_terminus_hacks == true ]] && yazpt_state[exit]="$char"$'\b '
		fi

		if [[ ${YAZPT_EXIT_ERROR_CODE_VISIBLE:l} == true ]]; then
			if [[ -z $ZPREZTODIR ]] || zstyle -T ':prezto:module:prompt' show-return-val; then
				[[ $_yazpt_terminus_hacks == true ]] && yazpt_state[exit]+=" " && YAZPT_EXIT_ERROR_COLOR=7
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
	[[ ${(t)YAZPT_VCS_GIT_WHITELIST} == array ]] && ! .yazpt_check_whitelist YAZPT_VCS_GIT_WHITELIST && return

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

	[[ -o prompt_bang ]] && context=${context//'!'/'!!'}
	[[ -o prompt_percent ]] && context="${context//\%/%%}"
	context="%{%F{$color}%}${context#refs/heads/}${activity}%{%f%}"

	if [[ -o prompt_subst ]]; then
		_yazpt_subst[context]="$context"
		context='$_yazpt_subst[context]'
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

		local i extra="" git_status=""
		[[ $_yazpt_terminus_hacks == true ]] && extra=" "

		for (( i=1; i <= $#statuses; i++ )); do
			local char_var="YAZPT_VCS_STATUS_${statuses[$i]}_CHAR"
			local color_var="${char_var%_CHAR}_COLOR"

			if [[ -n ${(P)${char_var}} ]]; then
				local char=${(P)${char_var}}
				[[ -o prompt_bang ]] && char=${char//'!'/'!!'}
				[[ -o prompt_percent ]] && char="${char//\%/%%}"
				git_status+="%{%F{${(P)${color_var}:=default}}%}${char}${extra}%{%f%}"
			fi
		done
	fi

	# Combine Git context and status
	local combined="$context"
	if [[ -n $git_status ]]; then
		combined+=" $git_status"
	fi

	if (( ${#YAZPT_VCS_WRAPPER_CHARS} >= 2 )); then
		local before=$YAZPT_VCS_WRAPPER_CHARS[1]
		[[ -o prompt_bang ]] && before=${before//'!'/'!!'}
		[[ -o prompt_percent ]] && before="${before//\%/%%}"

		local after=$YAZPT_VCS_WRAPPER_CHARS[2]
		[[ -o prompt_bang ]] && after=${after//'!'/'!!'}
		[[ -o prompt_percent ]] && after="${after//\%/%%}"

		before="%{%F{$color}%}${before}%{%f%}"
		after="%{%F{$color}%}${after}%{%f%}"
		combined="${before}${extra}${combined}${after}"
	fi

	yazpt_state[git]="$combined"
}

# Stub/loader for the real @yazpt_segment_svn function in segment-svn.zsh,
# which implements the "svn" prompt segment.
#
function @yazpt_segment_svn() {
	# Check the whitelist
	[[ ${(t)YAZPT_VCS_SVN_WHITELIST} == array ]] && ! .yazpt_check_whitelist YAZPT_VCS_SVN_WHITELIST && return

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
	[[ ${(t)YAZPT_VCS_TFVC_WHITELIST} == array ]] && ! .yazpt_check_whitelist YAZPT_VCS_TFVC_WHITELIST && return

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

# Set some variables that'll be used in multiple presets, tweaks, etc.
# These two hourglass characters look the same in VS Code, but they aren't.
(( $+yazpt_hourglass )) || declare -rg yazpt_hourglass="⌛︎"
(( $+yazpt_hourglass_emoji )) || declare -rg yazpt_hourglass_emoji="⌛ "

# Set up our defaults, by loading our default preset. Other presets can be loaded
# with yazpt_load_preset (run yazpt_list_presets to see the list of presets),
# or of course the YAZPT_* environment variables can be tweaked individually;
# those environment variables are listed and described in presets/default-preset.zsh.
[[ -n $yazpt_base_dir ]] || declare -rg yazpt_base_dir=${${(%):-%x}:A:h}
[[ -n $yazpt_default_preset_file ]] || declare -rg yazpt_default_preset_file="$yazpt_base_dir/presets/default-preset.zsh"
source "$yazpt_default_preset_file"
[[ ${YAZPT_READ_RC_FILE:l} != false && -e ~/.yazptrc ]] && source ~/.yazptrc

# Begin using the yazpt prompt theme as soon as this file is sourced.
unset _yazpt_cmd_exec_start
setopt prompt_percent

autoload -Uz add-zsh-hook
add-zsh-hook precmd yazpt_precmd
add-zsh-hook preexec yazpt_preexec

# Compile this file and our default preset file in the background,
# for faster loading NEXT time (it's too late to affect this load anyway).
if [[ ${YAZPT_COMPILE:l} != false ]]; then
	{
		.yazpt_compile ${${(%):-%x}:A}  # This file
		.yazpt_compile $yazpt_default_preset_file
	} &> /dev/null &!
fi
