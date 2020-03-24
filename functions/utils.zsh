# Utility functions. These are only means to be called by other yazpt_* functions.

# Details one Git/Subversion status; shows its character, in its configured color, and a description.
# If the character is empty, it's shown as a gray "n/a".
#
function _yazpt_detail_vcs_status() {
	local color=$1 ch=$2 var=$3 desc=$4
	[[ -z $5 ]] || desc+=" $5"

	if [[ -n $ch ]]; then
		print -Pn "\n   %{%F{${color:-default}}%}${ch}%{%f%}\t"
	else
		print -Pn "\n  %{%F{240}%}n/a%{%f%}\t"
	fi

	if [[ -z $ch ]]; then
		desc+=" $var is empty, so this status isn't shown."
	else
		desc+=" Unset $var to keep this status from showing."
	fi

	_yazpt_print_wrapped $desc true
}

# Makes a command string which can be invoked to wrap text,
# and stores it as $yazpt_wrap_cmd.
#
function _yazpt_make_wrap_cmd() {
	local width=$(( $COLUMNS - 8 ))
	(( $width >= 50 )) || width=50
	(( $width <= 100 )) || width=100

	if which "fmt" &> /dev/null; then
		yazpt_wrap_cmd="fmt -w $width"
	elif which "fold" &> /dev/null; then
		yazpt_wrap_cmd="fold -sw $width"
	else
		yazpt_wrap_cmd=""
	fi
}

# Prints some text, after wrapping it (so it might be printed on multiple lines).
# You can choose whether or not to indent the 2nd+ lines with a tab.
#
function _yazpt_print_wrapped() {
	local text=$1
	local tab_indent=$2  # Boolean

	if (( $+yazpt_wrap_cmd == 0 )); then
		_yazpt_make_wrap_cmd
	fi

	if [[ -n $yazpt_wrap_cmd ]]; then
		local wrapped=(${(f)"$(echo "$text" | ${=yazpt_wrap_cmd})"})
	else
		local wrapped=("$text")
	fi

	local i
	for (( i=1; i <= $#wrapped; i++ )); do
		local line=$wrapped[$i]
		[[ $i == 1 || $tab_indent != true ]] || echo -n "\t"
		echo $line
	done
}

# Prints some header text, after wrapping it.
#
function _yazpt_print_wrapped_header() {
	echo -n "\e[1m"
	_yazpt_print_wrapped "$1"
	echo -n "\e[0m"
}

# Prints some warning/alert text, after wrapping it.
#
function _yazpt_print_wrapped_warning() {
	echo -n "\e[38;5;217m"
	_yazpt_print_wrapped "$1"
	echo -n "\e[0m"
}
