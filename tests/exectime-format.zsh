#!/bin/zsh
# Tests for execution time formatting.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name

YAZPT_LAYOUT='<exectime> <cwd> <char> '
YAZPT_RLAYOUT=''

# Test
test_case "Seconds only"
test_init_done "_yazpt_cmd_exec_start=$((SECONDS - 42))"
contains "42s"

test_case "Minutes and seconds"
test_init_done "_yazpt_cmd_exec_start=$((SECONDS - 61))"
contains "1m 1s"

test_case "Minutes only"
test_init_done "_yazpt_cmd_exec_start=$((SECONDS - 120))"
contains "2m"

test_case "Hours and minutes"
test_init_done "_yazpt_cmd_exec_start=$((SECONDS - 3660))"
contains "1h 1m"

test_case "Hours only"
test_init_done "_yazpt_cmd_exec_start=$((SECONDS - 7200))"
contains "2h"

test_case "Hours and minutes and seconds"
test_init_done "_yazpt_cmd_exec_start=$((SECONDS - 3661))"
contains "1h 1m 1s"

test_case "Hours and seconds"
test_init_done "_yazpt_cmd_exec_start=$((SECONDS - 10803))"
contains "3h 3s"

# Clean up
after_tests
