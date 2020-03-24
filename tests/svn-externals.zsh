#!/bin/zsh
# Tests for externals in a Subversion working copy.
# http://svnbook.red-bean.com/en/1.7/svn.advanced.externals.html

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name "svn"
YAZPT_VCS_ORDER=(svn)

# Test
test_case "The external's branch is independent from the working copy's"
test_init_done
contains_branch "trunk"
cd yazpt-svn-ext
test_init_done
contains_branch "v1"

test_case "The external's status is independent from the working copy's"
svn lock lock-me.txt --force
test_init_done
contains_status "locked"
cd yazpt-svn-ext
test_init_done
contains_status "clean"
touch file3.txt
test_init_done
contains_status "dirty"
excludes $YAZPT_VCS_STATUS_LOCKED_CHAR
excludes $YAZPT_VCS_STATUS_LOCKED_COLOR
cd ..
test_init_done
contains_status "locked"
excludes $YAZPT_VCS_STATUS_DIRTY_CHAR
excludes $YAZPT_VCS_STATUS_DIRTY_COLOR
svn unlock lock-me.txt

# Clean up
after_tests
