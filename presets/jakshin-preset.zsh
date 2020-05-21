# A preset based on my personal default settings for the last decade or so.
#
# It's maybe a bit weird to put the VCS context and status on the left,
# so it shifts the current directory to the right when it's visible,
# but I like that it makes it more visually obvious when I'm working in
# a Git repo, Subversion working copy, or TFVC workspace.
#
# Showing the current directory in bright yellow makes a very clear visual divider
# between each command, since commands rarely use bright yellow in their output.

source "$yazpt_default_preset_file"

YAZPT_LAYOUT=$'\n[<vcs><? ><cwd><? ><exit>]\n<char> '
YAZPT_CWD_COLOR=226       # Yellow
YAZPT_EXECTIME_COLOR=240  # Dark gray
