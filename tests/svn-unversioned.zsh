#!/bin/zsh
# Tests for unversioned/ignored items in a Subversion working copy.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name "svn"
YAZPT_VCS_ORDER=(svn)

# Test
test_case "With an ignored file"
echo "This will be ignored" > ignored.txt
test_init_done
contains_status "clean"

test_case "With an ignored directory"
mkdir ignored-dir
test_init_done
contains_status "clean"

test_case "With a new file in an ignored directory"
echo "Subversion don't care" > ignored-dir/new-file.txt
test_init_done
contains_status "clean"

test_case "In an ignored directory"
cd ignored-dir
test_init_done
contains_dim_branch "trunk"
contains "|UNVERSIONED"
contains_status "clean"
mkdir subdir && cd subdir
contains_dim_branch "trunk"
contains "|UNVERSIONED"
contains_status "clean"

test_case "In an unversioned directory, with a tricky .svn subdirectory"
mkdir -p unversioned-dir/.svn/subdir
mkdir -p unversioned-dir/sibling-dir
test_init_done
contains_status "dirty"  # Sanity check
cd unversioned-dir
test_init_done
contains_dim_branch "trunk"
contains "|UNVERSIONED"
contains_status "dirty"
cd .svn
test_init_done
contains_dim_branch "trunk"
contains "|UNVERSIONED"
contains_status "dirty"
cd subdir
test_init_done
contains_dim_branch "trunk"
contains "|UNVERSIONED"
contains_status "dirty"
cd ../../sibling-dir
test_init_done
contains_dim_branch "trunk"
contains "|UNVERSIONED"
contains_status "dirty"
cd ../.. && rm -rf unversioned-dir

test_case "In the .svn directory"
cd .svn
test_init_done
contains_dim_branch "trunk"
contains "|IN-SVN-DIR"
contains_status "clean"
cd pristine
test_init_done
contains_dim_branch "trunk"
contains "|IN-SVN-DIR"
contains_status "clean"

# Clean up
after_tests
