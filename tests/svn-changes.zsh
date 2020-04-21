#!/bin/zsh
# Tests for various file/directory changes in a Subversion working copy.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name "svn"
YAZPT_VCS_ORDER=(svn)

# Test
test_case "Adding a directory"
mkdir new-dir
test_init_done
contains_status "dirty"
cd grandparent/parent/child
test_init_done
contains_status "dirty"
cd ../../..
svn add new-dir
test_init_done
contains_status "dirty"
cd grandparent/parent/child
test_init_done
contains_status "dirty"
cd ../../.. && svn revert new-dir && rmdir new-dir
test_init_done
contains_status "clean"

test_case "Adding a directory (svn mkdir)"
svn mkdir new-dir
test_init_done
contains_status "dirty"
cd grandparent/parent/child
test_init_done
contains_status "dirty"
cd ../../.. && svn revert new-dir && rmdir new-dir
test_init_done
contains_status "clean"

test_case "Adding an ignored directory"
mkdir ignored-dir
test_init_done
contains_status "clean"
cd grandparent/parent/child
test_init_done
contains_status "clean"

test_case "Adding a file"
touch new-file.txt
test_init_done
contains_status "dirty"
cd grandparent/parent/child
test_init_done
contains_status "dirty"
cd ../../..
svn add new-file.txt
test_init_done
contains_status "dirty"
cd grandparent/parent/child
test_init_done
contains_status "dirty"
cd ../../.. && svn revert new-file.txt && rm -f new-file.txt
test_init_done
contains_status "clean"

test_case "Adding an ignored file"
touch ignored.txt
test_init_done
contains_status "clean"
cd grandparent/parent/child
test_init_done
contains_status "clean"

test_case "Changing a file"
echo "blah" >> foobar.txt
test_init_done
contains_status "dirty"
cd grandparent/parent/child
test_init_done
contains_status "dirty"
cd ../../.. && svn revert foobar.txt
test_init_done
contains_status "clean"

test_case "Renaming a file"
mv foobar.txt foobaz.txt
test_init_done
contains_status "dirty"
cd grandparent/parent/child
test_init_done
contains_status "dirty"
cd ../../.. && mv foobaz.txt foobar.txt
test_init_done
contains_status "clean"

test_case "Renaming a file (svn rename)"
svn rename foobar.txt foobaz.txt
test_init_done
contains_status "dirty"
cd grandparent/parent/child
test_init_done
contains_status "dirty"
cd ../../.. && svn revert foobar.txt && svn revert foobaz.txt
test_init_done
contains_status "clean"

test_case "Copying a file"
cp foobar.txt foobaz.txt
test_init_done
contains_status "dirty"
cd grandparent/parent/child
test_init_done
contains_status "dirty"
cd ../../.. && rm -f foobaz.txt
test_init_done
contains_status "clean"

test_case "Copying a file (svn copy)"
svn copy foobar.txt foobaz.txt
test_init_done
contains_status "dirty"
cd grandparent/parent/child
test_init_done
contains_status "dirty"
cd ../../.. && svn revert foobaz.txt
test_init_done
contains_status "clean"

test_case "Deleting a file"
rm foobar.txt
test_init_done
contains_status "dirty"
cd grandparent/parent/child
test_init_done
contains_status "dirty"
cd ../../.. && svn revert foobar.txt
test_init_done
contains_status "clean"

test_case "Deleting a file (svn delete)"
svn delete foobar.txt
test_init_done
contains_status "dirty"
cd grandparent/parent/child
test_init_done
contains_status "dirty"
cd ../../.. && svn revert foobar.txt
test_init_done
contains_status "clean"

# Clean up
after_tests
