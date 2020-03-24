#!/bin/zsh
# Tests for running 'svn switch' in a Subversion working copy's subdirectory.
# http://svnbook.red-bean.com/en/1.7/svn.ref.svn.c.switch.html
#
# I never do this in real life - if I ever do, I expect it to be a brief arrangement,
# and I just want the status to be dirty (or some other flag) to remind me I did it.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name "svn"
YAZPT_VCS_ORDER=(svn)

# Test
test_case "Switching a subdirectory makes the working copy dirty"
test_init_done
contains_status "clean"  # Sanity check
cd grandparent
svn switch "^/branches/branch1/grandparent"
test_init_done
contains_branch "branch1"
contains_status "dirty"
cd ..
test_init_done
contains_branch "trunk"
contains_status "dirty"

# Clean up
after_tests
