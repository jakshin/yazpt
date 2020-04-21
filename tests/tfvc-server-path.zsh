#!/bin/zsh
# Tests for server path display in a TFVC workspace.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name "tfvc"
YAZPT_VCS_ORDER=(tfvc)

# Test
test_case "In the workspace's root folder"
test_init_done
contains_context '$/yazpt-tfvc-test/Main'

test_case 'In the $tf (or .tf) folder'
cd $tf_dir_name
test_init_done
contains_dim_context '$/yazpt-tfvc-test/Main'
contains "|IN-TF-DIR"

test_case "In a folder"
cd folder
test_init_done
contains_context '$/yazpt-tfvc-test/Main'

test_case "In an ignored folder"  # No special behavior
mkdir -p ignored-folder
cd ignored-folder
test_init_done
contains_context '$/yazpt-tfvc-test/Main'

# Clean up
after_tests
