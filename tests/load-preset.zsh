#!/bin/zsh
# Tests for loading presets.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name

typeset +r yazpt_base_dir
yazpt_base_dir=${${(%):-%x}:A:h}

mkdir -p presets
echo "yazpt_dummy=dummy" > presets/dummy-preset.zsh
echo "yazpt_dummy=dummy2" > dummy2.zsh
ln -sv dummy2.zsh dummy-link

# Test
test_case "Preset name"
unset yazpt_dummy return_code
yazpt_load_preset dummy
return_code=$?
test_init_done
equals yazpt_dummy $yazpt_dummy "dummy"
equals return_code $return_code "0"

test_case "Relative path to preset file"
unset yazpt_dummy return_code
yazpt_load_preset "./dummy2.zsh"
return_code=$?
test_init_done
equals yazpt_dummy $yazpt_dummy "dummy2"
equals return_code $return_code "0"

test_case "Absolute path to preset file"
unset yazpt_dummy return_code
yazpt_load_preset "$PWD/dummy2.zsh"
return_code=$?
test_init_done
equals yazpt_dummy $yazpt_dummy "dummy2"
equals return_code $return_code "0"

test_case "Symlink to a preset file"
unset yazpt_dummy return_code
yazpt_load_preset "./dummy-link"
return_code=$?
test_init_done
equals yazpt_dummy $yazpt_dummy "dummy2"
equals return_code $return_code "0"

test_case "Non-existent preset name"
unset yazpt_dummy return_code
yazpt_load_preset void
return_code=$?
test_init_done
equals yazpt_dummy $yazpt_dummy ""
equals return_code $return_code "1"

test_case "Relative path to non-existent preset file"
unset yazpt_dummy return_code
yazpt_load_preset "./void.zsh"
return_code=$?
test_init_done
equals yazpt_dummy $yazpt_dummy ""
equals return_code $return_code "1"

test_case "Absolute path to non-existent preset file"
unset yazpt_dummy return_code
yazpt_load_preset "$PWD/void.zsh"
return_code=$?
test_init_done
equals yazpt_dummy $yazpt_dummy ""
equals return_code $return_code "1"

test_case "Directory"
unset yazpt_dummy return_code
yazpt_load_preset "$PWD"
return_code=$?
test_init_done
equals yazpt_dummy $yazpt_dummy ""
equals return_code $return_code "1"

test_case "Non-text file"  # Including empty files
unset yazpt_dummy return_code
yazpt_load_preset "/dev/null"
return_code=$?
test_init_done
equals yazpt_dummy $yazpt_dummy ""
equals return_code $return_code "1"

# Clean up
after_tests
