#!/bin/zsh
# Tests for yazpt's handling of the prompt_subst zsh option.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name

YAZPT_LAYOUT='$(echo HEY) <cwd> <char> '
HOME=$(pwd -P)

# Test
test_case "Turn prompt_subst off if it's on"
setopt prompt_subst
test_init_done
[[ -o prompt_subst ]] && prompt_subst=on || prompt_subst=off
equals "prompt_subst" "$prompt_subst" "off"
contains '$(echo HEY)'

test_case "Don't turn prompt_subst off if ~/.yazpt_allow_subst exists"
setopt prompt_subst
touch .yazpt_allow_subst
test_init_done && saved_prompt="$(eval noglob echo $PROMPT)"  # Like prompt_subst will do
[[ -o prompt_subst ]] && prompt_subst=on || prompt_subst=off
equals "prompt_subst" "$prompt_subst" "on"
echo "Evaluating \$PROMPT a la prompt_subst -> $saved_prompt"
PROMPT=$saved_prompt excludes '$(echo HEY)'
PROMPT=$saved_prompt contains 'HEY'

# Clean up
after_tests
