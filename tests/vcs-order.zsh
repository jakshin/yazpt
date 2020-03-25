#!/bin/zsh
# Tests for VCS checks and ordering.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name

function reset_tracking() {
	git_call_count=0
	svn_call_count=0
	git_call_time=-1
	svn_call_time=-1
}

function @yazpt_segment_git() {
	(( git_call_count++ ))
	git_call_time=$(current_timestamp)
}

function @yazpt_segment_svn() {
	(( svn_call_count++ ))
	svn_call_time=$(current_timestamp)
}

# Test
test_case '$YAZPT_VCS_ORDER is empty'
YAZPT_VCS_ORDER=()
reset_tracking
test_init_done "no-standard-tests"
equals git_call_count $git_call_count 0
equals svn_call_count $svn_call_count 0

test_case '$YAZPT_VCS_ORDER contains only git'
YAZPT_VCS_ORDER=(git)
reset_tracking
test_init_done "no-standard-tests"
equals git_call_count $git_call_count 1
equals svn_call_count $svn_call_count 0

test_case '$YAZPT_VCS_ORDER contains only svn'
YAZPT_VCS_ORDER=(svn)
reset_tracking
test_init_done "no-standard-tests"
equals git_call_count $git_call_count 0
equals svn_call_count $svn_call_count 1

test_case '$YAZPT_VCS_ORDER contains git & svn'
YAZPT_VCS_ORDER=(git svn)
reset_tracking
test_init_done "no-standard-tests"
equals git_call_count $git_call_count 1
equals svn_call_count $svn_call_count 1
first_is_less git_call_time $git_call_time svn_call_time $svn_call_time

test_case '$YAZPT_VCS_ORDER contains svn & git'
YAZPT_VCS_ORDER=(svn git)
reset_tracking
test_init_done "no-standard-tests"
equals git_call_count $git_call_count 1
equals svn_call_count $svn_call_count 1
first_is_less svn_call_time $svn_call_time git_call_time $git_call_time

# Clean up
after_tests
