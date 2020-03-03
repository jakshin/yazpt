# Yazpt's default preset, automatically loaded with yazpt itself.
# The other presets here are defined relative to this baseline,
# i.e. they're expected to `source` this to reset to defaults,
# then apply their specific overrides.

# Layout: prompt segments, separators, etc.
YAZPT_LAYOUT=$'\n[<cwd><? ><result><? ><git>]\n%# '

# Settings for the "cwd" prompt segment, which shows the current working directory.
YAZPT_CWD_COLOR=73                        # Cyan

# Settings for the "git" prompt segment, which combines "git_branch" and "git_status",
# so their settings affect it too.
YAZPT_GIT_WRAPPER_CHARS=""                # Before/after the branch+status; use 2 characters or empty string

# Settings for the "git_branch" prompt segment.
YAZPT_GIT_BRANCH_COLOR=255                # Bright white
YAZPT_GIT_BRANCH_GIT_DIR_COLOR=240        # Dark gray; used when the CWD is in/under the .git directory
YAZPT_GIT_BRANCH_IGNORED_DIR_COLOR=240    # Dark gray; used when the CWD is in/under a directory ignored by git

# Settings for the "git_status" prompt segment.
YAZPT_GIT_STATUS_CLEAN_CHAR="●"           # Used when the repo is clean (no changes, nothing staged, no need to push/pull)
YAZPT_GIT_STATUS_CLEAN_CHAR_COLOR=29      # Dark green/cyan
YAZPT_GIT_STATUS_DIRTY_CHAR="⚑"           # Used when there are untracked files, unstaged or uncommitted changes
YAZPT_GIT_STATUS_DIRTY_CHAR_COLOR=208     # Orange
YAZPT_GIT_STATUS_DIVERGED_CHAR="◆"        # Used when the local branch's commits don't match its remote/upstream branch's
YAZPT_GIT_STATUS_DIVERGED_CHAR_COLOR=166  # Reddish orange
YAZPT_GIT_STATUS_NO_REMOTE_CHAR="◆"       # Used when the local branch has no remote/upstream branch
YAZPT_GIT_STATUS_NO_REMOTE_CHAR_COLOR=31  # Dark cyan
YAZPT_GIT_STATUS_UNKNOWN_CHAR="?"         # Used when the repo's status can't be determined
YAZPT_GIT_STATUS_UNKNOWN_CHAR_COLOR=45    # Bright blue

# Settings for the "result" prompt segment, which shows the previous command's exit code.
YAZPT_RESULT_ERROR_CHAR="✘"               # Set to empty string for no error indicator character
YAZPT_RESULT_ERROR_CHAR_COLOR=208         # Orange
YAZPT_RESULT_ERROR_CODE_COLOR=208         # Orange
YAZPT_RESULT_ERROR_CODE_VISIBLE=true      # Display the command's numeric exit code if it's non-zero?
YAZPT_RESULT_OK_CHAR=""                   # Set to empty string for no success indicator character
YAZPT_RESULT_OK_CHAR_COLOR=29             # Dark green/cyan
YAZPT_RESULT_OK_CODE_COLOR=29             # Dark green/cyan
YAZPT_RESULT_OK_CODE_VISIBLE=false        # Display the command's numeric exit code if it's zero?

# Set/restore default settings for input highlighting.
if (( $+yazpt_default_zle_highlight )); then
	zle_highlight=$yazpt_default_zle_highlight
else
	yazpt_default_zle_highlight=$zle_highlight
fi
