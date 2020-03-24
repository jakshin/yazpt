#!/bin/zsh
# Tests for branch/tag display in a Subversion working copy (trunk checked out).

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name "svn"
YAZPT_VCS_ORDER=(svn)

# Test
test_case "On trunk"
test_init_done
contains_branch "trunk"

test_case "On trunk, in a directory"
cd grandparent/parent/child
test_init_done
contains_branch "trunk"

test_case "On trunk, in an ignored directory"
mkdir -p ignored-dir && cd ignored-dir
test_init_done
contains_dim_branch "trunk"
contains "|UNVERSIONED"

test_case "On trunk, in an unversioned directory"
mkdir -p unversioned-dir && cd unversioned-dir
test_init_done
contains_dim_branch "trunk"
contains "|UNVERSIONED"
cd .. && rmdir unversioned-dir

test_case "On trunk, in the .svn directory"
cd .svn
test_init_done
contains_dim_branch "trunk"
contains "|IN-SVN-DIR"


test_case "In the list of branches"
svn switch '^/branches' --ignore-ancestry
test_init_done
contains_branch "branches"

test_case "In the list of branches, on a branch"
cd branch1
test_init_done
contains_branch "branch1"
cd grandparent/parent/child
test_init_done
contains_branch "branch1"


test_case "On a branch"
svn switch "^/branches/branch1" --ignore-ancestry
test_init_done
contains_branch "branch1"

test_case "On a branch, in a directory"
cd grandparent/parent/child
test_init_done
contains_branch "branch1"

test_case "On a branch, in an ignored directory"
mkdir -p ignored-dir && cd ignored-dir
test_init_done
contains_dim_branch "branch1"
contains "|UNVERSIONED"

test_case "On a branch, in an unversioned directory"
mkdir -p unversioned-dir && cd unversioned-dir
test_init_done
contains_dim_branch "branch1"
contains "|UNVERSIONED"
cd .. && rmdir unversioned-dir

test_case "On a branch, in the .svn directory"
cd .svn
test_init_done
contains_dim_branch "branch1"
contains "|IN-SVN-DIR"


test_case "On a branch's subdirectory"
svn switch '^/branches/branch1/grandparent' --ignore-ancestry
test_init_done
contains_branch "branch1"
cd parent/child
test_init_done
contains_branch "branch1"


test_case "In the list of tags"
svn switch '^/tags' --ignore-ancestry
test_init_done
contains_branch "tags"

test_case "In the list of tags, on a tag"
cd tag1
test_init_done
contains_branch "tag1"
cd grandparent/parent/child
test_init_done
contains_branch "tag1"


test_case "On a tag"
svn switch "^/tags/tag1" --ignore-ancestry
test_init_done
contains_branch "tag1"

test_case "On a tag, in a directory"
cd grandparent/parent/child
test_init_done
contains_branch "tag1"

test_case "On a tag, in an ignored directory"
mkdir -p ignored-dir && cd ignored-dir
test_init_done
contains_dim_branch "tag1"
contains "|UNVERSIONED"

test_case "On a tag, in an unversioned directory"
mkdir -p unversioned-dir && cd unversioned-dir
test_init_done
contains_dim_branch "tag1"
contains "|UNVERSIONED"
cd .. && rmdir unversioned-dir

test_case "On a tag, in the .svn directory"
cd .svn
test_init_done
contains_dim_branch "tag1"
contains "|IN-SVN-DIR"


test_case "On a branch with a scary name, with prompt_subst on"
setopt prompt_subst
svn switch '^/branches/$(IFS=_;cmd=echo_arg;$cmd)' --ignore-ancestry
test_init_done
contains '$yazpt_branch'
PROMPT="$(eval noglob echo $PROMPT)"  # Like prompt_subst will do
contains_branch '$(IFS=_;cmd=echo_arg;$cmd)'
	
test_case "On a branch with a scary name, with prompt_subst on, in the .svn directory"
cd .svn
test_init_done
contains '$yazpt_branch'
PROMPT="$(eval noglob echo $PROMPT)"  # Like prompt_subst will do
contains_dim_branch '$(IFS=_;cmd=echo_arg;$cmd)'
contains "|IN-SVN-DIR"

test_case "On a branch with a scary name, with prompt_subst off"
setopt no_prompt_subst
test_init_done
contains_branch '$(IFS=_;cmd=echo_arg;$cmd)'

test_case "On a branch with a scary name, with prompt_subst off, in the .svn directory"
cd .svn
test_init_done
contains_dim_branch '$(IFS=_;cmd=echo_arg;$cmd)'
contains "|IN-SVN-DIR"

test_case "On a branch that could trigger prompt expansion, with prompt_bang on"
setopt prompt_bang
svn switch '^/branches/is!a!test' --ignore-ancestry
test_init_done
contains_branch 'is!!a!!test'
	
test_case "On a branch that could trigger prompt expansion, with prompt_bang off"
setopt no_prompt_bang
test_init_done
contains_branch 'is!a!test'
	
test_case "On a branch that could trigger prompt expansion (prompt_percent)"
svn switch '^/branches/%F{160}red' --ignore-ancestry
test_init_done
contains_branch '%%F{160}red'


test_case "On a random directory off the root of the repo"
svn switch '^/random' --ignore-ancestry
test_init_done
contains_branch 'random'
cd thing1
test_init_done
contains_branch 'thing1'
cd thing2
test_init_done
contains_branch 'thing1'

test_case "On a scary directory off the root of the repo, with prompt_subst on"
setopt prompt_subst
svn switch '^/$(IFS=_;cmd=echo_arg;$cmd)' --ignore-ancestry
test_init_done
contains '$yazpt_branch'
PROMPT="$(eval noglob echo $PROMPT)"  # Like prompt_subst will do
contains_branch '$(IFS=_;cmd=echo_arg;$cmd)'

test_case "On a scary directory off the root of the repo, with prompt_subst off"
setopt no_prompt_subst
test_init_done
contains_branch '$(IFS=_;cmd=echo_arg;$cmd)'

test_case "On a directory off the root that could trigger prompt expansion, with prompt_bang on"
setopt prompt_bang
svn switch '^/is!a!test' --ignore-ancestry
test_init_done
contains_branch 'is!!a!!test'

test_case "On a directory off the root that could trigger prompt expansion, with prompt_bang off"
setopt no_prompt_bang
test_init_done
contains_branch 'is!a!test'

test_case "On a directory off the root that could trigger prompt expansion (prompt_percent)"
svn switch '^/%F{160}red' --ignore-ancestry
test_init_done
contains_branch '%%F{160}red'

test_case "On a directory off the root that exercises our URL-decoding"
svn switch '^/spaces +%2520 %252B%252520' --ignore-ancestry  # Manually URL-encoded for Subversion
test_init_done
contains_branch 'spaces +%%20 %%2B%%2520'  # We double up percent signs, because prompt_percent

# Clean up
after_tests
