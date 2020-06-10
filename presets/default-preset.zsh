# Yazpt's default preset, automatically loaded with yazpt itself. Other presets here are defined relative to this baseline,
# i.e. they're expected to `source` this to reset to defaults, then apply their specific overrides.

# -----------------------------------------------------------------------------------------------------------------------------
# All of the YAZPT_*_COLOR variables below accept the same range of values: anything valid in a zsh `%F{...}` expression.
# See http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Character-Highlighting's "fg=colour" section for details,
# but to summarize, valid values include: default (meaning the terminal's default foreground colour, usually gray);
# black, red, green, yellow, blue, magenta, cyan, white; numbers from 0-255 (where 0-7 are the named colors above,
# 8-15 are the bold/bright variants of those colors, 16-231 are colors from a palette of 216, and 232-255 are shades of gray);
# and on a terminal that supports true color, "#" followed by 3 or 6 hex digits specifying RGB.
#
# Giving an invalid value sometimes results in the terminal's default foreground color being used,
# and sometimes results in black being used (like you'd used the value `0`), which in many color schemes makes it invisible.
#
# Unpredictable but generally unfortunate things tend to happen if you use #RGB colors in a terminal without true color,
# such as Terminal.app. You can work around this limitation with zsh's "nearcolor" module:
# [[ $COLORTERM == *(24bit|truecolor)* ]] || zmodload zsh/nearcolor
#
# Yazpt doesn't escape *COLOR variables as it uses them in creating $PS1 and $RPS1, so you can have a bit of pointless fun
# by setting one to `%?` or `%j`, or `!` if you have prompt_bang turned on. More usefully, if you turn on prompt_subst
# and create ~/.yazpt_allow_subst, you can set one to `$(foo)`, where `foo` is a function which returns a color value
# based on some condition.
# -----------------------------------------------------------------------------------------------------------------------------

# Layout settings. These are like templates for $PS1 and $RPS1;
# they can contain anything $PS1/$RPS1 can, plus yazpt-style prompt segments/separators.
#
# Note that yazpt keeps the prompt_subst option turned off for safety, unless you create the ~/.yazpt_allow_subst file,
# so you'll need to do that if you want to use parameter/arithmetic expansion or command substitution in your prompt.

YAZPT_LAYOUT=$'\n[<cwd><? ><exit><? ><vcs>]\n<char> '
YAZPT_RLAYOUT='<exectime>'               # Works well with `setopt transient_rprompt`

# Settings for the "cwd" prompt segment, which shows the current working directory.

YAZPT_CWD_COLOR=73                       # Cyan

# Settings for the "exectime" prompt segment, which shows the execution time of the previous command,
# i.e how long it took to run. Formatted with hours/minutes/seconds, eliding any values which are zeros.

YAZPT_EXECTIME_CHAR="$yazpt_hourglass"   # Shown to the left of the execution time (include a trailing space if you want one)
YAZPT_EXECTIME_COLOR=195                 # Pale light blue
YAZPT_EXECTIME_MIN_SECONDS=10            # Minimum execution time to trigger display in the prompt

# Settings for the "exit" prompt segment, which shows the previous command's exit code
# and optionally a preceding success/failure indicator character.

YAZPT_EXIT_ERROR_CHAR="✘"                # Set to empty string for no error indicator character
YAZPT_EXIT_ERROR_CODE_VISIBLE=true       # Display the command's numeric exit code if it's non-zero?
YAZPT_EXIT_ERROR_COLOR=208               # Orange

YAZPT_EXIT_OK_CHAR=""                    # Set to empty string for no success indicator character
YAZPT_EXIT_OK_CODE_VISIBLE=false         # Display the command's numeric exit code if it's zero?
YAZPT_EXIT_OK_COLOR=29                   # Dark green/cyan

# Settings for the "vcs", "git", "svn", and "tfvc" prompt segments, including characters which indicate status at a glance.
# You can unset any of the *_CHAR variables below if you don't want to see an indicator for that status.
#
# The "git" segment shows the Git branch/tag/SHA, any 'activity' in progress, such as rebasing or merging,
# and 1-2 characters indicating the current status of the working tree.
#
# The "svn" segment shows the Subversion branch/tag, relevant extra info, e.g. if the current directory is unversioned,
# and 1-3 characters indicating the current status of the working copy.
#
# The "tfvc" prompt segment shows the Team Foundation Version Control local workspace's server path,
# and 1-2 characters indicating the current status of the workspace.
#
# The "vcs" segment shows either one or none of the above segments, checking each VCS listed in $YAZPT_VCS_ORDER below.
# If a VCS adds nothing to the prompt for any reason (e.g. because the current directory doesn't match its path prefix list),
# checking continues with the next VCS in the list.

YAZPT_VCS_CONTEXT_COLOR=255              # Bright white; default color for VCS context (branch/tag/SHA, activity or extra info)
YAZPT_VCS_CONTEXT_META_COLOR=240         # Dark gray; the cwd is in a .git, .svn, $tf or .tf directory (or a bare Git repo)
YAZPT_VCS_CONTEXT_IGNORED_COLOR=240      # Dark gray; the cwd is in a directory ignored by Git (not Subversion/TFVC)
YAZPT_VCS_CONTEXT_UNVERSIONED_COLOR=240  # Dark gray; the cwd is in an unversioned, and maybe ignored, directory
                                         # in a Subversion working copy; not used in Git repos or TFVC workspaces

YAZPT_VCS_STATUS_CLEAN_CHAR="●"          # The repo, working copy, or workspace has no changes or differing commits
YAZPT_VCS_STATUS_CLEAN_COLOR=29          # Dark green/cyan; used in Git/Subversion/TFVC
YAZPT_VCS_STATUS_CONFLICT_CHAR="≠"       # Items are conflicted after an `svn update`
YAZPT_VCS_STATUS_CONFLICT_COLOR=9        # Bright red, probably (based on terminal color scheme); used only in Subversion
YAZPT_VCS_STATUS_DIRTY_CHAR="⚑"          # There are untracked files or unstaged/uncommitted/pending changes
YAZPT_VCS_STATUS_DIRTY_COLOR=208         # Orange; used in Git/Subversion/TFVC
YAZPT_VCS_STATUS_DIVERGED_CHAR="◆"       # The local Git branch's commits don't match its remote/upstream branch's
YAZPT_VCS_STATUS_DIVERGED_COLOR=166      # Reddish orange; used only in Git
YAZPT_VCS_STATUS_LINKED_BARE_CHAR="↪"    # The cwd is in a bare Git repo's linked worktree, where `git status` only partly works
YAZPT_VCS_STATUS_LINKED_BARE_COLOR=81    # Light blue; used only in Git
YAZPT_VCS_STATUS_LOCKED_CHAR="⊠"         # An item is locked in the working copy for exclusive commit/check-in
YAZPT_VCS_STATUS_LOCKED_COLOR=229        # Light yellow, almost bright white; used in Subversion/TFVC
YAZPT_VCS_STATUS_NO_UPSTREAM_CHAR="◆"    # The local Git branch has no remote/upstream branch
YAZPT_VCS_STATUS_NO_UPSTREAM_COLOR=31    # Dark cyan; used only in Git
YAZPT_VCS_STATUS_UNKNOWN_CHAR="⌀"        # The repo's status can't be determined, due to an error or missing CLI
YAZPT_VCS_STATUS_UNKNOWN_COLOR=9         # Bright red, probably (based on terminal color scheme); used in Git/Subversion/TFVC

YAZPT_VCS_WRAPPER_CHARS=()               # Characters shown before and after the Git/Subversion/TFVC context & status;
                                         # Should be an empty array or contain 2 characters, e.g. ('[' ']')

# VCS behavior settings
# (Default values are set here if needed, but aren't forced to defaults every time this preset is loaded)
YAZPT_VCS_ORDER=(${YAZPT_VCS_ORDER-git}) # VCSs to check, in the order listed in this array; for best prompt performance,
                                         # list the VCS you use most first, then any others you use, e.g. use `(git svn tfvc)`
                                         # to enable all of them in a likely order (Subversion and TFVC are disabled by default)

declare -ag YAZPT_GIT_PATHS              # Directory prefix lists for activating VCS checks; Git, Subversion and/or TFVC checks
declare -ag YAZPT_SVN_PATHS              # are only made in directories whose full paths begin with one of these strings;
declare -ag YAZPT_TFVC_PATHS             # an empty array, or unset variable, enables the corresponding VCS in any directory
                                         # Examples: YAZPT_GIT_PATHS=(~/Code/ ~/.yazpt /usr/local/Homebrew)
                                         # YAZPT_TFVC_PATHS=(/cygdrive/c/Users/$USER/Source/Workspaces/ ~/Source/Workspaces/)

: ${YAZPT_CHECK_TFVC_LOCKS=true}         # Enable to check for locked files in TFVC workspaces by parsing pendingchanges.tf1,
                                         # or disable to treat any locked files as just "dirty" and make the prompt a bit faster

# Tweaks and fixups for various environments
if [[ -z $YAZPT_NO_TWEAKS ]]; then
	if [[ $OSTYPE == "darwin"* ]]; then
		# I think this chain-link character is more expressive than the default arrow,
		# but it renders problematically almost everywhere except on macOS
		YAZPT_VCS_STATUS_LINKED_BARE_CHAR="⚭"

	elif [[ $OS == "Windows"* || -n $WSL_DISTRO_NAME ]]; then
		_yazpt_tweaks_file="tweaks-for-windows.zsh"
	elif [[ $OSTYPE == "linux-gnu" ]]; then
		_yazpt_tweaks_file="tweaks-for-linux.zsh"
	elif [[ $OSTYPE == "freebsd"* ]]; then
		_yazpt_tweaks_file="tweaks-for-freebsd.zsh"
	else
		unset _yazpt_tweaks_file
	fi

	if [[ -n $_yazpt_tweaks_file ]]; then
		functions .yazpt_tweak_hourglass > /dev/null || source "$yazpt_base_dir/functions/$_yazpt_tweaks_file"
		unset _yazpt_tweaks_file
		.yazpt_tweak_hourglass
	fi
fi

# Default any flags set by other presets.
unset _yazpt_terminus_hacks

# Set/restore default settings for input highlighting.
if (( $+_yazpt_default_zle_highlight )); then
	zle_highlight=($_yazpt_default_zle_highlight)
else
	_yazpt_default_zle_highlight=($zle_highlight)
fi
