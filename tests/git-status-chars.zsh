#!/bin/zsh
# Tests for our handling of git status characters.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name true

function gitx() {
	if [[ $1 == "status" ]]; then
		return 1
	else
		command git "$@"
	fi
}

function reset_git_status_chars() {
	YAZPT_GIT_STATUS_CLEAN_CHAR="●"
	YAZPT_GIT_STATUS_DIRTY_CHAR="⚑"
	YAZPT_GIT_STATUS_DIVERGED_CHAR="◆"
	YAZPT_GIT_STATUS_LINKED_BARE_CHAR="⚭"
	YAZPT_GIT_STATUS_NO_UPSTREAM_CHAR="◆"
	YAZPT_GIT_STATUS_UNKNOWN_CHAR="⌀"
}

# Test
function run_tests() {
	test_case "Empty YAZPT_GIT_STATUS_CLEAN_CHAR"
	reset_git_status_chars
	test_init_done
	contains "●"
	contains "%F{$YAZPT_GIT_STATUS_CLEAN_CHAR_COLOR}"
	YAZPT_GIT_STATUS_CLEAN_CHAR=""
	test_init_done
	excludes_status
	excludes "%F{$YAZPT_GIT_STATUS_CLEAN_CHAR_COLOR}"

	test_case "Empty YAZPT_GIT_STATUS_DIRTY_CHAR"
	reset_git_status_chars
	touch new-file.txt
	test_init_done
	contains "⚑"
	contains "%F{$YAZPT_GIT_STATUS_DIRTY_CHAR_COLOR}"
	YAZPT_GIT_STATUS_DIRTY_CHAR=""
	test_init_done
	excludes_status
	excludes "%F{$YAZPT_GIT_STATUS_DIRTY_CHAR_COLOR}"
	excludes "%F{$YAZPT_GIT_STATUS_CLEAN_CHAR_COLOR}"

	test_case "Empty YAZPT_GIT_STATUS_DIVERGED_CHAR"
	reset_git_status_chars
	git add . && git commit -m "Add a new file"
	test_init_done
	contains "◆"
	contains "%F{$YAZPT_GIT_STATUS_DIVERGED_CHAR_COLOR}"
	YAZPT_GIT_STATUS_DIVERGED_CHAR=""
	test_init_done
	excludes_status
	excludes "%F{$YAZPT_GIT_STATUS_DIVERGED_CHAR_COLOR}"
	excludes "%F{$YAZPT_GIT_STATUS_CLEAN_CHAR_COLOR}"

	test_case "Empty YAZPT_GIT_STATUS_NO_UPSTREAM_CHAR"
	reset_git_status_chars
	git checkout -b new-branch
	test_init_done
	contains "◆"
	contains "%F{$YAZPT_GIT_STATUS_NO_UPSTREAM_CHAR_COLOR}"
	YAZPT_GIT_STATUS_NO_UPSTREAM_CHAR=""
	test_init_done
	excludes_status
	excludes "%F{$YAZPT_GIT_STATUS_NO_UPSTREAM_CHAR_COLOR}"
	excludes "%F{$YAZPT_GIT_STATUS_CLEAN_CHAR_COLOR}"

	test_case "Empty YAZPT_GIT_STATUS_UNKNOWN_CHAR"
	reset_git_status_chars
	alias git=gitx
	test_init_done
	contains "⌀"
	contains "%F{$YAZPT_GIT_STATUS_UNKNOWN_CHAR_COLOR}"
	YAZPT_GIT_STATUS_UNKNOWN_CHAR=""
	test_init_done
	excludes_status
	excludes "%F{$YAZPT_GIT_STATUS_UNKNOWN_CHAR_COLOR}"
	excludes "%F{$YAZPT_GIT_STATUS_CLEAN_CHAR_COLOR}"
	unalias git

	test_case "Empty YAZPT_GIT_STATUS_LINKED_BARE_CHAR"
	reset_git_status_chars
	rm -rf * .git .gitignore
	git clone --bare "https://github.com/jakshin/yazpt-test.git"
	cd yazpt-test.git
	git worktree add ../yazpt-linked
	cd ../yazpt-linked
	test_init_done
	contains "⚭"
	contains "%F{$YAZPT_GIT_STATUS_LINKED_BARE_CHAR_COLOR}"
	YAZPT_GIT_STATUS_LINKED_BARE_CHAR=""
	test_init_done
	excludes_status
	excludes "%F{$YAZPT_GIT_STATUS_LINKED_BARE_CHAR_COLOR}"
	excludes "%F{$YAZPT_GIT_STATUS_NO_UPSTREAM_CHAR_COLOR}"
	excludes "%F{$YAZPT_GIT_STATUS_CLEAN_CHAR_COLOR}"
}

run_tests

# Reinitialize and test again, in a linked worktree
before_linked_tests $script_name
run_tests

# Clean up
after_tests
