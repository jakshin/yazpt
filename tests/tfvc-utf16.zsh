#!/bin/zsh
# Tests for conversion of UTF-16 in a TFVC workspace's server path.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name "tfvc-winky"
YAZPT_VCS_ORDER=(tfvc)

# Test
test_case "With non-English characters and emoji in the branch name"
test_init_done
contains_context '$/yazpt-tfvc-test/Wîñky-ßränçh 😉' true
cd $tf_dir_name
test_init_done
contains_dim_context '$/yazpt-tfvc-test/Wîñky-ßränçh 😉' true
contains "|IN-TF-DIR"

# Clean up
after_tests
