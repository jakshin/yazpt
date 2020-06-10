#!/bin/zsh
# Tests for VCS behavior settings (via environment variables handled in the default preset).
# We're just testing handling of the variables here, not the actual behaviors.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name

# Test
test_case "Environment variables are unset"
unset YAZPT_VCS_ORDER
unset YAZPT_GIT_PATHS
unset YAZPT_SVN_PATHS
unset YAZPT_TFVC_PATHS
unset YAZPT_CHECK_TFVC_LOCKS
yazpt_load_preset default
test_init_done
equals "YAZPT_VCS_ORDER" "$YAZPT_VCS_ORDER" "git"
equals "YAZPT_VCS_ORDER's type" "${(t)YAZPT_VCS_ORDER}" "array"
equals "YAZPT_GIT_PATHS" "$YAZPT_GIT_PATHS" ""
equals "YAZPT_GIT_PATHS's type" "${(t)YAZPT_GIT_PATHS}" "array"
equals "YAZPT_SVN_PATHS" "$YAZPT_SVN_PATHS" ""
equals "YAZPT_SVN_PATHS's type" "${(t)YAZPT_SVN_PATHS}" "array"
equals "YAZPT_TFVC_PATHS" "$YAZPT_TFVC_PATHS" ""
equals "YAZPT_TFVC_PATHS's type" "${(t)YAZPT_TFVC_PATHS}" "array"
equals "YAZPT_CHECK_TFVC_LOCKS" "$YAZPT_CHECK_TFVC_LOCKS" true
equals "YAZPT_CHECK_TFVC_LOCKS's type" "${(t)YAZPT_CHECK_TFVC_LOCKS}" "scalar"

test_case "Environment variables are set to empty values"
YAZPT_VCS_ORDER=""
YAZPT_GIT_PATHS=""
YAZPT_SVN_PATHS=""
YAZPT_TFVC_PATHS=""
YAZPT_CHECK_TFVC_LOCKS=""
yazpt_load_preset default
test_init_done
equals "YAZPT_VCS_ORDER" "$YAZPT_VCS_ORDER" ""
equals "YAZPT_VCS_ORDER's type" "${(t)YAZPT_VCS_ORDER}" "array"
equals "YAZPT_GIT_PATHS" "$YAZPT_GIT_PATHS" ""
equals "YAZPT_GIT_PATHS's type" "${(t)YAZPT_GIT_PATHS}" "array"
equals "YAZPT_SVN_PATHS" "$YAZPT_SVN_PATHS" ""
equals "YAZPT_SVN_PATHS's type" "${(t)YAZPT_SVN_PATHS}" "array"
equals "YAZPT_TFVC_PATHS" "$YAZPT_TFVC_PATHS" ""
equals "YAZPT_TFVC_PATHS's type" "${(t)YAZPT_TFVC_PATHS}" "array"
equals "YAZPT_CHECK_TFVC_LOCKS" "$YAZPT_CHECK_TFVC_LOCKS" ""
equals "YAZPT_CHECK_TFVC_LOCKS's type" "${(t)YAZPT_CHECK_TFVC_LOCKS}" "scalar"

test_case "Environment variables are set to realistic values"
YAZPT_VCS_ORDER=(svn git)
YAZPT_GIT_PATHS=(~/git "Linus's second big hit")
YAZPT_SVN_PATHS=(~/svn "ess vee en")
YAZPT_TFVC_PATHS=()
YAZPT_CHECK_TFVC_LOCKS=false
yazpt_load_preset default
test_init_done
equals "YAZPT_VCS_ORDER" "$YAZPT_VCS_ORDER" "svn git"
equals "YAZPT_VCS_ORDER's type" "${(t)YAZPT_VCS_ORDER}" "array"
equals "YAZPT_VCS_ORDER's size" "${#YAZPT_VCS_ORDER}" 2
equals "YAZPT_GIT_PATHS" "$YAZPT_GIT_PATHS" ~/"git Linus's second big hit"
equals "YAZPT_GIT_PATHS's type" "${(t)YAZPT_GIT_PATHS}" "array"
equals "YAZPT_GIT_PATHS's size" "${#YAZPT_GIT_PATHS}" 2
equals "YAZPT_SVN_PATHS" "$YAZPT_SVN_PATHS" ~/"svn ess vee en"
equals "YAZPT_SVN_PATHS's type" "${(t)YAZPT_SVN_PATHS}" "array"
equals "YAZPT_SVN_PATHS's size" "${#YAZPT_SVN_PATHS}" 2
equals "YAZPT_TFVC_PATHS" "$YAZPT_TFVC_PATHS" ""
equals "YAZPT_TFVC_PATHS's type" "${(t)YAZPT_TFVC_PATHS}" "array"
equals "YAZPT_TFVC_PATHS's size" "${#YAZPT_TFVC_PATHS}" 0
equals "YAZPT_CHECK_TFVC_LOCKS" "$YAZPT_CHECK_TFVC_LOCKS" false
equals "YAZPT_CHECK_TFVC_LOCKS's type" "${(t)YAZPT_CHECK_TFVC_LOCKS}" "scalar"

# Clean up
after_tests
