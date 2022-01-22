#!/bin/zsh
# Tests for Git settings (via environment variables).

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name "git"
YAZPT_VCS_ORDER=(git)

function git_mock() {
	if [[ $1 == "status" ]]; then
		return 1
	else
		command git "$@"
	fi
}

# Test
test_case "Git context color"
YAZPT_VCS_CONTEXT_COLOR=1
YAZPT_VCS_CONTEXT_META_COLOR=2
YAZPT_VCS_CONTEXT_IGNORED_COLOR=3
test_init_done
contains '%{%F{1}%}main%{%f%}'
cd $(git rev-parse --git-dir)
test_init_done
contains '%{%F{2}%}main|IN-GIT-DIR%{%f%}'
mkdir ../ignored
cd ../ignored
test_init_done
contains '%{%F{3}%}main|IGNORED%{%f%}'

test_case "Git status = clean"
YAZPT_VCS_STATUS_CLEAN_CHAR="★"
YAZPT_VCS_STATUS_CLEAN_COLOR=17
test_init_done
contains '%{%F{17}%}★%{%f%}'

test_case "Git status = dirty"
YAZPT_VCS_STATUS_DIRTY_CHAR="☆"
YAZPT_VCS_STATUS_DIRTY_COLOR=18
touch new-file
test_init_done
contains '%{%F{18}%}☆%{%f%}'

test_case "Git status = diverged"
YAZPT_VCS_STATUS_DIVERGED_CHAR="✪"
YAZPT_VCS_STATUS_DIVERGED_COLOR=19
git add . && git commit -m "new file"
test_init_done
contains '%{%F{19}%}✪%{%f%}'

test_case "Git status = no remote/upstream branch"
YAZPT_VCS_STATUS_NO_UPSTREAM_CHAR="✡︎"
YAZPT_VCS_STATUS_NO_UPSTREAM_COLOR=20
git checkout -b new-branch
test_init_done
contains '%{%F{20}%}✡︎%{%f%}'

test_case "Git status = unknown ('git status' failed)"
YAZPT_VCS_STATUS_UNKNOWN_CHAR="✣"
YAZPT_VCS_STATUS_UNKNOWN_COLOR=21
alias git=git_mock
test_init_done
contains '%{%F{21}%}✣%{%f%}'
unalias git

# Clean up
after_tests
