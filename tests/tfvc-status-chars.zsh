#!/bin/zsh
# Tests for our handling of TFVC status characters.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name "tfvc"
YAZPT_VCS_ORDER=(tfvc)

function reset_tfvc_status_chars() {
	YAZPT_VCS_STATUS_CLEAN_CHAR="●"
	YAZPT_VCS_STATUS_DIRTY_CHAR="⚑"
	YAZPT_VCS_STATUS_LOCKED_CHAR="⊠"
	YAZPT_VCS_STATUS_UNKNOWN_CHAR="⌀"
}

# Test
test_case "Empty YAZPT_VCS_STATUS_CLEAN_CHAR"
reset_tfvc_status_chars
test_init_done
contains "●"
contains "%F{$YAZPT_VCS_STATUS_CLEAN_COLOR}"
YAZPT_VCS_STATUS_CLEAN_CHAR=""
test_init_done
excludes_tfvc_status
excludes "%F{$YAZPT_VCS_STATUS_CLEAN_COLOR}"

test_case "Empty YAZPT_VCS_STATUS_DIRTY_CHAR (YAZPT_VCS_TFVC_CHECK_LOCKS=true)"
reset_tfvc_status_chars
YAZPT_VCS_TFVC_CHECK_LOCKS=true
function .yazpt_parse_pendingchanges_tf1() { _yazpt_tfvc_status=ny }
function zstat() { stat=(24) }
function .yazpt_parse_properties_tf1() {
	# Mock this function to avoid errors caused by mocking zstat
	_yazpt_server_path='$/yazpt-tfvc-test/Mock'
}
test_init_done
contains "⚑"
contains "%F{$YAZPT_VCS_STATUS_DIRTY_COLOR}"
YAZPT_VCS_STATUS_DIRTY_CHAR=""
test_init_done
excludes_tfvc_status
excludes "%F{$YAZPT_VCS_STATUS_DIRTY_COLOR}"

test_case "Empty YAZPT_VCS_STATUS_LOCKED_CHAR (YAZPT_VCS_TFVC_CHECK_LOCKS=true)"
reset_tfvc_status_chars
YAZPT_VCS_TFVC_CHECK_LOCKS=true
function .yazpt_parse_pendingchanges_tf1() { _yazpt_tfvc_status=yn }
test_init_done
contains "⊠"
contains "%F{$YAZPT_VCS_STATUS_LOCKED_COLOR}"
YAZPT_VCS_STATUS_LOCKED_CHAR=""
test_init_done
excludes_tfvc_status
excludes "%F{$YAZPT_VCS_STATUS_LOCKED_COLOR}"

test_case "Empty YAZPT_VCS_STATUS_DIRTY_CHAR (YAZPT_VCS_TFVC_CHECK_LOCKS=false)"
reset_tfvc_status_chars
YAZPT_VCS_TFVC_CHECK_LOCKS=false
unfunction .yazpt_parse_pendingchanges_tf1  # Shouldn't get called
test_init_done
contains "⚑"
contains "%F{$YAZPT_VCS_STATUS_DIRTY_COLOR}"
YAZPT_VCS_STATUS_DIRTY_CHAR=""
test_init_done
excludes_tfvc_status
excludes "%F{$YAZPT_VCS_STATUS_DIRTY_COLOR}"
excludes "%F{$YAZPT_VCS_STATUS_LOCKED_COLOR}"

test_case "Empty YAZPT_VCS_STATUS_UNKNOWN_CHAR (parse failure)"
reset_tfvc_status_chars
YAZPT_VCS_TFVC_CHECK_LOCKS=true
function .yazpt_parse_pendingchanges_tf1() { _yazpt_tfvc_status=nn }
test_init_done
contains "⌀"
contains "%F{$YAZPT_VCS_STATUS_UNKNOWN_COLOR}"
YAZPT_VCS_STATUS_UNKNOWN_CHAR=""
test_init_done
excludes_tfvc_status
excludes "%F{$YAZPT_VCS_STATUS_UNKNOWN_COLOR}"

test_case "Empty YAZPT_VCS_STATUS_UNKNOWN_CHAR (zstat failure)"
reset_tfvc_status_chars
touch "$tf_dir_name/pendingchanges.tf1"
function .yazpt_parse_pendingchanges_tf1() { _yazpt_tfvc_status=yy }  # Shouldn't get called
function zstat() { return 1 }
test_init_done
contains "⌀"
contains "%F{$YAZPT_VCS_STATUS_UNKNOWN_COLOR}"
YAZPT_VCS_STATUS_UNKNOWN_CHAR=""
test_init_done
excludes_tfvc_status
excludes "%F{$YAZPT_VCS_STATUS_UNKNOWN_COLOR}"

# Clean up
after_tests
