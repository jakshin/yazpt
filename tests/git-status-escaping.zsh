#!/bin/zsh
# Tests for our escaping of Git status characters.
# We escape `!` if prompt_bang is on, and `%` if prompt_percent is on (which it always should be),
# but let `$` expressions through, as a feature.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name "git"
YAZPT_VCS_ORDER=(git)

function git_mock() {
	if [[ $1 == "status" ]]; then
		return 1
	else
		command git "$@"
	fi
}

function reset_git_status_chars() {
	YAZPT_VCS_STATUS_CLEAN_CHAR="●"
	YAZPT_VCS_STATUS_DIRTY_CHAR="⚑"
	YAZPT_VCS_STATUS_DIVERGED_CHAR="◆"
	YAZPT_VCS_STATUS_LINKED_BARE_CHAR="⚭"
	YAZPT_VCS_STATUS_NO_UPSTREAM_CHAR="◆"
	YAZPT_VCS_STATUS_UNKNOWN_CHAR="⌀"
	YAZPT_VCS_WRAPPER_CHARS=""
}

function test_escaping() {
	local bang_or_percent=$1
	local char_var=$2
	local color_var="${char_var%_CHAR}_COLOR"

	reset_git_status_chars
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

test_case "YAZPT_VCS_STATUS_DIVERGED_CHAR"
git add . && git commit -m "Add a new file"
test_bang_escaping YAZPT_VCS_STATUS_DIVERGED_CHAR
test_percent_escaping YAZPT_VCS_STATUS_DIVERGED_CHAR

test_case "YAZPT_VCS_STATUS_NO_UPSTREAM_CHAR"
git checkout -b new-branch
test_bang_escaping YAZPT_VCS_STATUS_NO_UPSTREAM_CHAR
test_percent_escaping YAZPT_VCS_STATUS_NO_UPSTREAM_CHAR

test_case "YAZPT_VCS_STATUS_UNKNOWN_CHAR"
alias git=git_mock
test_bang_escaping YAZPT_VCS_STATUS_UNKNOWN_CHAR
test_percent_escaping YAZPT_VCS_STATUS_UNKNOWN_CHAR
unalias git

test_case "YAZPT_VCS_STATUS_LINKED_BARE_CHAR"
rm -rf * .git .gitignore
git clone --bare "https://github.com/jakshin/yazpt-test.git"
cd yazpt-test.git
git worktree add ../yazpt-linked
cd ../yazpt-linked
test_bang_escaping YAZPT_VCS_STATUS_LINKED_BARE_CHAR
test_percent_escaping YAZPT_VCS_STATUS_LINKED_BARE_CHAR

test_case "YAZPT_VCS_WRAPPER_CHARS"
cd yazpt-linked
test_bang_escaping YAZPT_VCS_WRAPPER_CHARS
test_percent_escaping YAZPT_VCS_WRAPPER_CHARS

# Clean up
after_tests
