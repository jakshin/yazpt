# A preset favoring shades of blue, with colors are defined in 16-color mode
# so they match the ANSI color palette set up in your terminal emulator.

source "$yazpt_default_preset_file"

YAZPT_LAYOUT=$'\n[<result><? ><cwd><? ><git>]\n%# '

YAZPT_CWD_COLOR=4
YAZPT_GIT_BRANCH_COLOR=12
YAZPT_GIT_BRANCH_GIT_DIR_COLOR=8
YAZPT_GIT_BRANCH_IGNORED_DIR_COLOR=8

YAZPT_GIT_STATUS_CLEAN_CHAR=""
YAZPT_GIT_STATUS_DIRTY_CHAR_COLOR=15
YAZPT_GIT_STATUS_DIVERGED_CHAR_COLOR=7
YAZPT_GIT_STATUS_NO_UPSTREAM_CHAR_COLOR=8
YAZPT_GIT_STATUS_UNKNOWN_CHAR=""

YAZPT_RESULT_ERROR_CHAR_COLOR=15
YAZPT_RESULT_ERROR_CODE_COLOR=15
YAZPT_RESULT_OK_CHAR="✔︎"
YAZPT_RESULT_OK_CHAR_COLOR=8
YAZPT_RESULT_OK_CODE_COLOR=8
