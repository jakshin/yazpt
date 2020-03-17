#!/bin/zsh
# Tests for escaping the current working directory's name.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name

function mock_prezto() {
	if [[ $1 == true ]]; then
		ZPREZTODIR=~/.zprezto
		zstyle ':prezto:module:prompt' 'pwd-length' 'mock'

		function prompt-pwd() {
			echo "${PWD/#$HOME/~}"  # Like Prezto's "long" mode
		}
	elif [[ $1 == false ]]; then
		unset ZPREZTODIR
		zstyle -d ':prezto:module:prompt' 'pwd-length'
		unfunction 'prompt-pwd'
	else
		echo " ${failure_bullet} mock_prezto was called incorrectly [$1]"
		(( failed++ ))
	fi                
} 

# Test
test_case "Directory containing an exclamation mark"
mkdir 'hey!' && cd 'hey!'

setopt no_prompt_bang
test_init_done
contains "%~"
excludes "hey"
mock_prezto true
test_init_done "no-standard-tests"
excludes "%~"
contains 'hey!'
mock_prezto false

setopt prompt_bang
test_init_done
contains "%~"
excludes "hey"
mock_prezto true
test_init_done "no-standard-tests"
excludes "%~"
contains 'hey!!'
mock_prezto false

test_case "Directory containing a percent escape sequence"
mkdir '%F{red}blargh%f' && cd '%F{red}blargh%f'

setopt no_prompt_percent
test_init_done
contains "%~"
excludes "blargh"
mock_prezto true
test_init_done "no-standard-tests"
excludes "%~"
contains '%F{red}blargh%f'
mock_prezto false

setopt prompt_percent
test_init_done
contains "%~"
excludes "blargh"
mock_prezto true
test_init_done "no-standard-tests"
excludes "%~"
contains '%%F{red}blargh%%f'
mock_prezto false

test_case "Directory containing a potential command substitution"
mkdir '$(echo pwned)' && cd '$(echo pwned)'

setopt no_prompt_subst
test_init_done
contains "%~"
excludes "echo"
excludes "pwned"
mock_prezto true
test_init_done "no-standard-tests"
excludes "%~"
contains '$(echo pwned)'
mock_prezto false

setopt prompt_subst
test_init_done
contains "%~"
excludes "echo"
excludes "pwned"
mock_prezto true
test_init_done "no-standard-tests"
excludes "%~"
contains '$yazpt_cwd'
excludes "pwned"
mock_prezto false

test_case "Directory containing a legacy potential command substitution"
mkdir '`echo pwned`' && cd '`echo pwned`'

setopt no_prompt_subst  
test_init_done
contains "%~"
excludes "echo"
excludes "pwned"
mock_prezto true
test_init_done "no-standard-tests"
excludes "%~"
contains '`echo pwned`'
mock_prezto false

setopt prompt_subst  
test_init_done
contains "%~"
excludes "echo"
excludes "pwned"
mock_prezto true
test_init_done "no-standard-tests"
excludes "%~"
contains '$yazpt_cwd'
excludes "pwned"
mock_prezto false

# Clean up
after_tests
