#!/bin/zsh
# Tests for our escaping of TFVC status characters.
# We escape `!` if prompt_bang is on, and `%` if prompt_percent is on (which it always should be),
# but let `$` expressions through, as a feature.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name "tfvc"
YAZPT_VCS_ORDER=(tfvc)
YAZPT_CHECK_TFVC_LOCKS=true

function reset_tfvc_status_chars() {
	YAZPT_VCS_STATUS_CLEAN_CHAR="●"
	YAZPT_VCS_STATUS_DIRTY_CHAR="⚑"
	YAZPT_VCS_STATUS_LOCKED_CHAR="⊠"
	YAZPT_VCS_STATUS_UNKNOWN_CHAR="⌀"
}

function test_escaping() {
	local bang_or_percent=$1
	local char_var=$2
	local color_var="${char_var%_CHAR}_COLOR"

	reset_tfvc_status_chars
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
function .yazpt_parse_pendingchanges_tf1() { _yazpt_tfvc_status=ny }
function zstat() { stat=(24) }
function .yazpt_parse_properties_tf1() {
	# Mock this function to avoid errors caused by mocking zstat
	_yazpt_server_path='$/yazpt-tfvc-test/Mock'
}
test_bang_escaping YAZPT_VCS_STATUS_DIRTY_CHAR
test_percent_escaping YAZPT_VCS_STATUS_DIRTY_CHAR

test_case "YAZPT_VCS_STATUS_LOCKED_CHAR"
function .yazpt_parse_pendingchanges_tf1() { _yazpt_tfvc_status=yn }
test_bang_escaping YAZPT_VCS_STATUS_LOCKED_CHAR
test_percent_escaping YAZPT_VCS_STATUS_LOCKED_CHAR

test_case "YAZPT_VCS_STATUS_UNKNOWN_CHAR"
function .yazpt_parse_pendingchanges_tf1() { _yazpt_tfvc_status=nn }
test_bang_escaping YAZPT_VCS_STATUS_UNKNOWN_CHAR
test_percent_escaping YAZPT_VCS_STATUS_UNKNOWN_CHAR

test_case "YAZPT_VCS_WRAPPER_CHARS"
test_bang_escaping YAZPT_VCS_WRAPPER_CHARS
test_percent_escaping YAZPT_VCS_WRAPPER_CHARS

# Clean up
after_tests
