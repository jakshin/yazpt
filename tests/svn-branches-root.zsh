#!/bin/zsh
# Tests for branch/tag display in a Subversion working copy (repo root checked out).

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name "svn-root"
YAZPT_VCS_ORDER=(svn)

[[ -e ~/.yazpt_allow_subst ]] && yazpt_allow_subst_existed=true
touch ~/.yazpt_allow_subst

# Test
test_case "In the root directory"
test_init_done
contains_context "SVN-ROOT"

test_case "In the .svn directory"
cd .svn
test_init_done
contains_dim_context "SVN-ROOT"
contains "|IN-SVN-DIR"


test_case "On trunk"
cd trunk
test_init_done
contains_context "trunk"

test_case "On trunk, in a directory"
cd trunk/grandparent/parent/child
test_init_done
contains_context "trunk"

test_case "On trunk, in an ignored directory"
cd trunk
mkdir -p ignored-dir && cd ignored-dir
test_init_done
contains_dim_context "trunk"
contains "|UNVERSIONED"

test_case "On trunk, in an unversioned directory"
cd trunk
mkdir -p unversioned-dir && cd unversioned-dir
test_init_done
contains_dim_context "trunk"
contains "|UNVERSIONED"
cd .. && rmdir unversioned-dir


test_case "In the list of branches"
cd branches
test_init_done
contains_context "branches"

test_case "On a branch"
cd branches/branch1
test_init_done
contains_context "branch1"

test_case "On a branch, in a directory"
cd branches/branch1/grandparent/parent/child
test_init_done
contains_context "branch1"

test_case "On a branch, in an ignored directory"
cd branches/branch1
mkdir -p ignored-dir && cd ignored-dir
test_init_done
contains_dim_context "branch1"
contains "|UNVERSIONED"

test_case "On a branch, in an unversioned directory"
cd branches/branch1
mkdir -p unversioned-dir && cd unversioned-dir
test_init_done
contains_dim_context "branch1"
contains "|UNVERSIONED"
cd .. && rmdir unversioned-dir


test_case "In the list of tags"
cd tags
test_init_done
contains_context "tags"

test_case "On a tag"
cd tags/tag1
test_init_done
contains_context "tag1"

test_case "On a tag, in a directory"
cd tags/tag1/grandparent/parent/child
test_init_done
contains_context "tag1"

test_case "On a tag, in an ignored directory"
cd tags/tag1
mkdir -p ignored-dir && cd ignored-dir
test_init_done
contains_dim_context "tag1"
contains "|UNVERSIONED"

test_case "On a tag, in an unversioned directory"
cd tags/tag1
mkdir -p unversioned-dir && cd unversioned-dir
test_init_done
contains_dim_context "tag1"
contains "|UNVERSIONED"
cd .. && rmdir unversioned-dir


test_case "On a tag with a scary name, with prompt_subst on"
setopt prompt_subst
cd 'tags/$(IFS=_;cmd=echo_arg;$cmd)'
test_init_done && saved_prompt="$(eval noglob echo $PROMPT)"  # Like prompt_subst will do
contains '$_yazpt_subst[context]'
echo "Evaluating \$PROMPT a la prompt_subst -> $saved_prompt"
PROMPT=$saved_prompt contains_context '$(IFS=_;cmd=echo_arg;$cmd)'

test_case "On a tag with a scary name, with prompt_subst off"
setopt no_prompt_subst
cd 'tags/$(IFS=_;cmd=echo_arg;$cmd)'
test_init_done
contains_context '$(IFS=_;cmd=echo_arg;$cmd)'

test_case "On a tag that could trigger prompt expansion, with prompt_bang on"
setopt prompt_bang
cd 'tags/is!a!test'
test_init_done
contains_context 'is!!a!!test'

test_case "On a tag that could trigger prompt expansion, with prompt_bang off"
setopt no_prompt_bang
cd 'tags/is!a!test'
test_init_done
contains_context 'is!a!test'

test_case "On a tag that could trigger prompt expansion (prompt_percent)"
cd 'tags/%F{160}red'
test_init_done
contains_context '%%F{160}red'


test_case "In a random directory off the root of the repo"
cd random
test_init_done
contains_context 'random'
cd thing1
test_init_done
contains_context 'thing1'
cd thing2
test_init_done
contains_context 'thing1'

test_case "In a scary directory off the root of the repo, with prompt_subst on"
setopt prompt_subst
cd '$(IFS=_;cmd=echo_arg;$cmd)'
test_init_done && saved_prompt="$(eval noglob echo $PROMPT)"  # Like prompt_subst will do
contains '$_yazpt_subst[context]'
echo "Evaluating \$PROMPT a la prompt_subst -> $saved_prompt"
PROMPT=$saved_prompt contains_context '$(IFS=_;cmd=echo_arg;$cmd)'

test_case "In a scary directory off the root of the repo, with prompt_subst off"
setopt no_prompt_subst
cd '$(IFS=_;cmd=echo_arg;$cmd)'
test_init_done
contains_context '$(IFS=_;cmd=echo_arg;$cmd)'

test_case "In a directory off the root that could trigger prompt expansion, with prompt_bang on"
setopt prompt_bang
cd 'is!a!test'
test_init_done
contains_context 'is!!a!!test'

test_case "In a directory off the root that could trigger prompt expansion, with prompt_bang off"
setopt no_prompt_bang
cd 'is!a!test'
test_init_done
contains_context 'is!a!test'

test_case "In a directory off the root that could trigger prompt expansion (prompt_percent)"
cd '%F{160}red'
test_init_done
contains_context '%%F{160}red'

test_case "In a directory off the root that exercises our URL-decoding"
cd 'spaces +%20 %2B%2520'
test_init_done
contains_context 'spaces +%%20 %%2B%%2520'  # We double up percent signs, because prompt_percent

# Clean up
after_tests
[[ $yazpt_allow_subst_existed == true ]] || rm -f ~/.yazpt_allow_subst
