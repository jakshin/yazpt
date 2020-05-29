#!/usr/bin/env zsh
# Installs this directory's resource files, by creating symlinks to them.

function usage() {
	explain "This script installs resource files from this directory, by creating symlinks to them." && echo
	explain "Installing prompt_yazpt_setup is only useful if you use Prezto, or zsh's promptinit-based prompt theme system." \
		"Installing Xresources is only useful if you use XTerm (and haven't already configured it yourself)."

	echo "\nUsage: $script_name [options]"
	echo "\nOptions:"
	option "-f, --force" "Install without asking for confirmation. Without this option," \
		"you'll be prompted before installing each resource file, and before replacing any existing files."
	option "-h, --help" "Show this help and exit, regardless of any other options given."
	exit
}

# Utilities
script_name="$(basename -- "$0")"
script_dir="$(dirname -- "$0")"
repo_dir="$(cd -- "$script_dir/.." && pwd -P)"

source "$repo_dir/functions/utils.zsh"

explanation_color='\e[38;5;152m'
question_color='\e[38;5;231m'
warning_color='\e[38;5;217m'
no_color='\e[0m'

function ask() {
	echo -n "${question_color}${*}${no_color}"
	read -rq REPLY
	echo
	[[ $REPLY == 'y' ]]
}

function ask_to_install() {
	local text="$*"
	[[ $force == true ]] && text+=" Installing..."
	explain "$text"

	if [[ $force == true ]]; then
		echo
	elif ! ask "\nInstall it? [y|n] "; then
		echo "Okie doke, skipping installation."
		return 1
	fi
}

function ask_to_replace() {
	local target_path="$1" description=""
	if [[ -L "$target_path" ]]; then
		description="Symlink"
	elif [[ -e "$target_path" && ! -d "$target_path" ]]; then
		description="File"
	fi

	if [[ -n "$description" && $force != true ]] && ! ask "${description} ${target_path} exists. Replace it? [y|n] "; then
		echo "Okay then."
		return 1
	fi
}

function check_existing_directory() {
	local target_path="$1"
	if [[ -d "$target_path" ]]; then
		.yazpt_print_wrapped "Error: Target $target_path already exists, as a directory"
		return 1
	fi
}

function explain() {
	echo -n "$explanation_color"
	.yazpt_print_wrapped "$*"
	echo -n "$no_color"
}

function make_symbolic_link() {
	local target_path="$1"
	local link_path="$2"
	local sudo="$3"

	if [[ $OSTYPE == "msys" ]]; then
		# See https://github.com/msys2/MSYS2-packages/issues/249
		echo "MSYS2 doesn't support creating symbolic links with 'ln -s'."
		echo "Creating a symbolic link with cmd's mklink command instead..."

		# You might need to run as Administrator for this mklink command to succeed; try that
		# if you get an error about "You do not have sufficient privilege to perform this operation",
		# but still want a symlink instead of a copy of the file
		if cmd //c mklink "$(cygpath -w "$link_path")" "$(cygpath -w "$target_path")"; then
			return
		elif [[ $force == true ]]; then
			echo "Falling back to creating a copy..."
		elif ! ask "Creating a symbolic link failed. Create a copy instead? [y|n] "; then
			return 1
		fi
	fi

	$sudo ln -sv "$target_path" "$link_path"  # Creates a copy on MSYS2
}

function option() {
	local opt="$1"; opt="${(r:14:)opt}"; shift
	local desc="$*"
	echo -n "  "
	.yazpt_print_wrapped "${opt}${desc}" 2
}

function warn() {
	echo "${warning_color}${*}${no_color}"
}

function xrdb_merge() {
	if ( [[ $OSTYPE != "darwin"* && $OS != "Windows"* && -z $WSL_DISTRO_NAME ]] ) || which xrdb > /dev/null; then
		xrdb -merge "$1"
	fi
}

# Parse the command line
force=false

for arg; do
	if [[ $arg == "-f" || $arg == "--force" ]]; then
		force=true
	elif [[ $arg == "-h" || $arg == "--help" ]]; then
		usage
	else
		warn "Invalid argument: ${arg}\n"
		usage
	fi
done

# Install prompt_yazpt_setup
target_dir='/usr/local/share/zsh/site-functions'
target="$target_dir/prompt_yazpt_setup"

msg="It's installed by creating a symlink in $target_dir."
if [[ $OS != "Windows"* && $USERNAME != "root" ]]; then
	msg+=" Doing so requires using sudo."
	sudo="sudo"  # Used below and in make_symbolic_link
fi

if ask_to_install "Yazpt's integration with zsh's prompt theme system (promptinit), and with the Prezto framework," \
     "is enabled by the prompt_yazpt_setup file. $msg" && \
   ask_to_replace "$target"
then
	installed=false && \
		check_existing_directory "$target" && \
		attempted=true && \
		$sudo rm -f "$target" && \
		$sudo mkdir -pv "$target_dir" && \
		make_symbolic_link "$repo_dir/resources/prompt_yazpt_setup" "$target" "$sudo" && \
		installed=true || warn "An error occurred during installation."

	if [[ $installed == true ]]; then
		msg="Installed. Run 'autoload -U promptinit && promptinit' and then 'prompt' for more details on usage."
		.yazpt_print_wrapped "$msg"
	elif [[ $attempted == true && $sudo != "" ]]; then
		msg="If sudo told you you're not in the sudoers file, you might try running 'su' and then running this script again."
		.yazpt_print_wrapped "$msg"
	fi
fi

# Install Xresources
target=~$USER/.Xresources  # So it works while running under su
echo

if ask_to_install "Using XTerm with its default settings can be a bit painful. Yazpt includes an Xresources file" \
     "which makes XTerm look considerably nicer. It's installed by creating a symlink in your home directory." && \
   ask_to_replace "$target"
then
	installed=false && \
		check_existing_directory "$target" && \
		rm -f "$target" && \
		make_symbolic_link "$repo_dir/resources/Xresources" "$target" "" && \
		chown -h "$USER" "$target" && \
		xrdb_merge "$target" && \
		installed=true || warn "An error occurred during installation."

	if [[ $installed == true ]]; then
		msg="Installed. If ~/.Xresources doesn't have any effect when you start a new XTerm, "
		msg+="it might help if you rename it to ~/.Xdefaults-$(hostname)."
		.yazpt_print_wrapped "$msg"
	fi
fi
