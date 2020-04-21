#!/bin/zsh
# Tests for clean state in a TFVC workspace.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name "tfvc"
YAZPT_VCS_ORDER=(tfvc)

# Test
test_case "With no pendingchanges.tf1"
rm -f "$tf_dir_name/pendingchanges.tf1"
test_init_done
contains_status "clean"
cd $tf_dir_name
test_init_done
contains_status "clean"
contains "|IN-TF-DIR"
cd ../folder
test_init_done
contains_status "clean"

test_case "With an empty pendingchanges.tf1"
touch "$tf_dir_name/pendingchanges.tf1"
test_init_done
contains_status "clean"
cd $tf_dir_name
test_init_done
contains_status "clean"
contains "|IN-TF-DIR"
cd ../folder
test_init_done
contains_status "clean"

test_case "With a 23-byte pendingchanges.tf1"
rm -f "$tf_dir_name/pendingchanges.tf1"
touch foo && tf_status
rm -f foo && tf_status
ls -l "$tf_dir_name/pendingchanges.tf1"
test_init_done
contains_status "clean"
cd $tf_dir_name
test_init_done
contains_status "clean"
contains "|IN-TF-DIR"
cd ../folder
test_init_done
contains_status "clean"

# Clean up
after_tests
