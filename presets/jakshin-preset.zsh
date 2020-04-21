# A preset based on my personal default settings for the last decade or so.
#
# It's maybe a bit weird to put the Git context and status on the left,
# so it shifts the current directory to the right when it's visible,
# but I like that it makes it more visually obvious when I'm in a Git repo.
#
# Showing the current directory in bright yellow makes a very clear visual divider
# between each command, since commands rarely use bright yellow in their output.

source "$yazpt_default_preset_file"

YAZPT_LAYOUT=$'\n[<vcs><? ><cwd><? ><exit>]\n%# '
YAZPT_CWD_COLOR=226  # Yellow
