#!/bin/zsh
# Tests for property changes in a Subversion working copy.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name "svn"
YAZPT_VCS_ORDER=(svn)

# Test
test_case "Adding a property"
svn propset "yazpt:test2" "TEST 2" property.txt
test_init_done
contains_status "dirty"
svn revert property.txt
test_init_done
contains_status "clean"

test_case "Changing a property"
svn propset "yazpt:test1" "blah" property.txt
test_init_done
contains_status "dirty"
svn revert property.txt
test_init_done
contains_status "clean"

test_case "Deleting a property"
svn propdel "yazpt:test1" property.txt
test_init_done
contains_status "dirty"
svn revert property.txt
test_init_done
contains_status "clean"

# Clean up
after_tests
