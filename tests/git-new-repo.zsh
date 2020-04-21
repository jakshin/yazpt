#!/bin/zsh
# Tests for new Git repos with no commits.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name
YAZPT_VCS_ORDER=(git)

# Test
test_case "New repo with no branches/commits"
git init
test_init_done
contains_context "master"
contains_status "no-upstream"

test_case "In the .git directory of a new repo with no branches/commits"
cd $(git rev-parse --git-dir)
test_init_done
contains_dim_context "master"
contains_status "no-upstream"
contains "IN-GIT-DIR"

# Clean up
after_tests
