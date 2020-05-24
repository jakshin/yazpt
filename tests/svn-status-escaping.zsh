#!/bin/zsh
# Tests for our escaping of Subversion status characters.
# We escape `!` if prompt_bang is on, and `%` if prompt_percent is on (which it always should be),
# but let `$` expressions through, as a feature.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name "svn"
YAZPT_VCS_ORDER=(svn)

function svn_mock_error() {
	if [[ $1 == "status" ]]; then
		return 1
	else
		command svn "$@"
	fi
}

function svn_mock_conflict() {
	if [[ $1 == "status" ]]; then
		#     1234567 filename
		echo 'CC    C dummy'
	else
		command svn "$@"
	fi
}

function svn_mock_locked() {
	if [[ $1 == "status" ]]; then
		#     1234567 filename
		echo '     K  dummy'
	else
		command svn "$@"
	fi
}

function reset_svn_status_chars() {
	YAZPT_VCS_STATUS_CLEAN_CHAR="●"
	YAZPT_VCS_STATUS_DIRTY_CHAR="⚑"
	YAZPT_VCS_STATUS_LOCKED_CHAR="⊠"
	YAZPT_VCS_STATUS_CONFLICT_CHAR="≠"
	YAZPT_VCS_STATUS_UNKNOWN_CHAR="⌀"
}

function test_escaping() {
	local bang_or_percent=$1
	local char_var=$2
	local color_var="${char_var%_CHAR}_COLOR"

	reset_svn_status_chars
	eval "$char_var='$bang_or_percent'"

	if [[ $char_var == 'YAZPT_VCS_WRAPPER_CHARS' ]]; then
		eval "$char_var=('$bang_or_percent' '$bang_or_percent')"
		color_var='YAZPT_VCS_CONTEXT_COLOR'
	fi

	setopt prompt_bang
	setopt prompt_percent

	test_init_done
	contains "%{%F{${(P)color_var}}%}${bang_or_percent}${bang_or_percent}%{%f%}"

	[[ $bang_or_percent == '!' ]] && setopt no_prompt_bang || setopt no_prompt_percent
	test_init_done
	contains "%{%F{${(P)color_var}}%}${bang_or_percent}%{%f%}"
	[[ $bang_or_percent == '!' ]] && excludes "${bang_or_percent}${bang_or_percent}"
}

function test_bang_escaping() {
	test_escaping '!' $1
}

function test_percent_escaping() {
	test_escaping '%' $1
}

# Test
test_case "YAZPT_VCS_STATUS_CLEAN_CHAR"
test_bang_escaping YAZPT_VCS_STATUS_CLEAN_CHAR
test_percent_escaping YAZPT_VCS_STATUS_CLEAN_CHAR

test_case "YAZPT_VCS_STATUS_DIRTY_CHAR"
touch new-file.txt
test_bang_escaping YAZPT_VCS_STATUS_DIRTY_CHAR
test_percent_escaping YAZPT_VCS_STATUS_DIRTY_CHAR
rm -f new-file.txt

test_case "YAZPT_VCS_STATUS_LOCKED_CHAR"
alias svn=svn_mock_locked
test_bang_escaping YAZPT_VCS_STATUS_LOCKED_CHAR
test_percent_escaping YAZPT_VCS_STATUS_LOCKED_CHAR
unalias svn

test_case "YAZPT_VCS_STATUS_CONFLICT_CHAR"
alias svn=svn_mock_conflict
test_bang_escaping YAZPT_VCS_STATUS_CONFLICT_CHAR
test_percent_escaping YAZPT_VCS_STATUS_CONFLICT_CHAR
unalias svn

test_case "YAZPT_VCS_STATUS_UNKNOWN_CHAR"
alias svn=svn_mock_error
test_bang_escaping YAZPT_VCS_STATUS_UNKNOWN_CHAR
test_percent_escaping YAZPT_VCS_STATUS_UNKNOWN_CHAR
unalias svn

test_case "YAZPT_VCS_WRAPPER_CHARS"
test_bang_escaping YAZPT_VCS_WRAPPER_CHARS
test_percent_escaping YAZPT_VCS_WRAPPER_CHARS

# Clean up
after_tests
