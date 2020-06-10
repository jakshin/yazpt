# Implements the "tfvc" prompt segment, which shows the Team Foundation Version Control local workspace's server path,
# and 1-2 characters indicating the current status of the workspace.
#
# Note that this prompt segment only works in local workspaces.
# IT DOESN'T WORK IN SERVER WORKSPACES - it has no idea they even exist.
#
# Copyright (c) 2020 Jason Jackson <jasonjackson@pobox.com>. Distributed under GPL v2.0, see LICENSE for details.
#
function @yazpt_segment_tfvc() {
	# Check the path prefix list
	[[ ${(t)YAZPT_TFVC_PATHS} == array ]] && ! .yazpt_check_path YAZPT_TFVC_PATHS && return

	# Determine whether the current directory is in a TFVC local workspace,
	# and if so, find out the workspace's root directory's server path
	.yazpt_find_tf_dir
	[[ -z $_yazpt_tf_dir ]] && return

	if [[ $PWD == "$_yazpt_tf_dir"* ]]; then
		local color=$YAZPT_VCS_CONTEXT_META_COLOR
		local extra="|IN-TF-DIR"
	else
		local color=$YAZPT_VCS_CONTEXT_COLOR
	fi

	.yazpt_parse_properties_tf1 "$_yazpt_tf_dir/properties.tf1"  # Sets $_yazpt_server_path
	local context=$_yazpt_server_path

	[[ -o prompt_bang ]] && context=${context//'!'/'!!'}
	[[ -o prompt_percent ]] && context="${context//\%/%%}"
	context="%{%F{$color}%}${context}${extra}%{%f%}"

	if [[ -o prompt_subst ]]; then
		_yazpt_subst[context]="$context"
		context='$_yazpt_subst[context]'
	fi

	# Find out whether the local workspace has pending changes or not
	local stat=() statuses=()
	zstat +size -A stat -- "$_yazpt_tf_dir/pendingchanges.tf1" &> /dev/null

	if [[ -z $stat && -e "$_yazpt_tf_dir/pendingchanges.tf1" ]]; then
		[[ -n $YAZPT_VCS_STATUS_UNKNOWN_CHAR ]] && statuses+="UNKNOWN"
	elif [[ -n $stat ]] && (( $stat[1] > 23 )); then
		if [[ ${YAZPT_CHECK_TFVC_LOCKS:l} == true ]]; then
			.yazpt_parse_pendingchanges_tf1 "$_yazpt_tf_dir/pendingchanges.tf1" $stat[1]  # Sets $_yazpt_tfvc_status
			[[ $_yazpt_tfvc_status[1] == y || $_yazpt_tfvc_status[2] == y ]] || _yazpt_tfvc_status[3]=y

			[[ $_yazpt_tfvc_status[1] == y && -n $YAZPT_VCS_STATUS_LOCKED_CHAR ]] && statuses+="LOCKED"
			[[ $_yazpt_tfvc_status[2] == y && -n $YAZPT_VCS_STATUS_DIRTY_CHAR ]] && statuses+="DIRTY"
			[[ $_yazpt_tfvc_status[3] == y && -n $YAZPT_VCS_STATUS_UNKNOWN_CHAR ]] && statuses+="UNKNOWN"
			unset _yazpt_tfvc_status
		elif [[ -n $YAZPT_VCS_STATUS_DIRTY_CHAR ]]; then
			statuses+="DIRTY"
		fi
	elif [[ -n $YAZPT_VCS_STATUS_CLEAN_CHAR ]]; then
		statuses+="CLEAN"
	fi

	local extra="" i=1 tfvc_status=""
	[[ $_yazpt_terminus_hacks == true ]] && extra=" "

	for (( i=1; i <= $#statuses; i++ )); do
		local char_var="YAZPT_VCS_STATUS_${statuses[$i]}_CHAR"
		local color_var="${char_var%_CHAR}_COLOR"

		if [[ -n ${(P)${char_var}} ]]; then
			local char=${(P)${char_var}}
			[[ -o prompt_bang ]] && char=${char//'!'/'!!'}
			[[ -o prompt_percent ]] && char="${char//\%/%%}"
			tfvc_status+="%{%F{${(P)${color_var}:=default}}%}${char}${extra}%{%f%}"
		fi
	done

	# Combine context and status
	local combined="$context"
	if [[ -n $tfvc_status ]]; then
		combined+=" $tfvc_status"
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

	yazpt_state[tfvc]="$combined"
	unset _yazpt_tf_dir _yazpt_server_path
}

# Utility function for @yazpt_segment_tfvc. Tries to find a TFVC local workspace's $tf or .tf directory,
# which indicates the existence of a TFVC local workspace, by walking up the directory tree looking.
# Sets $_yazpt_tf_dir to an absolute path, or an empty string if no $tf or .tf directory was found.
#
function .yazpt_find_tf_dir() {
	local dir=$PWD

	if [[ -z $yazpt_tf_dir_name ]]; then
		if [[ $OS == "Windows"* ]]; then
			yazpt_tf_dir_name='$tf'
		else
			yazpt_tf_dir_name='.tf'
		fi
	fi

	while [[ -r $dir ]]; do
		if [[ -d "$dir/$yazpt_tf_dir_name" && -f "$dir/$yazpt_tf_dir_name/properties.tf1" ]]; then
			_yazpt_tf_dir="$dir/$yazpt_tf_dir_name"
			return
		fi

		if [[ $dir == "/" ]]; then
			_yazpt_tf_dir=""
			return
		fi

		dir=${dir:h}
	done
}

# Utility function for @yazpt_segment_tfvc. Parses change types out of pendingchanges.tf1,
# and sets $_yazpt_tfvc_status. Only called if YAZPT_CHECK_TFVC_LOCKS is `true`.
#
# Reference for pendingchanges.tf1 file format:
# https://github.com/microsoft/team-explorer-everywhere -> LocalPendingChangesTable.java
#
function .yazpt_parse_pendingchanges_tf1() {
	local pendingchanges_tf1="$1"
	_yazpt_tfvc_status=nn  # Default = no locks, nothing dirty; will trigger unknown status display unless changed

	# Check magic number and schema version byte
	.yazpt_read_file_as_hex $pendingchanges_tf1  # Sets _yazpt_file

	[[ ${_yazpt_file:0:2} == "25 74" ]] || return

	local version=$_yazpt_file[3]
	[[ $version == "01" || $version == "02" ]] || return

	# Constants from files in https://github.com/microsoft/team-explorer-everywhere
	local change_type_lock=512  # ChangeType.java
	local item_type_file=02     # ItemType.java

	# Read the pending changes
	local pos=24  # The 1-based position of our "cursor" within the file
	local i num change_type item_type lock_status

	while (( $pos < $#_yazpt_file )); do
		# Strings we don't care about (target server item, committed server item, branch from item)
		for (( i=1; i <= 3; i++ )); do
			.yazpt_read_str_in_file $pos _yazpt_str_bytes
			(( pos += _yazpt_str_bytes ))  # Length byte(s), string (which might be empty)
		done

		(( pos += 8 ))  # Bytes we don't care about (versions)

		# Change type is stored in a little-endian 32-bit uint, but we only care about the least-significant 2 bytes
		let "change_type = 0x$_yazpt_file[$pos+1] * 0x100 + 0x$_yazpt_file[$pos]"
		(( change_type & change_type_lock == 512 )) && _yazpt_tfvc_status[1]=y
		(( change_type == change_type_lock )) || _yazpt_tfvc_status[2]=y
		(( pos += 4 ))

		item_type=${_yazpt_file[$pos]}
		(( pos++ ))

		(( pos += 4 ))  # Bytes we don't care about (encoding)

		lock_status=${_yazpt_file[$pos]}
		[[ $lock_status == "01" ]] && _yazpt_tfvc_status[1]=y
		(( pos++ ))

		(( pos += 16 ))  # Bytes we don't care about (item ID, creation date, deletion ID)
		[[ $item_type == $item_type_file ]] && (( pos += 16 ))  # Bytes we don't care about, iff item is a file (hash)
		(( $version == 2 )) && (( pos++ ))  # A byte we don't care about, only present in schema v2 (flags)
	done
}

# Utility function for @yazpt_segment_tfvc. Parses the workspace's server path out of properties.tf1,
# and sets $_yazpt_server_path (using "TFVC" as its value if parsing fails).
#
# Reference for properties.tf1 file format:
# https://github.com/microsoft/team-explorer-everywhere -> LocalWorkspaceProperties.java
#
function .yazpt_parse_properties_tf1() {
	local properties_tf1="$1"
	_yazpt_server_path="TFVC"  # Default in case we fail to parse properties.tf1

	# Check magic number and schema version byte
	.yazpt_read_file_as_hex $properties_tf1  # Sets _yazpt_file

	[[ ${_yazpt_file:0:2} == "3c 7e" ]] || return
	[[ $_yazpt_file[3] == "02" ]] || return  # We only understand schema v2

	# Skip past baseline folder objects
	local count i pos=6  # The 1-based position of our "cursor" within the file
	let "count = 0x$_yazpt_file[5] * 0x100 + 0x$_yazpt_file[4]"

	for (( i=1; i <= $count; i++ )); do
		.yazpt_read_str_in_file $pos _yazpt_str_bytes
		(( pos += _yazpt_str_bytes ))  # Length byte(s), baseline folder partition

		.yazpt_read_str_in_file $pos _yazpt_str_bytes
		(( pos += _yazpt_str_bytes ))  # Length byte(s), baseline folder path

		(( pos++ ))                    # Baseline folder state byte
	done

	# Skip past baseline folder map
	let "count = 0x$_yazpt_file[$pos+1] * 0x100 + 0x$_yazpt_file[$pos]"
	(( pos += 2 ))

	for (( i=1; i <= $count; i++ )); do
		.yazpt_read_str_in_file $pos _yazpt_str_bytes
		(( pos += _yazpt_str_bytes + 2 ))  # Length byte(s) and table name, 2 index bytes
	done

	# Figure out the server path to display, by reading the working folders in the workspace,
	# and finding the one whose local path is a best match for the current directory
	local pwd="$(pwd -P)"  # Resolve symlinks in the current directory, for correct comparison to paths in properties.tf1
	local local_path="" server_path

	let "count = 0x$_yazpt_file[$pos+1] * 0x100 + 0x$_yazpt_file[$pos]"
	(( pos += 2 ))

	for (( i=1; i <= $count; i++ )); do
		.yazpt_read_str_in_file $pos _yazpt_str_bytes _yazpt_spath
		(( pos += _yazpt_str_bytes ))  # On next length byte

		.yazpt_read_str_in_file $pos _yazpt_str_bytes _yazpt_lpath
		(( pos += _yazpt_str_bytes ))  # On next length byte

		if [[ $OSTYPE == "cygwin" && -n $_yazpt_lpath ]]; then
			# Cache cygpath conversions
			(( $+_yazpt_cygpath_conversions )) || declare -Ag _yazpt_cygpath_conversions

			if [[ -z $_yazpt_cygpath_conversions[$_yazpt_lpath] ]]; then
				local fixed_path="$(cygpath "$_yazpt_lpath")"
				_yazpt_cygpath_conversions[$_yazpt_lpath]="$fixed_path"
			fi

			_yazpt_lpath="$_yazpt_cygpath_conversions[$_yazpt_lpath]"
		fi

		[[ -n $_yazpt_lpath && -n $_yazpt_spath ]] || continue
		[[ $pwd == "$_yazpt_lpath"* ]] || continue

		if (( $#_yazpt_lpath > $#local_path )); then
			local_path=$_yazpt_lpath
			server_path=$_yazpt_spath
		fi
	done

	[[ -z $server_path ]] || _yazpt_server_path=$server_path
	unset _yazpt_file _yazpt_lpath _yazpt_spath _yazpt_str_bytes
}

# Reads a file and stores its bytes as hex characters in the _yazpt_file array,
# overwriting anything already stored in the array.
#
function .yazpt_read_file_as_hex() {
	local file_path=$1          # Should be an absolute path
	local file_size=$2          # Optional, pass it if you have it, else no worries
	declare -ag _yazpt_file=()  # Return value

	# Reading a file using `$(<file)` is fast, but sometimes buggy, e.g. if a file contains `\x52\xC2`,
	# it drops the C2 - so use it if we can, but stop using it on each file we encounter problems with
	(( $+_yazpt_tf1_bugs )) || declare -Ag _yazpt_tf1_bugs

	if [[ -z $_yazpt_tf1_bugs[$file_path] ]]; then
		local bytes=$(<"$file_path")

		if [[ $file_size == "" ]]; then
			zstat +size -A file_size -- "$file_path" &> /dev/null
			file_size=$file_size[1]
		fi

		if (( $#bytes == $file_size )); then
			local hex i

			for (( i=1; i <= $#bytes; i++ )); do
				printf -v hex %.2x "'$bytes[$i]"
				_yazpt_file+=$hex
			done

			return
		elif [[ -r $file_path ]]; then
			_yazpt_tf1_bugs[$file_path]=true
		fi
	fi

	if [[ -n $_yazpt_tf1_bugs[$file_path] ]]; then
		if command -v od > /dev/null; then
			_yazpt_file=($(od -A n -vt x1 "$file_path"))
		elif command -v hexdump > /dev/null; then
			_yazpt_file=($(hexdump -ve '/1 "%.2x" " "' "$file_path"))
		fi
	fi
}

# Reads a string in the last file read by .yazpt_read_file_as_hex(), i.e. in $_yazpt_file.
#
# You must pass the 1-based position of the string's first length byte, and the name of a variable
# in which to store the total number of bytes used by the string and its length byte(s).
# If you want the string itself, converted from UTF-16, also pass the name of a variable to store it in.
#
function .yazpt_read_str_in_file() {
	local pos=$1             # Pass the 1-based index of the string's first length byte
	local pos_change_var=$2  # Variable in which to store the change to $pos caused by reading the string
	local str_var=$3         # Variable in which to store the string (optional)

	# Read the string's length byte(s)
	declare -i 16 byte
	declare -i 10 byte_count=0 multiplier=1 str_len=0

	while true; do
		byte=0x$_yazpt_file[$pos]
		(( str_len += (byte & 127) * multiplier ))
		(( pos++ && byte_count++ ))
		(( byte & 128 == 0 )) && break
		(( multiplier *= 128 ))
	done

	local pos_change=$(( byte_count + str_len ))
	eval "$pos_change_var=$pos_change"

	if [[ -n $str_var ]]; then
		# Read the string, converted from UTF-16
		local end_pos=$(( $pos + $str_len - 1 ))
		.yazpt_transform_utf16 "$_yazpt_file[$pos,$end_pos]" $str_var
	fi
}

# Transforms a little-endian UTF-16 string expressed as space-separated hex characters into equivalent displayable text,
# encoded using the system locale, and stores it into the given variable.
#
function .yazpt_transform_utf16() {
	local utf16=$1  # Space-separated hex chars expressing little-endian UTF-16 bytes
	local var=$2    # Variable in which to store the transformed text
	local text=""

	# Cache UTF-16 conversions
	# TODO: We should probably invalidate this cache if $LANG, $LC_ALL or $LC_CTYPE changes
	(( $+_yazpt_utf16_conversions )) || declare -Ag _yazpt_utf16_conversions

	if [[ -n $_yazpt_utf16_conversions[$utf16] ]]; then
		text=$_yazpt_utf16_conversions[$utf16]
	else
		setopt local_options no_multibyte

		if command -v iconv > /dev/null; then
			# Convert the hex characters to actual bytes, then pipe them through iconv
			local i hex bytes=""

			for (( i=1; i <= $#utf16; i += 3 )); do
				hex=0x$utf16[$i,$i+1]
				bytes+="${(#)hex}"
			done

			text="$(echo -n $bytes | iconv -f UTF-16LE -sc 2> /dev/null)"
		else
			# Fall back to just preserving ASCII characters
			local i hex next

			for (( i=1; i <= $#utf16; i += 6 )); do
				hex=0x$utf16[$i,$i+1]
				next=$utf16[$i+3,$i+4]
				[[ $next == "00" ]] && text+="${(#)hex}"
			done
		fi

		_yazpt_utf16_conversions[$utf16]="$text"  # Cache
	fi

	eval "$var=${(q)text}" &> /dev/null
}

# We use zstat in @yazpt_segment_tfvc and .yazpt_read_file_as_hex.
zmodload -F zsh/stat b:zstat
