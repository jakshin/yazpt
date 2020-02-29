# A prompt preset based on my personal default settings for the last decade or so.
#
# It's maybe a bit weird to put the git branch and status on the left,
# so it shifts the current directory to the right when it's visible,
# but I like that it makes it more visually obvious when I'm in a git repo.
#
# Showing the current directory in bright yellow makes a very clear visual divider
# between each command, since commands rarely use bright yellow in their output.

source "$yazpt_default_preset_file"

YAZPT_LAYOUT=$'\n<cwd><? ><result><? ><git>\n%# '

YAZPT_CWD_COLOR=23
YAZPT_GIT_WRAPPER_CHARS="()"
YAZPT_GIT_BRANCH_COLOR=34

YAZPT_GIT_STATUS_CLEAN_CHAR=""
YAZPT_GIT_STATUS_DIRTY_CHAR_COLOR=229
YAZPT_GIT_STATUS_DIVERGED_CHAR_COLOR=230
YAZPT_GIT_STATUS_NO_REMOTE_CHAR_COLOR=240

YAZPT_RESULT_ERROR_CHAR=""
YAZPT_RESULT_ERROR_CODE_COLOR=36
YAZPT_RESULT_OK_CODE_COLOR=36
YAZPT_RESULT_OK_CODE_VISIBLE=true

zle_highlight=(default:fg=254 suffix:fg=243)
