#!/bin/zsh
# Tests for bare git repos.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name

# Test
test_case "New bare repo with no branches/commits"
mkdir "bare"
cd "bare"
git init --bare
test_init_done
contains_dim_branch "BARE-REPO"
excludes "master"
excludes_status

test_case "Cloned bare repo"
git clone --bare "https://github.com/jakshin/yazpt-test.git"
cd "yazpt-test.git"
test_init_done
contains_dim_branch "BARE-REPO"
excludes "master"
excludes_status
YAZPT_GIT_HIDE_IN_BARE_REPO=true
test_init_done
excludes "BARE-REPO"
excludes "master"
excludes_status

# Clean up
after_tests
