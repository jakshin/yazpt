#!/bin/zsh
# Tests for settings (via environment variables).

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name true

function gitx {
	if [[ $1 == "status" ]]; then
		return 1
	else
		command git "$@"
	fi
}

# Test
test_case "Current working directory color"
YAZPT_CWD_COLOR=5
test_init_done
contains '%{%F{5}%}%~%{%f%}'

test_case "Git branch color"
YAZPT_GIT_BRANCH_COLOR=1
YAZPT_GIT_BRANCH_GIT_DIR_COLOR=2
YAZPT_GIT_BRANCH_IGNORED_DIR_COLOR=3
test_init_done
contains '%{%F{1}%}master%{%f%}'
cd .git
test_init_done
contains '%{%F{2}%}master|IN-GIT-DIR%{%f%}'
mkdir ../ignored
cd ../ignored
test_init_done
contains '%{%F{3}%}master|IGNORED%{%f%}'

test_case "Git status = clean"
YAZPT_GIT_STATUS_CLEAN_CHAR="★"
YAZPT_GIT_STATUS_CLEAN_CHAR_COLOR=17
test_init_done
contains '%{%F{17}%}★%{%f%}'

test_case "Git status = dirty"
YAZPT_GIT_STATUS_DIRTY_CHAR="☆"
YAZPT_GIT_STATUS_DIRTY_CHAR_COLOR=18
touch new-file
test_init_done
contains '%{%F{18}%}☆%{%f%}'

test_case "Git status = diverged"
YAZPT_GIT_STATUS_DIVERGED_CHAR="✪"
YAZPT_GIT_STATUS_DIVERGED_CHAR_COLOR=19
git add . && git commit -m "new file"
test_init_done
contains '%{%F{19}%}✪%{%f%}'

test_case "Git status = no remote/upstream branch"
YAZPT_GIT_STATUS_NO_UPSTREAM_CHAR="✡︎"
YAZPT_GIT_STATUS_NO_UPSTREAM_CHAR_COLOR=20
git checkout -b new-branch
test_init_done
contains '%{%F{20}%}✡︎%{%f%}'

test_case "Git status = unknown ('git status' failed)"
YAZPT_GIT_STATUS_UNKNOWN_CHAR="✣"
YAZPT_GIT_STATUS_UNKNOWN_CHAR_COLOR=21
alias git=gitx
test_init_done
contains '%{%F{21}%}✣%{%f%}'
unalias git

test_case "Command result = error"
YAZPT_RESULT_ERROR_CHAR="✦"
YAZPT_RESULT_ERROR_CHAR_COLOR=9
YAZPT_RESULT_ERROR_CODE_COLOR=13
YAZPT_RESULT_ERROR_CODE_VISIBLE=true
test_init_done "(exit 42)"
contains '%{%F{9}%}✦%{%f%}'
contains '%{%F{13}%}42%{%f%}'
YAZPT_RESULT_ERROR_CHAR=""
test_init_done "(exit 42)"
excludes '%F{9}'
excludes '✘'
contains '%{%F{13}%}42%{%f%}'
YAZPT_RESULT_ERROR_CHAR="✦"
YAZPT_RESULT_ERROR_CODE_VISIBLE=false
test_init_done "(exit 42)"
contains '%{%F{9}%}✦%{%f%}'
excludes '%F{13}'
excludes '42'

test_case "Command result = success"
YAZPT_RESULT_OK_CHAR="✧"
YAZPT_RESULT_OK_CHAR_COLOR=10
YAZPT_RESULT_OK_CODE_COLOR=14
YAZPT_RESULT_OK_CODE_VISIBLE=true
test_init_done "true"
contains '%{%F{10}%}✧%{%f%}'
contains '%{%F{14}%}0%{%f%}'
YAZPT_RESULT_OK_CHAR=""
test_init_done "true"
excludes '%F{10}'
contains '%{%F{14}%}0%{%f%}'
YAZPT_RESULT_OK_CHAR="✧"
YAZPT_RESULT_OK_CODE_VISIBLE=false
test_init_done "true"
contains '%{%F{10}%}✧%{%f%}'
excludes '%F{14}'

# Clean up
after_tests
