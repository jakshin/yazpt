#!/bin/zsh
# Tests for Subversion settings (via environment variables).

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name "svn"
YAZPT_VCS_ORDER=(svn)

function svn_mock_error() {
	if [[ $1 == "status" ]]; then
		return 1
	else
		command svn "$@"
	fi
}

function svn_mock_conflict() {
	if [[ $1 == "status" ]]; then
		#     1234567 filename
		echo 'CC    C dummy'
	else
		command svn "$@"
	fi
}

function svn_mock_locked() {
	if [[ $1 == "status" ]]; then
		#     1234567 filename
		echo '     K  dummy'
	else
		command svn "$@"
	fi
}

# Test
test_case "Subversion context color"
YAZPT_VCS_CONTEXT_COLOR=1
YAZPT_VCS_CONTEXT_META_COLOR=2
YAZPT_VCS_CONTEXT_UNVERSIONED_COLOR=3
test_init_done
contains '%{%F{1}%}trunk%{%f%}'
cd .svn
test_init_done
contains '%{%F{2}%}trunk|IN-SVN-DIR%{%f%}'
mkdir ../ignored-dir
cd ../ignored-dir
test_init_done
contains '%{%F{3}%}trunk|UNVERSIONED%{%f%}'
mkdir ../new-dir
cd ../new-dir
test_init_done
contains '%{%F{3}%}trunk|UNVERSIONED%{%f%}'
cd .. && rmdir new-dir

test_case "Subversion status = clean"
YAZPT_VCS_STATUS_CLEAN_CHAR="★"
YAZPT_VCS_STATUS_CLEAN_COLOR=17
test_init_done
contains '%{%F{17}%}★%{%f%}'

test_case "Subversion status = dirty"
YAZPT_VCS_STATUS_DIRTY_CHAR="☆"
YAZPT_VCS_STATUS_DIRTY_COLOR=18
touch new-file
test_init_done
contains '%{%F{18}%}☆%{%f%}'
rm -f new-file

test_case "Subversion status = locked"
YAZPT_VCS_STATUS_LOCKED_CHAR="✪"
YAZPT_VCS_STATUS_LOCKED_COLOR=19
alias svn=svn_mock_locked
test_init_done
contains '%{%F{19}%}✪%{%f%}'
unalias svn

test_case "Subversion status = conflict"
YAZPT_VCS_STATUS_CONFLICT_CHAR="✡︎"
YAZPT_VCS_STATUS_CONFLICT_COLOR=20
alias svn=svn_mock_conflict
test_init_done
contains '%{%F{20}%}✡︎%{%f%}'
unalias svn

test_case "Subversion status = unknown ('svn status' failed)"
YAZPT_VCS_STATUS_UNKNOWN_CHAR="✣"
YAZPT_VCS_STATUS_UNKNOWN_COLOR=21
alias svn=svn_mock_error
test_init_done
contains '%{%F{21}%}✣%{%f%}'
unalias svn

# Clean up
after_tests
