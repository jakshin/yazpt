# Yazpt's default preset, automatically loaded with yazpt itself. Other presets here are defined relative to this baseline,
# i.e. they're expected to `source` this to reset to defaults, then apply their specific overrides.

# All of the YAZPT_*_COLOR variables below accept the same range of values: anything valid in a `%F{...}` expression.
# See http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Character-Highlighting's "fg=colour" section for details,
# but to summarize, valid values include: default (the terminal's default foreground colour);
# black, red, green, yellow, blue, magenta, cyan, white; numbers from 0-255 (where 0-7 are the named colors above,
# 8-15 are the bold/bright variants of those colors, 16-231 are colors from a palette of 216, and 232-255 are shades of gray);
# and on a terminal that supports true color, "#" followed by 3 or 6 hex digits specifying RGB.
#
# Giving an invalid value sometimes results in the terminal's default color being used,
# and sometimes results in black being used (like you'd used the value `0`).
#
# Unpredictable but generally unfortunate things tend to happen if you use #RGB colors
# in a terminal that doesn't support true color, such as Terminal.app.
# You can work around this limitation with zsh's "nearcolor" module:
# [[ $COLORTERM = *(24bit|truecolor)* ]] || zmodload zsh/nearcolor

# Layout: Like a template for $PS1, with anything $PS1 can contain, plus prompt segments/separators.

YAZPT_LAYOUT=$'\n[<cwd><? ><exit><? ><vcs>]\n%# '

# Settings for the "cwd" prompt segment, which shows the current working directory.

YAZPT_CWD_COLOR=73                      # Cyan

# Settings for the "exit" prompt segment, which shows the previous command's exit code
# and optionally a preceding success/failure indicator character.

YAZPT_EXIT_ERROR_CHAR="✘"               # Set to empty string for no error indicator character
YAZPT_EXIT_ERROR_CODE_VISIBLE=true      # Display the command's numeric exit code if it's non-zero?
YAZPT_EXIT_ERROR_COLOR=208              # Orange

YAZPT_EXIT_OK_CHAR=""                   # Set to empty string for no success indicator character
YAZPT_EXIT_OK_CODE_VISIBLE=false        # Display the command's numeric exit code if it's zero?
YAZPT_EXIT_OK_COLOR=29                  # Dark green/cyan

# Settings for the "vcs", "git" and "svn" prompt segments, including characters which indicate status at a glance.
# You can unset any of the *_CHAR variables below if you don't want to see an indicator for that status.
#
# The "git" segment shows the Git branch/tag/SHA, any 'activity' in progress, such as rebasing or merging,
# and 1-2 characters indicating the current status of the working tree.
#
# The "svn" segment shows the Subversion branch/tag, relevant extra info, e.g. if the current directory is unversioned,
# and 1-3 characters indicating the current status of the working copy.
#
# The "vcs" segment shows either or neither of the above segments, checking each VCS listed in $YAZPT_VCS_ORDER.
# If a VCS adds nothing to the prompt for any reason (e.g. because the current directory doesn't match its whitelist),
# checking continues with the next VCS in the list.

YAZPT_VCS_ORDER=(git svn)               # Order in which VCS checks will be made; checks stop when any VCS has output for the prompt
                                        # Re-declare with VCS names removed to disable them entirely

YAZPT_VCS_GIT_WHITELIST=()              # Whitelists for activating VCS checks; Git and/or Subversion checks will only be made
YAZPT_VCS_SVN_WHITELIST=()              # in directories whose full paths begin with one of the strings in these arrays;
                                        # unset one, or set it to an empty array, to enable the corresponding VCS anywhere

YAZPT_VCS_BARE_REPO_VISIBLE=true        # Show "BARE-REPO" as Git branch in bare Git repos? Otherwise hide Git info entirely;
                                        # Not applicable in Subversion working copies

YAZPT_VCS_BRANCH_COLOR=255              # Bright white; default color for the branch/tag/SHA, and any applicable activity or extra info
YAZPT_VCS_BRANCH_IN_META_COLOR=240      # Dark gray; used when the CWD is in/under the .git or .svn directory (or a bare Git repo)
YAZPT_VCS_BRANCH_IN_IGNORED_COLOR=240   # Dark gray; used when the CWD is in/under a directory ignored by Git (not Subversion)
YAZPT_VCS_BRANCH_IN_UNVERSION_COLOR=240 # Dark gray; used when the CWD is in/under an unversioned, and maybe ignored, directory
                                        # in a Subversion working copy; not applicable in Git repos

YAZPT_VCS_STATUS_CLEAN_CHAR="●"         # Used when the repo is clean: no changes, nothing staged, no need to push/pull (Git/Subversion)
YAZPT_VCS_STATUS_CLEAN_COLOR=29         # Dark green/cyan
YAZPT_VCS_STATUS_CONFLICT_CHAR="≠"      # Used when files are conflicted after an `svn update` (Subversion only)
YAZPT_VCS_STATUS_CONFLICT_COLOR=9       # Bright red, probably (based on terminal color scheme)
YAZPT_VCS_STATUS_DIRTY_CHAR="⚑"         # Used when there are untracked files, unstaged or uncommitted changes (Git/Subversion)
YAZPT_VCS_STATUS_DIRTY_COLOR=208        # Orange
YAZPT_VCS_STATUS_DIVERGED_CHAR="◆"      # Used when the local branch's commits don't match its remote/upstream branch's (Git only)
YAZPT_VCS_STATUS_DIVERGED_COLOR=166     # Reddish orange
YAZPT_VCS_STATUS_LINKED_BARE_CHAR="⚭"	# Used in bare repos' linked worktrees, where `git status` only partly works (Git only)
YAZPT_VCS_STATUS_LINKED_BARE_COLOR=81   # Light blue
YAZPT_VCS_STATUS_LOCKED_CHAR="⊠"        # Used when something is locked in the working copy for exclusive commit (Subversion only)
YAZPT_VCS_STATUS_LOCKED_COLOR=229       # Light yellow, almost bright white
YAZPT_VCS_STATUS_NO_UPSTREAM_CHAR="◆"   # Used when the local Git branch has no remote/upstream branch (Git only)
YAZPT_VCS_STATUS_NO_UPSTREAM_COLOR=31   # Dark cyan
YAZPT_VCS_STATUS_UNKNOWN_CHAR="⌀"       # Used when the repo's status can't be determined (Git/Subversion)
YAZPT_VCS_STATUS_UNKNOWN_COLOR=9        # Bright red, probably (based on terminal color scheme)

YAZPT_VCS_WRAPPER_CHARS=""              # Characters to show before and after the Git/Subversion branch+status;
                                        # Use an empty string or 2 characters, e.g. "()"

# Set/restore default settings for input highlighting.
if (( $+_yazpt_default_zle_highlight )); then
	zle_highlight=$_yazpt_default_zle_highlight
else
	_yazpt_default_zle_highlight=$zle_highlight
fi
