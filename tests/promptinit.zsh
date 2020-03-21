#!/bin/zsh
# Tests for yazpt's integration with zsh's prompt theme system.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
test_dir="$(pwd -P)"
source ./utils.zsh
before_tests $script_name

autoload -U promptinit && promptinit
default_ps1='%n@%m %1~ %# '
default_yazpt_ps1='[%{%F{73}%}%~%{%f%}]%# '
jakshin_yazpt_ps1='[%{%F{226}%}%~%{%f%}]%# '

# Test
function run_test_variant_1() {
	prompt yazpt
	test_init_done "no-standard-tests"
	is $default_yazpt_ps1
	has_one_precmd_function

	yazpt_load_preset jakshin
	test_init_done "no-standard-tests"
	is $jakshin_yazpt_ps1
	has_one_precmd_function

	prompt -h yazpt > /dev/null
	test_init_done "no-standard-tests"
	is $jakshin_yazpt_ps1
	has_one_precmd_function

	prompt -p "yazpt blues" > /dev/null
	test_init_done "no-standard-tests"
	is $jakshin_yazpt_ps1
	has_one_precmd_function
}

function run_test_variant_2() {
	prompt yazpt
	test_init_done "no-standard-tests"
	is $default_yazpt_ps1
	has_one_precmd_function

	yazpt_load_preset jakshin
	test_init_done "no-standard-tests"
	is $jakshin_yazpt_ps1
	has_one_precmd_function

	prompt -p "yazpt blues" > /dev/null
	test_init_done "no-standard-tests"
	is $jakshin_yazpt_ps1
	has_one_precmd_function

	prompt -h yazpt > /dev/null
	test_init_done "no-standard-tests"
	is $jakshin_yazpt_ps1
	has_one_precmd_function
}

function run_test_variant_3() {
	prompt -h yazpt > /dev/null
	is $default_ps1
	has_no_precmd_function

	prompt yazpt jakshin
	test_init_done "no-standard-tests"
	is $jakshin_yazpt_ps1
	has_one_precmd_function

	prompt -p "yazpt blues" > /dev/null
	test_init_done "no-standard-tests"
	is $jakshin_yazpt_ps1
	has_one_precmd_function
}

function run_test_variant_4() {
	prompt -h yazpt > /dev/null
	prompt -p "yazpt all" > /dev/null
	is $default_ps1
	has_no_precmd_function

	prompt yazpt
	test_init_done "no-standard-tests"
	is $default_yazpt_ps1
	has_one_precmd_function

	prompt yazpt jakshin
	test_init_done "no-standard-tests"
	is $jakshin_yazpt_ps1
	has_one_precmd_function
}

function run_test_variant_5() {
	prompt -p "yazpt blues" > /dev/null
	is $default_ps1
	has_no_precmd_function

	prompt yazpt
	yazpt_load_preset jakshin
	test_init_done "no-standard-tests"
	is $jakshin_yazpt_ps1
	has_one_precmd_function

	prompt -h yazpt > /dev/null
	test_init_done "no-standard-tests"
	is $jakshin_yazpt_ps1
	has_one_precmd_function
}

test_case "Integration with promptinit"
for i in {1..5}; do
	yazpt_plugin_unload
	run_test_variant_$i
done

test_case "Integration with promptinit (yazpt loaded beforehand)"
for i in {1..5}; do
	yazpt_plugin_unload
	source "$test_dir/../yazpt.zsh-theme"
	run_test_variant_$i
done

test_case "Integration with promptinit (yazpt loaded beforehand, with preset)"
for i in {1..5}; do
	yazpt_plugin_unload
	source "$test_dir/../yazpt.zsh-theme"
	yazpt_load_preset spearmint
	run_test_variant_$i
done

# Clean up
after_tests
