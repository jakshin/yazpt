#!/bin/zsh
# Tests for layout and its environment variable.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name

function @yazpt_segment_bar() {
	yazpt_state[bar]="BAR"
}

# Test
test_case "Basic layout control"
YAZPT_LAYOUT="Jason's \"favorite\" \\\test <string> <cwd>%# "
test_init_done
contains "Jason's \"favorite\" \\\test <string>"

test_case "Escaped angle-brackets"
YAZPT_LAYOUT="<cwd><< > <<> <> <foo> <bar> <<bar> %# "
test_init_done
contains "< > <> <> <foo> BAR <bar>"

test_case "Escaped angle-brackets in a separator"
YAZPT_LAYOUT="<cwd><? <<●<> ><bar> %# "
test_init_done
contains " <●> "

test_case "Unclosed segment tag"
YAZPT_LAYOUT="<cwd> %# <this never ends"
test_init_done
contains " <this never ends"

test_case "Separators"
YAZPT_LAYOUT="<cwd><?-one-><bar><?-two->[blah]<?-three-><bar> %# "
test_init_done
contains "-one-"
excludes "two"
excludes "three"
YAZPT_LAYOUT="<cwd><?-one-><bar><?-two-><blah><?-three-><bar> %# "
test_init_done
contains "-one-"
excludes "two"
excludes "three"

test_case "Repeated separators"
YAZPT_LAYOUT="<cwd><?-one-><?-two-><?-three-><bar> %# "
test_init_done
contains "-one-"
excludes "two"
excludes "three"
YAZPT_LAYOUT="<cwd><?-one-><?-two-><blah><?-three-><bar> %# "
test_init_done
excludes "one"
excludes "two"
excludes "three"

test_case "Spaces around a separator"
YAZPT_LAYOUT="<cwd> <?hey> <bar> %# "
test_init_done
contains "BAR"  # Sanity check
excludes "hey"  # The surrounding spaces are non-segment output

test_case "Empty YAZPT_LAYOUT"
YAZPT_LAYOUT=""
test_init_done  # Standard tests suffice in this case

# Clean up
after_tests
