#!/bin/zsh
# Tests for TFVC settings (via environment variables).

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name "tfvc"
YAZPT_VCS_ORDER=(tfvc)

# Test
test_case "TFVC context color"
YAZPT_VCS_CONTEXT_COLOR=1
YAZPT_VCS_CONTEXT_META_COLOR=2
test_init_done
contains '%{%F{1}%}$/yazpt-tfvc-test/Main%{%f%}'
cd $tf_dir_name
test_init_done
contains '%{%F{2}%}$/yazpt-tfvc-test/Main|IN-TF-DIR%{%f%}'

test_case "TFVC status = clean"
YAZPT_VCS_STATUS_CLEAN_CHAR="★"
YAZPT_VCS_STATUS_CLEAN_COLOR=17
test_init_done
contains '%{%F{17}%}★%{%f%}'

test_case "TFVC status = dirty"
YAZPT_VCS_STATUS_DIRTY_CHAR="☆"
YAZPT_VCS_STATUS_DIRTY_COLOR=18
function zstat() { stat=(24) }
function .yazpt_parse_pendingchanges_tf1() { _yazpt_tfvc_status=ny }
test_init_done
contains '%{%F{18}%}☆%{%f%}'

test_case "TFVC status = locked"
YAZPT_VCS_STATUS_LOCKED_CHAR="✪"
YAZPT_VCS_STATUS_LOCKED_COLOR=19
function .yazpt_parse_pendingchanges_tf1() { _yazpt_tfvc_status=yn }
test_init_done
contains '%{%F{19}%}✪%{%f%}'

test_case "TFVC status = locked and dirty"
function .yazpt_parse_pendingchanges_tf1() { _yazpt_tfvc_status=yy }
test_init_done
contains '%{%F{18}%}☆%{%f%}'
contains '%{%F{19}%}✪%{%f%}'

test_case "TFVC status = unknown"
YAZPT_VCS_STATUS_UNKNOWN_CHAR="✣"
YAZPT_VCS_STATUS_UNKNOWN_COLOR=21
function .yazpt_parse_pendingchanges_tf1() { _yazpt_tfvc_status=nn }
test_init_done
contains '%{%F{21}%}✣%{%f%}'

# Clean up
after_tests
