#!/bin/zsh
# Tests for conflicts in a Subversion working copy.
# http://svnbook.red-bean.com/en/1.7/svn.tour.cycle.html#svn.tour.cycle.examine.status

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name
YAZPT_VCS_ORDER=(svn)

function init_working_copy() {
	local target_wc_dir=$1
	rm -rf $target_wc_dir
	mkdir -p $target_wc_dir
	svn checkout "https://svn.riouxsvn.com/yazpt-svn-test/trunk" $target_wc_dir
}

function edit_file() {
	local target_wc_dir=$1
	local commit=$2
	cd $target_wc_dir
	echo "This file is for testing conflicts $(current_timestamp)" > conflict.txt
	[[ $commit == true ]] && svn commit -m "Changing conflict.txt for testing"
	cd ..
}

function edit_properties() {
	local target_wc_dir=$1
	local commit=$2
	cd $target_wc_dir
	svn propset testprop "$(current_timestamp)" conflict.txt
	[[ $commit == true ]] && svn commit -m "Changing conflict.txt's properties for testing"
	cd ..
}

function edit_tree() {
	local target_wc_dir=$1
	local commit=$2
	cd $target_wc_dir
	local old_name=$(echo conflict-dir-*)
	local new_name="conflict-dir-$(current_timestamp)"
	local new_name="conflict-dir-$(current_timestamp)"
	svn rename $old_name $new_name
	[[ $commit == true ]] && svn commit -m "Renaming directory to test tree conflicts"
	cd ..
}

# Test
test_case "With a file conflict"
init_working_copy baseline
edit_file baseline false
init_working_copy conflicter
edit_file conflicter true
cd baseline
svn update --accept postpone
test_init_done
contains_status "conflict"
cd grandparent/parent/child
test_init_done
contains_status "conflict"

test_case "With a properties conflict"
init_working_copy baseline
edit_properties baseline false
edit_properties conflicter true
cd baseline
svn update --accept postpone
test_init_done
contains_status "conflict"
cd grandparent/parent/child
test_init_done
contains_status "conflict"

test_case "With a tree conflict"
init_working_copy baseline
edit_tree baseline false
edit_tree conflicter true
cd baseline
svn update --accept postpone
test_init_done
contains_status "conflict"
cd grandparent/parent/child
test_init_done
contains_status "conflict"

# Clean up
after_tests
