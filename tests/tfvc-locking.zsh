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
$tf_cli lock ${=tf_args} -lock:checkin lock-me.txt
YAZPT_VCS_TFVC_CHECK_LOCKS=true
test_init_done
contains_status "locked"
cd folder
test_init_done
contains_status "locked"
cd ..
YAZPT_VCS_TFVC_CHECK_LOCKS=false
test_init_done
contains_status "dirty"
cd folder
test_init_done
contains_status "dirty"
cd ..
$tf_cli lock ${=tf_args} -lock:none lock-me.txt
test_init_done
contains_status "clean"

# Clean up
after_tests
