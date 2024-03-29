#!/bin/zsh
# Tests for locking files in a TFVC workspace.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name "tfvc"
YAZPT_VCS_ORDER=(tfvc)

# Test
test_case "With a locked file"
$tf_cli vc lock -lock:checkin lock-me.txt
YAZPT_CHECK_TFVC_LOCKS=true
test_init_done
contains_status "locked"
cd folder
test_init_done
contains_status "locked"
cd ..
YAZPT_CHECK_TFVC_LOCKS=false
test_init_done
contains_status "dirty"
cd folder
test_init_done
contains_status "dirty"
cd ..
$tf_cli vc lock -lock:none lock-me.txt
test_init_done
contains_status "clean"

# Clean up
after_tests
