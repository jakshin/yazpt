# Implements the "svn" prompt segment, which shows the Subversion branch/tag, relevant extra info, 
# e.g. if the current directory is unversioned, and 1-3 characters indicating the current status of the working copy.
#
function yazpt_segment_svn() {
	# Check the whitelist
	if [[ ${(t)YAZPT_VCS_SVN_WHITELIST} == array ]] && ! yazpt_test_whitelist YAZPT_VCS_SVN_WHITELIST; then
		return
	fi

	# Find out which branch/tag we've got checked out, and where the working copy's root directory is
	local xml svn_exit_code
	xml=(${(f)"$(svn info --xml 2>&1)"})
	svn_exit_code=$?

	local rel_url wc_root extra color=$YAZPT_VCS_BRANCH_COLOR

	if [[ $xml[3] == "svn: E155007:"* ]]; then
		# The current working directory isn't in a Subversion working copy
		return
	elif [[ $xml[3] == *"W155010"* && $xml[5] == *"E200009"* ]]; then
		# Subversion has apparently noticed a .svn directory somewhere in a parent directory,
		# so we know we're in an unversioned, possibly ignored, subdirectory of a working copy
		wc_root="$(yazpt_find_svn_root)"

		# Concatenate together the relative URL based on where we checked the repo out,
		# and where the directory we couldn't get svn info from is located relative to the WC root
		rel_url="$(cd $wc_root; svn info --show-item relative-url 2> /dev/null)"
		rel_url="$(printf "${rel_url//\%/\\x}")"  # Decode URL-encoding
		rel_url="${rel_url%/}"                    # Strip any trailing slash (e.g. when '^/')
		rel_url+="${PWD#$wc_root}"

		if [[ $PWD == "$wc_root/.svn"* ]]; then
			extra="|IN-SVN-DIR"
			color=$YAZPT_VCS_BRANCH_IN_META_COLOR
		else
			extra="|UNVERSIONED"
			color=$YAZPT_VCS_BRANCH_IN_UNVERSION_COLOR
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
	local branch

	if [[ $rel_url == "/trunk" || $rel_url == "/trunk/"* ]]; then
		branch="trunk"
	else
		local words=(${(s./.)rel_url})
		if [[ $#words == 0 || $words[1] == ".svn" ]]; then
			branch="SVN-ROOT"
		elif [[ $#words == 1 ]]; then
			branch=$words[1]
		else
			branch=$words[2]  # e.g. /branches/foo -> foo
		fi
	fi

	if [[ -o prompt_bang ]]; then
		# Escape exclamation marks from prompt expansion, by doubling them
		branch=${branch//'!'/'!!'}
	fi

	branch="${branch//\%/%%}"  # Escape percent signs from prompt expansion
	branch="%{%F{$color}%}${branch}${extra}%{%f%}"

	if [[ -o prompt_subst ]]; then
		yazpt_branch="$branch"
		branch='$yazpt_branch'
	else
		unset yazpt_branch
	fi

	# Find out the working copy's status (not the current working directory's)
	{
		declare -ag yazpt_svn_status_lines
		if [[ $PWD == $wc_root ]]; then
			yazpt_svn_status_lines=(${(f)"$(svn status --ignore-externals 2> /dev/null)"})
			svn_exit_code=$?
		else
			yazpt_svn_status_lines=(${(f)"$(cd $wc_root; svn status --ignore-externals 2> /dev/null)"})
			svn_exit_code=$?
		fi

		declare -Ag yazpt_svn_status=()
		if [[ $svn_exit_code != 0 ]]; then
			yazpt_svn_status[unknown]=true
		else
			yazpt_parse_svn_status
		fi

		local svn_status
		if [[ $yazpt_svn_status[unknown] == true ]]; then
			if [[ -n $YAZPT_VCS_STATUS_UNKNOWN_CHAR ]]; then
				svn_status+="%{%F{${YAZPT_VCS_STATUS_UNKNOWN_COLOR:=default}}%}$YAZPT_VCS_STATUS_UNKNOWN_CHAR%{%f%}"
			fi
		else
			[[ $yazpt_svn_status[locked] == true && -n $YAZPT_VCS_STATUS_LOCKED_CHAR ]] && \
				svn_status+="%{%F{${YAZPT_VCS_STATUS_LOCKED_COLOR:=default}}%}$YAZPT_VCS_STATUS_LOCKED_CHAR%{%f%}"
			[[ $yazpt_svn_status[dirty] == true && -n $YAZPT_VCS_STATUS_DIRTY_CHAR ]] && \
				svn_status+="%{%F{${YAZPT_VCS_STATUS_DIRTY_COLOR:=default}}%}$YAZPT_VCS_STATUS_DIRTY_CHAR%{%f%}"
			[[ $yazpt_svn_status[conflict] == true && -n $YAZPT_VCS_STATUS_CONFLICT_CHAR ]] && \
				svn_status+="%{%F{${YAZPT_VCS_STATUS_CONFLICT_COLOR:=default}}%}$YAZPT_VCS_STATUS_CONFLICT_CHAR%{%f%}"

			if [[ -z $svn_status && -n $YAZPT_VCS_STATUS_CLEAN_CHAR ]]; then
				if [[ $yazpt_svn_status[locked] != true && $yazpt_svn_status[dirty] != true && $yazpt_svn_status[conflict] != true ]]; then
					svn_status="%{%F{${YAZPT_VCS_STATUS_CLEAN_COLOR:=default}}%}$YAZPT_VCS_STATUS_CLEAN_CHAR%{%f%}"
				fi
			fi
		fi
	} always {
		unset yazpt_svn_status_lines yazpt_svn_status
	}

	# Combine branch and status
	local combined="$branch"
	if [[ -n $svn_status ]]; then
		combined+=" $svn_status"
	fi

	if (( ${#YAZPT_VCS_WRAPPER_CHARS} >= 2 )); then
		local before="%{%F{$color}%}$YAZPT_VCS_WRAPPER_CHARS[1]%{%f%}"
		local after="%{%F{$color}%}$YAZPT_VCS_WRAPPER_CHARS[2]%{%f%}"
		combined="${before}${combined}${after}"
	fi

	yazpt_state[svn]="$combined"
}

# Utility function for yazpt_segment_svn. Tries to find a working copy's root directory,
# by walking up the directory tree looking for a valid .svn directory.
#
function yazpt_find_svn_root() {
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

# Utility function for yazpt_segment_svn. Parses the output of `svn status`,
# finding out whether any files are locked, added/modified/deleted, or conflicted.
#
function yazpt_parse_svn_status() {
	local i skip=false

	for (( i=1; i <= $#yazpt_svn_status_lines; i++ )); do
		local line=$yazpt_svn_status_lines[$i]
		if [[ $skip == true ]]; then
			skip=false
			continue
		fi
		
		# First column: Says if item was added, deleted, or otherwise changed
		if [[ 'ADMR?!' == *"$line[1]"* ]]; then
			yazpt_svn_status[dirty]=true
		elif [[ 'C~' == *"$line[1]"* ]]; then
			yazpt_svn_status[conflict]=true
		fi

		# Second column: Modifications of a file's or directory's properties
		[[ $line[2] == 'C' ]] && yazpt_svn_status[conflict]=true
		[[ $line[2] == 'M' ]] && yazpt_svn_status[dirty]=true

		# Fourth column: Scheduled commit will create a copy (addition-with-history)
		[[ $line[4] == '+' ]] && yazpt_svn_status[dirty]=true

		# Fifth column: Whether the item is switched or a file external
		[[ $line[5] == 'S' ]] && yazpt_svn_status[dirty]=true

		# Sixth column: Whether the item is locked in the working copy for exclusive commit
		# (The lock might actually be stolen or broken, we don't check the server)
		[[ $line[6] == 'K' ]] && yazpt_svn_status[locked]=true

		# Seventh column: Whether the item is the victim of a tree conflict
		# (If the item is a tree conflict victim, an additional line is printed
		# after the item's status line, explaining the nature of the conflict)
		if [[ $line[7] == 'C' ]]; then
			yazpt_svn_status[conflict]=true
			skip=true
		fi

		# TODO: Under what conditions does it become worth checking here whether
		# conflict+dirty+locked have all been found already, and short-circuiting?
		# Can we optimize by skipping checks if we've already turned a flag on,
		# e.g. don't bother to look at columns 4 or 5 if already dirty, etc?
	done
}
