#!/bin/zsh
# Tests for bare Git repos.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name
YAZPT_VCS_ORDER=(git)

# Test
test_case "New bare repo with no branches/commits"
mkdir "bare"
cd "bare"
git init --bare
test_init_done
contains_dim_context "BARE-REPO"
excludes "master"
excludes_git_status

test_case "Cloned bare repo"
git clone --bare "https://github.com/jakshin/yazpt-test.git"
cd "yazpt-test.git"
test_init_done
contains_dim_context "BARE-REPO"
excludes "master"
excludes_git_status

# Clean up
after_tests
