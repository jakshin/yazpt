#!/bin/zsh
# Tests for locking files in a Subversion working copy.
# http://svnbook.red-bean.com/en/1.7/svn.advanced.locking.html

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name "svn"
YAZPT_VCS_ORDER=(svn)

# Test
test_case "With a locked file"
svn lock lock-me.txt --force
test_init_done
contains_status "locked"
cd grandparent/parent/child
test_init_done
contains_status "locked"
cd ../../.. && svn unlock lock-me.txt

# Clean up
after_tests
