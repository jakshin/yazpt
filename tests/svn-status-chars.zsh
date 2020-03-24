#!/bin/zsh
# Tests for our handling of Subversion status characters.

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

# Test
test_case "Empty YAZPT_VCS_STATUS_CLEAN_CHAR"
reset_svn_status_chars
test_init_done
contains "●"
contains "%F{$YAZPT_VCS_STATUS_CLEAN_COLOR}"
YAZPT_VCS_STATUS_CLEAN_CHAR=""
test_init_done
excludes_svn_status
excludes "%F{$YAZPT_VCS_STATUS_CLEAN_COLOR}"

test_case "Empty YAZPT_VCS_STATUS_DIRTY_CHAR"
reset_svn_status_chars
touch new-file.txt
test_init_done
contains "⚑"
contains "%F{$YAZPT_VCS_STATUS_DIRTY_COLOR}"
YAZPT_VCS_STATUS_DIRTY_CHAR=""
test_init_done
excludes_svn_status
excludes "%F{$YAZPT_VCS_STATUS_DIRTY_COLOR}"
excludes "%F{$YAZPT_VCS_STATUS_CLEAN_COLOR}"
rm -f new-file.txt

test_case "Empty YAZPT_VCS_STATUS_LOCKED_CHAR"
reset_svn_status_chars
alias svn=svn_mock_locked
test_init_done
contains "⊠"
contains "%F{$YAZPT_VCS_STATUS_LOCKED_COLOR}"
YAZPT_VCS_STATUS_LOCKED_CHAR=""
test_init_done
excludes_svn_status
excludes "%F{$YAZPT_VCS_STATUS_LOCKED_COLOR}"
excludes "%F{$YAZPT_VCS_STATUS_CLEAN_COLOR}"
unalias svn

test_case "Empty YAZPT_VCS_STATUS_CONFLICT_CHAR"
reset_svn_status_chars
alias svn=svn_mock_conflict
test_init_done
contains "≠"
contains "%F{$YAZPT_VCS_STATUS_CONFLICT_COLOR}"
YAZPT_VCS_STATUS_CONFLICT_CHAR=""
test_init_done
excludes_svn_status
excludes "%F{$YAZPT_VCS_STATUS_CONFLICT_COLOR}"
excludes "%F{$YAZPT_VCS_STATUS_CLEAN_COLOR}"
unalias svn

test_case "Empty YAZPT_VCS_STATUS_UNKNOWN_CHAR"
reset_svn_status_chars
alias svn=svn_mock_error
test_init_done
contains "⌀"
contains "%F{$YAZPT_VCS_STATUS_UNKNOWN_COLOR}"
YAZPT_VCS_STATUS_UNKNOWN_CHAR=""
test_init_done
excludes_svn_status
excludes "%F{$YAZPT_VCS_STATUS_UNKNOWN_COLOR}"
excludes "%F{$YAZPT_VCS_STATUS_CLEAN_COLOR}"
unalias svn

# Clean up
after_tests
