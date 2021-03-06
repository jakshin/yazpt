# Implements the "svn" prompt segment, which shows the Subversion branch/tag, relevant extra info, 
# e.g. if the current directory is unversioned, and 1-3 characters indicating the current status of the working copy.
#
# Copyright (c) 2020 Jason Jackson <jasonjackson@pobox.com>. Distributed under GPL v2.0, see LICENSE for details.
#
function @yazpt_segment_svn() {
	# Check the path prefix list
	[[ ${(t)YAZPT_SVN_PATHS} == array ]] && ! .yazpt_check_path YAZPT_SVN_PATHS && return

	# Find out which branch/tag we've got checked out, and where the working copy's root directory is
	local xml svn_exit_code
	xml=(${(f)"$(svn info --xml 2>&1)"})
	svn_exit_code=$?

	local rel_url wc_root extra color=$YAZPT_VCS_CONTEXT_COLOR

	if [[ $xml[3] == "svn: E155007:"* ]]; then
		# The current working directory isn't in a Subversion working copy
		return
	elif [[ $xml[3] == *"W155010"* && $xml[5] == *"E200009"* ]]; then
		# Subversion has apparently noticed a .svn directory somewhere in a parent directory,
		# so we know we're in an unversioned, possibly ignored, subdirectory of a working copy
		wc_root="$(.yazpt_find_svn_root)"

		# Concatenate together the relative URL based on where we checked the repo out,
		# and where the directory we couldn't get svn info from is located relative to the WC root
		rel_url="$(cd $wc_root; svn info --show-item relative-url 2> /dev/null)"
		rel_url="$(printf "${rel_url//\%/\\x}")"  # Decode URL-encoding
		rel_url="${rel_url%/}"                    # Strip any trailing slash (e.g. when '^/')
		rel_url+="${PWD#$wc_root}"

		if [[ $PWD == "$wc_root/.svn"* ]]; then
			extra="|IN-SVN-DIR"
			color=$YAZPT_VCS_CONTEXT_META_COLOR
		else
			extra="|UNVERSIONED"
			color=$YAZPT_VCS_CONTEXT_UNVERSIONED_COLOR
		fi
	elif [[ $svn_exit_code != 0 ]]; then
		# Subversion CLI isn't installed or isn't working
		yazpt_state[svn_error]=$svn_exit_code
		return
	fi

	local i
	for (( i=1; i <= $#xml; i++ )); do
		[[ -n $rel_url && -n $wc_root ]] && break
		local line=$xml[$i]

		if [[ $line == "<relative-url>"* ]]; then
			rel_url=${${line#<relative-url>}%</relative-url>}
			rel_url="$(printf "${rel_url//\%/\\x}")"  # Decode URL-encoding
		elif [[ $line == "<wcroot-abspath>"* ]]; then
			wc_root=${${line#<wcroot-abspath>}%</wcroot-abspath>}
		fi
	done

	if [[ -z $rel_url || -z $wc_root ]]; then
		return  # Something went wrong, not sure what...
	fi

	rel_url=${rel_url#^}
	local context

	if [[ $rel_url == "/trunk" || $rel_url == "/trunk/"* ]]; then
		context="trunk"
	else
		local words=(${(s./.)rel_url})
		if [[ $#words == 0 || $words[1] == ".svn" ]]; then
			context="SVN-ROOT"
		elif [[ $#words == 1 ]]; then
			context=$words[1]
		else
			context=$words[2]  # e.g. /branches/foo -> foo
		fi
	fi

	[[ -o prompt_bang ]] && context=${context//'!'/'!!'}
	[[ -o prompt_percent ]] && context="${context//\%/%%}"
	context="%{%F{$color}%}${context}${extra}%{%f%}"

	if [[ -o prompt_subst ]]; then
		_yazpt_subst[context]="$context"
		context='$_yazpt_subst[context]'
	fi

	# Find out the working copy's status (not the current working directory's)
	{
		declare -ag _yazpt_svn_status_lines
		if [[ $PWD == $wc_root ]]; then
			_yazpt_svn_status_lines=(${(f)"$(svn status --ignore-externals 2> /dev/null)"})
			svn_exit_code=$?
		else
			_yazpt_svn_status_lines=(${(f)"$(cd $wc_root; svn status --ignore-externals 2> /dev/null)"})
			svn_exit_code=$?
		fi

		declare -Ag _yazpt_svn_status=()
		if [[ $svn_exit_code != 0 ]]; then
			_yazpt_svn_status[unknown]=true
		else
			.yazpt_parse_svn_status
		fi

		local statuses=()
		if [[ $_yazpt_svn_status[unknown] == true ]]; then
			[[ -n $YAZPT_VCS_STATUS_UNKNOWN_CHAR ]] && statuses+="UNKNOWN"
		else
			[[ $_yazpt_svn_status[locked] == true && -n $YAZPT_VCS_STATUS_LOCKED_CHAR ]] && statuses+="LOCKED"
			[[ $_yazpt_svn_status[dirty] == true && -n $YAZPT_VCS_STATUS_DIRTY_CHAR ]] && statuses+="DIRTY"
			[[ $_yazpt_svn_status[conflict] == true && -n $YAZPT_VCS_STATUS_CONFLICT_CHAR ]] && statuses+="CONFLICT"

			[[ $_yazpt_svn_status[locked] != true && $_yazpt_svn_status[dirty] != true && $_yazpt_svn_status[conflict] != true ]] && \
				[[ -n $YAZPT_VCS_STATUS_CLEAN_CHAR ]] && statuses+="CLEAN"
		fi

		local i=1 svn_status=""
		for (( i=1; i <= $#statuses; i++ )); do
			local char_var="YAZPT_VCS_STATUS_${statuses[$i]}_CHAR"
			local color_var="${char_var%_CHAR}_COLOR"

			if [[ -n ${(P)${char_var}} ]]; then
				local char=${(P)${char_var}}
				[[ -o prompt_bang ]] && char=${char//'!'/'!!'}
				[[ -o prompt_percent ]] && char="${char//\%/%%}"
				svn_status+="%{%F{${(P)${color_var}:=default}}%}${char}%{%f%}"
			fi
		done
	} always {
		unset _yazpt_svn_status_lines _yazpt_svn_status
	}

	# Combine context and status
	local combined="$context"
	if [[ -n $svn_status ]]; then
		combined+=" $svn_status"
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
		combined="${before}${combined}${after}"
	fi

	yazpt_state[svn]="$combined"
}

# Utility function for @yazpt_segment_svn. Tries to find a working copy's root directory,
# by walking up the directory tree looking for a valid .svn directory.
#
function .yazpt_find_svn_root() {
	local dir=$PWD

	while [[ -r $dir ]]; do
		if [[ -d "$dir/.svn" && -e "$dir/.svn/entries" && -e "$dir/.svn/format" && -e "$dir/.svn/wc.db" ]]; then
			echo $dir
			return
		fi

		[[ $dir == "/" ]] && return
		dir=${dir:h}
	done
}

# Utility function for @yazpt_segment_svn. Parses the output of `svn status`,
# finding out whether any files are locked, added/modified/deleted, or conflicted.
# Reads from the $_yazpt_svn_status_lines array, writes to the $_yazpt_svn_status associative array.
#
function .yazpt_parse_svn_status() {
	local i skip=false

	for (( i=1; i <= $#_yazpt_svn_status_lines; i++ )); do
		local line=$_yazpt_svn_status_lines[$i]
		if [[ $skip == true ]]; then
			skip=false
			continue
		fi
		
		# First column: Says if item was added, deleted, or otherwise changed
		if [[ 'ADMR?!' == *"$line[1]"* ]]; then
			_yazpt_svn_status[dirty]=true
		elif [[ 'C~' == *"$line[1]"* ]]; then
			_yazpt_svn_status[conflict]=true
		fi

		# Second column: Modifications of a file's or directory's properties
		[[ $line[2] == 'C' ]] && _yazpt_svn_status[conflict]=true
		[[ $line[2] == 'M' ]] && _yazpt_svn_status[dirty]=true

		# Fourth column: Scheduled commit will create a copy (addition-with-history)
		[[ $line[4] == '+' ]] && _yazpt_svn_status[dirty]=true

		# Fifth column: Whether the item is switched or a file external
		[[ $line[5] == 'S' ]] && _yazpt_svn_status[dirty]=true

		# Sixth column: Whether the item is locked in the working copy for exclusive commit
		# (The lock might actually be stolen or broken, we don't check the server)
		[[ $line[6] == 'K' ]] && _yazpt_svn_status[locked]=true

		# Seventh column: Whether the item is the victim of a tree conflict
		# (If the item is a tree conflict victim, an additional line is printed
		# after the item's status line, explaining the nature of the conflict)
		if [[ $line[7] == 'C' ]]; then
			_yazpt_svn_status[conflict]=true
			skip=true
		fi

		# TODO: Under what conditions does it become worth checking here whether
		# conflict+dirty+locked have all been found already, and short-circuiting?
		# Can we optimize by skipping checks if we've already turned a flag on,
		# e.g. don't bother to look at columns 4 or 5 if already dirty, etc?
	done
}
