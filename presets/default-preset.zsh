# Yazpt's default preset, automatically loaded with yazpt itself. Other presets here are defined relative to this baseline,
# i.e. they're expected to `source` this to reset to defaults, then apply their specific overrides.

# All of the YAZPT_*_COLOR settings below accept the same range of values: anything valid in a `%F{...}` expression.
# See http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Character-Highlighting's "fg=colour" section for details,
# but to summarize, valid values include: default (the terminal's default foreground colour);
# black, red, green, yellow, blue, magenta, cyan, white;
# numbers from 0-255 (where 0-7 are the named colors above, 8-15 are the bold/bright variants of those colors,
# 16-231 select colors from a 216 palette, and 232-255 select shades of gray);
# and on a terminal that supports true color, "#" followed by 3 or 6 hex digits specifying RGB.
#
# Giving an invalid value sometimes results in the terminal's default color being used,
# and sometimes results in black being used (like you'd used the value `0`).
#
# Unpredictable but generally unfortunate things tend to happen if you use #RGB colors
# in a terminal that doesn't support true color, such as Terminal.app.

# Layout: Like a template for $PS1, with anything $PS1 can contain, plus prompt segments/separators.
YAZPT_LAYOUT=$'\n[<cwd><? ><result><? ><git>]\n%# '

# Settings for the "cwd" prompt segment, which shows the current working directory.
YAZPT_CWD_COLOR=73                         # Cyan

# Settings for the "git" prompt segment, which combines "git_branch" and "git_status";
# the YAZPT_GIT_BRANCH_* and YAZPT_GIT_STATUS_* settings below affect this prompt segment too.
YAZPT_GIT_WRAPPER_CHARS=""                 # Shown before/after the branch+status; use empty string or 2 characters, e.g. "()"
YAZPT_GIT_HIDE_IN_BARE_REPO=false          # Hide git-related prompt segments in a bare repo? (Shows "BARE-REPO" if not)

# Settings for the "git_branch" prompt segment, including any 'activity' like "REBASING".
YAZPT_GIT_BRANCH_COLOR=255                 # Bright white; used by default
YAZPT_GIT_BRANCH_GIT_DIR_COLOR=240         # Dark gray; used when the CWD is in/under the .git directory (or a bare repo)
YAZPT_GIT_BRANCH_IGNORED_DIR_COLOR=240     # Dark gray; used when the CWD is in/under a directory ignored by git

# Settings for the "git_status" prompt segment.
# You can unset any of the YAZPT_*_CHAR settings below if you don't want to see an indicator for that status.
YAZPT_GIT_STATUS_CLEAN_CHAR="●"            # Used when the repo is clean (no changes, nothing staged, no need to push/pull)
YAZPT_GIT_STATUS_CLEAN_CHAR_COLOR=29       # Dark green/cyan
YAZPT_GIT_STATUS_DIRTY_CHAR="⚑"            # Used when there are untracked files, unstaged or uncommitted changes
YAZPT_GIT_STATUS_DIRTY_CHAR_COLOR=208      # Orange
YAZPT_GIT_STATUS_DIVERGED_CHAR="◆"         # Used when the local branch's commits don't match its remote/upstream branch's
YAZPT_GIT_STATUS_DIVERGED_CHAR_COLOR=166   # Reddish orange
YAZPT_GIT_STATUS_LINKED_BARE_CHAR="⚭"	   # Used in bare repos' linked worktrees, where `git status` only partly works
YAZPT_GIT_STATUS_LINKED_BARE_CHAR_COLOR=81 # Light blue
YAZPT_GIT_STATUS_NO_UPSTREAM_CHAR="◆"      # Used when the local branch has no remote/upstream branch
YAZPT_GIT_STATUS_NO_UPSTREAM_CHAR_COLOR=31 # Dark cyan
YAZPT_GIT_STATUS_UNKNOWN_CHAR="⌀"          # Used when the repo's status can't be determined
YAZPT_GIT_STATUS_UNKNOWN_CHAR_COLOR=9      # Bright red, probably (based on terminal color scheme)

# Settings for the "result" prompt segment, which shows the previous command's exit code
# and optionally a preceding success/failure indicator character.
YAZPT_RESULT_ERROR_CHAR="✘"                # Set to empty string for no error indicator character
YAZPT_RESULT_ERROR_CHAR_COLOR=208          # Orange
YAZPT_RESULT_ERROR_CODE_COLOR=208          # Orange
YAZPT_RESULT_ERROR_CODE_VISIBLE=true       # Display the command's numeric exit code if it's non-zero?
YAZPT_RESULT_OK_CHAR=""                    # Set to empty string for no success indicator character
YAZPT_RESULT_OK_CHAR_COLOR=29              # Dark green/cyan
YAZPT_RESULT_OK_CODE_COLOR=29              # Dark green/cyan
YAZPT_RESULT_OK_CODE_VISIBLE=false         # Display the command's numeric exit code if it's zero?

# Set/restore default settings for input highlighting.
if (( $+yazpt_default_zle_highlight )); then
	zle_highlight=$yazpt_default_zle_highlight
else
	yazpt_default_zle_highlight=$zle_highlight
fi
