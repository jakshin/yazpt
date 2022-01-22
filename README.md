# yazpt = yet another zsh prompt theme

Yazpt is a clean, fast, good-looking [zsh](http://zsh.sourceforge.net) prompt theme that thoughtfully incorporates Git/Subversion/TFVC status info, integrates with popular plugin managers like [Oh My Zsh](#with-oh-my-zsh), and is straightforward to customize and extend.

<p align="center">[
  <a href="#features">Features</a>
• <a href="#supportedtested-environments">Supported/Tested Environments</a>
• <a href="#installing">Installing</a>
• <a href="#enabling-subversion-andor-team-foundation-version-control">Enabling Subversion/TFVC</a>
• <a href="#customizing">Customizing</a>
]</p><br>


Git | Subversion | TFVC
----| ---------- | ----
<img src="Screenshots/Git.png"> | <img src="Screenshots/Subversion.png"> | <img src="Screenshots/TFVC.png">

Yazpt's appearance can be easily changed by loading one of its presets:

dense preset | elementary preset | jakshin preset
-------------| ----------------- | --------------
<img src="Screenshots/dense-preset.png"> | <img src="Screenshots/elementary-preset.png"> | <img src="Screenshots/jakshin-preset.png">

sapphire preset | spearmint preset | yolo preset
----------------| ---------------- | -----------
<img src="Screenshots/sapphire-preset.png"> | <img src="Screenshots/spearmint-preset.png"> | <img src="Screenshots/yolo-preset.png">


## Features

* **It's fast.**
  It's faster than any prompt theme which relies on [vcs_info](https://github.com/zsh-users/zsh/tree/master/Functions/VCS_Info), and faster than nearly all prompt themes which don't use async approaches for obtaining and displaying VCS status. Prompt themes which populate the VCS parts of the prompt asynchronously can be faster, but I actually tend not to love them, as I personally find it a bit distracting when part of the prompt pops into existence a bit later than the rest.

  Yazpt also allows you to configure lists of path prefixes in which you expect to find Git repos, Subversion working copies, and/or Team Foundation Version Control local workspaces - if you've done so, then while working in any path which isn't in one or more of those lists, it skips checking for Git/Subversion/TFVC status, improving performance even further. If you don't happen to use one or more of the supported VCSs, you can also entirely disable yazpt's use of any of them.

* **It's as configurable as you want it to be.**
  Yazpt uses about three dozen environment variables to tweak its appearance and behavior. If that sounds like too much to bother with, it also comes with a handful of "presets", i.e. preconfigured settings for the environment variables, in a variety of styles. Or if, on the other hand, you really want to dig in and customize it, it's straightforward to add new prompt segments, or override the default implementations of existing prompt segments, using zsh functions. Either way, the details are all [carefully documented](customizing.md) to help you jump right in.

* **It lets you do your own thing with $PS1 and $RPS1.**
  Yazpt thinks of itself as an add-on or power-up, not a replacement, for zsh's built-in prompt logic, so if you've already spent time pimping out your `$PS1` or `$RPS1`, there's no need to throw that work away - you can copy your current `$PS1` straight into `$YAZPT_LAYOUT` (and/or `$RPS1` into `$YAZPT_RLAYOUT`), and then add any yazpt-specific segments you'd like.

* **It's secure.**
  A surprising number of prompt themes will execute arbitrary shell code if you [browse an unsafe repo](https://github.com/jakshin/pw3nage). Others fail to escape the info they show in ways that lead to corrupted display, e.g. allowing zsh to interpret percent escape sequences or exclamation marks in either the current directory's path or a VCS branch name. Yazpt tries hard to avoid those mistakes, and works properly regardless of your preferences about zsh settings like `prompt_subst` and `prompt_bang`.

* **It doesn't require a patched font.**
  Because it uses only standard Unicode characters, yazpt works fine with most standard terminal fonts. You don't need a patched one, like from [Nerd Fonts](https://www.nerdfonts.com) or [Powerline Fonts](https://github.com/powerline/fonts) - but of course if you use one of those fonts in your terminal, you can configure yazpt to use its special glyphs.

* **It incorporates Git info thoughtfully.**
  Rather than try to display every detail about the Git status in the prompt, like many prompt themes do, and which has always seemed a bit visually busy to me, yazpt tries to boil it all down to a few key bits of info: the current branch, whether a significant activity is in progress (like merging or rebasing), and one of 3 meaningful, action-oriented statuses:
  * The working tree is dirty (with untracked files, and/or staged or unstaged changes),
  * The local branch has different commits than its remote branch, or
  * Both the working tree and branch are clean, i.e. neither of the above is true.

  There are a couple of other statuses that can be shown in less-common situations; in any case, if you don't know or remember what one of the status characters means, you can just run the explainer function, `yazpt_explain_git`, for full details.

  Yazpt goes out of its way to make its Git support seamless, e.g. by showing correct Git status info even when you're browsing in the `.git` directory, which most other prompts don't bother to do.

  Incidentally, yazpt supports bare repos, linked worktrees, and even bare repos' linked worktrees, more completely and correctly than any other prompt theme I've tried.

* **It incorporates Subversion info thoughtfully, too.**
  There are a few cases where I still need to use Subversion, and I've generally found other prompt themes' support for it a bit lacking. The biggest gap is that although Subversion thinks of status as a per-directory concept, in all of my SVN usage patterns, it would be more convenient and helpful to see status across my whole working copy, like I'm used to while using Git.

  In general, what I want to know while using Subversion in a terminal is:
  * Which branch I have checked out (usually `trunk`, but occasionally something else),
  * Whether my last `svn update` resulted in a conflict that I haven't resolved yet,
  * Whether I have any files locked, anywhere in my working copy, and
  * Whether my working copy is dirty anywhere, i.e. has new unversioned files/directories,
    or uncommitted file/directory/property changes, in any directory.

  So that's exactly what yazpt shows - even, unlike many other prompt themes, while the current directory is ignored or unversioned, including in the `.svn` directory.

  Yazpt also has an explainer function for its Subversion statuses - just run `yazpt_explain_svn` for a list of all possible Subversion statuses and their meanings.

  Note that yazpt's Subversion support is disabled by default, and needs to be [enabled](#enabling-subversion-andor-team-foundation-version-control).

* **It incorporates Team Foundation Version Control info.**
  While I'd probably be a bit happier if TFVC went the way of VSS, the world doesn't always work exactly how I'd like. 😉

  When I use TFVC, it's usually in Visual Studio - and I think I'm normal in that regard - so only lightweight support for TFVC at a prompt seems warranted:
  * Some basic context, i.e. the workspace's server path,
  * Whether the workspace is dirty at all, i.e. has any pending additions/modifications/deletions, and
  * Whether I have any items locked.

  Command-line tools for TFVC exist - a `TF.exe` ships with Visual Studio for Windows, and on other platforms there's a CLI tool called [TEE-CLC](https://github.com/microsoft/team-explorer-everywhere) - but they run far too slowly to be used while generating a prompt, so instead yazpt parses a couple of TFVC's binary data files itself (`properties.tf1` and `pendingchanges.tf1`).

  The `yazpt_explain_tfvc` explainer function shows the details.

  Note that yazpt's TFVC support is disabled by default, and needs to be [enabled](#enabling-subversion-andor-team-foundation-version-control).
  <p align="center">•</p>


## Supported/Tested Environments

Yazpt's code logic should work just about anywhere zsh 5.1+ itself does, and with any semi-recent version of the Git and Subversion CLIs, but how well its Unicode VCS status characters get rendered can vary a bit across environments; a bit of tinkering usually fixes things up nicely, or you can load the [elementary preset](./presets/elementary-preset.zsh), which only uses ASCII characters.

### macOS

My primary environment is macOS, and yazpt works without fuss on recent versions -- in Terminal.app, [iTerm](https://iterm2.com), and [Tabby](https://tabby.sh) -- with the system zsh, and either the system or [Homebrew](https://brew.sh) versions of git and svn. I use yazpt on these macOS versions regularly, or did at one time:

* **macOS 11 Big Sur**,
  with the preinstalled fixed width fonts, plus
  [Bitstream Vera Sans Mono](https://www.gnome.org/fonts),
  [Fira Code](https://github.com/tonsky/FiraCode),
  [Meslo](https://www.nerdfonts.com), and
  [Source Code Pro](https://github.com/adobe-fonts/source-code-pro)
  (all with Terminal.app's "Antialias text" setting turned on)
* **macOS 10.15 Catalina**
* **macOS 10.14.6 Mojave**
* **macOS 10.13.6 High Sierra**

### Windows

Yazpt also works without fuss in Windows Terminal on Windows 10 and Windows 11, whether it's running on Windows Subsystem for Linux (WSL), [Cygwin](https://cygwin.com) or [MSYS2](https://www.msys2.org).

It also works in various other terminals, including Mintty, Tabby, MobaXterm, and ConEmu, and on Windows 7 and 8, but a little bit of tinkering is needed for good results -- see the [tips for using yazpt on Windows](./tips-for-windows.md) for details.

### Haiku

Yazpt works in [Haiku R1/beta3's](https://www.haiku-os.org) Terminal application, after these steps are taken:
* Install zsh and the DejaVu fonts, either in HaikuDepot, or with `pkgman install zsh dejavu`
* Configure Terminal to use the DejaVu Sans Mono font

You'll also want to switch Terminal's color theme from the default to one with a dark background.

If you'd like for Terminal to run zsh every time you open a window or tab, rather than bash, create `~/config/settings/bash_profile` with these contents:

```sh
if [[ $- =~ i && -x /bin/zsh ]]; then
	exec /bin/zsh
fi
```

### Linux

Yazpt just works, without any special attention, in many popular distros:

* CentOS 8.3 and CentOS Stream 8, installed as a "server with GUI"
* Debian 10.9 and 11.x, installed with defaults ("Debian desktop environment")
* Kali Linux 2021.1, 2021.3
* KDE neon
* Kubuntu 20.04 and newer
* Linux Mint 20.1 and newer (Cinnamon, MATE or XFCE)
* openSUSE Leap 15.3 and openSUSE Tumbleweed, running KDE Plasma 5
* Pop!_OS 20.04 and newer

It also works well in lots of other distros, including [Ubuntu](tips-for-linux.md#ubuntu-desktop-2004-lts-focal-fossa-2104-hirsute-hippo-2110-impish-indri) and its variants, after making some minor tweaks to settings and/or installing a font or two. See the [tips for using yazpt on GNU/Linux](./tips-for-linux.md) for details.

### FreeBSD

I don't use FreeBSD much, but just for kicks I tried yazpt out on a couple of its derivatives. A bit of tinkering is warranted; see the [tips for using yazpt on FreeBSD derivatives](./tips-for-freebsd.md) for details.
<p align="center">•</p>


## Installing

Yazpt can be installed in a variety of ways, with popular zsh frameworks or completely on its own.

### Without a framework

Yazpt doesn't require a framework - to start using it, you can just `source yazpt.zsh-theme`, on demand or in your `.zshrc` file. To install, clone the git repo to a location of your choice:

```sh
git clone https://github.com/jakshin/yazpt ~/.yazpt
```

Then source the theme file (in your `.zshrc` to apply it in all terminal sessions), and optionally load a preset and/or tweak some settings:

```sh
source ~/.yazpt/yazpt.zsh-theme

# Optionally, and for example
yazpt_load_preset dense  # Run yazpt_list_presets to see available choices
YAZPT_CWD_COLOR=70       # Type 'YAZPT_' and press tab to see all settings
```

### With zsh's prompt theme system

Yazpt integrates with zsh's native "promptinit" [prompt theme system](http://zsh.sourceforge.net/Doc/Release/User-Contributions.html#Prompt-Themes). To install, clone the git repo to a location of your choice, and symlink `prompt_yazpt_setup` into a directory in your `$fpath`; running `install-resources.zsh` is the easiest way:

```sh
git clone https://github.com/jakshin/yazpt ~/.yazpt  # Or wherever you'd like
~/.yazpt/resources/install-resources.zsh
```

To begin using yazpt:

```sh
autoload -U promptinit && promptinit  # Usually in .zshrc
prompt yazpt  # You can pass a preset's name if you want, e.g. `prompt yazpt spearmint`
```

### With Oh My Zsh

To install, clone the git repo, and create a symlink for [Oh My Zsh](https://ohmyz.sh) to find:

```sh
git clone https://github.com/jakshin/yazpt $ZSH_CUSTOM/themes/yazpt
ln -sv $ZSH_CUSTOM/themes/yazpt/yazpt.zsh-theme $ZSH_CUSTOM/themes/yazpt.zsh-theme
```

Then, in your `.zshrc`, _before_ the `source $ZSH/oh-my-zsh.sh` line:

```sh
ZSH_THEME="yazpt"
```

If you'd like to load a preset and/or tweak some settings, put those lines in your `.zshrc` in the "User configuration" section (_after_ the `source $ZSH/oh-my-zsh.sh` line):

```sh
# Optionally, and for example
yazpt_load_preset jakshin
YAZPT_CWD_COLOR=14
```

### With Prezto

If you've already installed yazpt for zsh's [prompt theme system](#with-zshs-prompt-theme-system), it'll Just Work with [Prezto](https://github.com/sorin-ionescu/prezto) as well. You don't even need to enable Prezto's Git module.

Otherwise, to install yazpt into Prezto, clone the git repo to a location of your choice, and symlink `prompt_yazpt_setup` into your `.zprezto/modules/prompt/functions` directory:

```sh
git clone https://github.com/jakshin/yazpt ~/.yazpt  # Or wherever you'd like

target_path="${ZDOTDIR:-$HOME}/.zprezto/modules/prompt/functions"
ln -sv ~/.yazpt/functions/prompt_yazpt_setup $target_path/prompt_yazpt_setup
```

To use yazpt on demand, run `prompt yazpt`, optionally with a preset, e.g. `prompt yazpt sapphire`. To make it your default prompt, put this in the "Prompt" section of your `~/.zpreztorc`:

```sh
zstyle ':prezto:module:prompt' theme 'yazpt'
# Or with a preset: zstyle ':prezto:module:prompt' theme 'yazpt' 'sapphire'
```

To tweak yazpt's settings further, add to the bottom of your `.zshrc`, below the "Customize to your needs" line:

```sh
# Optionally, and for example
yazpt_load_preset sapphire
YAZPT_GIT_HIDE_IN_BARE_REPO=true
```

If you explicitly configure Prezto's [pwd-length](https://github.com/sorin-ionescu/prezto/tree/master/modules/prompt#prompt-display-length) or [show-return-val](https://github.com/sorin-ionescu/prezto/tree/master/modules/prompt#display-return-value) settings, yazpt will respect those settings while running under Prezto - but you _do_ need to configure them explicitly, rather than relying on Prezto's defaults for those settings, as yazpt doesn't know or care about Prezto's defaults. You'll also still need an `<exit>` somewhere in your $YAZPT_LAYOUT or $YAZPT_RLAYOUT for setting `show-return-val` to `yes` to work.

```sh
# Optionally, and for example
zstyle ':prezto:module:prompt' pwd-length 'short'
zstyle ':prezto:module:prompt' show-return-val 'no'
```

### With Zinit

To try the prompt out under [Zinit](https://github.com/zdharma/zinit) (formerly named Zplugin), run `zinit load jakshin/yazpt`. To use the prompt in all terminal sessions, just add that line to your `.zshrc`, then tweak any settings you'd like:

```sh
zinit load jakshin/yazpt
yazpt_load_preset yolo  # Optionally, and for example
```

Yazpt implements an unload function as specified in the [Zdharma Zsh Plugin Standard](https://github.com/zdharma-continuum/Zsh-100-Commits-Club/blob/master/Zsh-Plugin-Standard.adoc#unload-fun), so you can unload it by calling `zinit unload jakshin/yazpt`.
<p align="center">•</p>


## Enabling Subversion and/or Team Foundation Version Control

By default, yazpt disables its support for Subversion and Team Foundation Version Control. To enable either or both of those VCSs in the prompt, you'll need to adjust the `$YAZPT_VCS_ORDER` - a good place to do this is right after you load yazpt in your `.zshrc`. For example, if you mostly use Git, but occasionally work in Subversion and TFVC repos, you can use this setting:

```sh
YAZPT_VCS_ORDER=(git svn tfvc)
```

In order to prevent performance from dropping with the additional VCSs enabled, you'll probably also want to configure yazpt's path prefix list for each VCS, so it only spends time trying to gather VCS status when it needs to. For example, on Windows with Cygwin, something like this might work well:

```sh
user_profile_path="$(cygpath "$USERPROFILE")"
YAZPT_GIT_PATHS=("$user_profile_path/Documents/Visual Studio 2019/Projects/" ~/.yazpt)
YAZPT_SVN_PATHS=("$user_profile_path/Documents/Code/")
YAZPT_TFVC_PATHS=("$user_profile_path/Source/Workspaces/")
```

Note that while yazpt knows when the current directory is ignored by Git or Subversion, and uses a different color when displaying the VCS context, it doesn't know this for TFVC -- if you cd into an ignored directory in a TFVC local workspace, the VCS status will still be displayed in the default color. Yazpt does know enough about whether files/directories are ignored by TFVC to correctly display the local workspace's clean/dirty state, though.

Also, for the TFVC prompt segment to properly display non-ASCII characters in branch names, the `iconv` command line tool must be available. It's usually installed by default, but not on [Cygwin](tips-for-windows.md#cygwin), where the `libiconv` package must be installed in order to get it.

Finally, when using TFVC on Windows, with the workspace open in Visual Studio, any changes in the workspace get noticed immediately, whether they're made through Visual Studio or otherwise, and TFVC updates its metadata in the `$tf` directory right away. The same is true when making changes via the `tf` CLI, whether VS is running or not. But otherwise, like while changing files using general command-line utilities without Visual Studio running, TFVC won't notice changes until you kick it a little - by, say, running `tf info` or `tf status`. I hope to improve on this situation eventually.
<p align="center">•</p>


## Customizing

Yazpt is quite customizable, with options ranging from very simple (loading a preset) to somewhat complex (implementing a custom segment). [Read on for details](customizing.md).
