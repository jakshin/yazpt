# A preset favoring shades of green and bluish green,
# with refreshing bright white input.

source "$yazpt_default_preset_file"

YAZPT_LAYOUT=$'\n<cwd><? ><exit><? ><vcs>\n%# '
YAZPT_CWD_COLOR=23

YAZPT_EXIT_ERROR_CHAR=""
YAZPT_EXIT_ERROR_CODE_VISIBLE=true
YAZPT_EXIT_ERROR_COLOR=36
YAZPT_EXIT_OK_CHAR=""
YAZPT_EXIT_OK_CODE_VISIBLE=true
YAZPT_EXIT_OK_COLOR=36

YAZPT_VCS_BRANCH_COLOR=34
YAZPT_VCS_WRAPPER_CHARS="()"

YAZPT_VCS_STATUS_CLEAN_CHAR=""
YAZPT_VCS_STATUS_CLEAN_COLOR=34
YAZPT_VCS_STATUS_DIRTY_COLOR=229
YAZPT_VCS_STATUS_DIVERGED_COLOR=230
YAZPT_VCS_STATUS_LOCKED_COLOR=230
YAZPT_VCS_STATUS_NO_UPSTREAM_COLOR=240

zle_highlight=(default:fg=254 suffix:fg=243)
