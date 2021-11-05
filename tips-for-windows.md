# Tips for using yazpt on Windows


## Environments/Frameworks

When choosing an environment or framework for running UNIX programs on Windows 10 and Windows 11, you have a handful of options, each of which has strengths and weaknesses.

### Windows Subsystem for Linux (WSL)

[WSL](https://docs.microsoft.com/en-us/windows/wsl/) is now pretty much the standard/default way to run UNIX programs on Windows.

By default, it uses Windows' ancient console subsystem, which unfortunately mangles yazpt's Unicode characters and emoji, unless you install and use the [DejaVu Sans Mono font](https://dejavu-fonts.github.io) -- then yazpt works well enough, though without emoji support, so falling back to emoticons in the yolo preset. Still, upgrading to Windows Terminal is a good idea. It's also quick and easy to use Mintty instead, by [installing WSLtty](https://github.com/mintty/wsltty) and then [configuring it](#mintty).

You can change your default shell the normal UNIX way, by running `chsh -s /usr/bin/zsh` at a bash or zsh prompt.

### Cygwin

[Cygwin](https://cygwin.com) has been around for roughly forever, and is comfortable and dependable. It starts up faster than WSL, but then creating new processes is a tad slower. It has a wide selection of software which is easy to install and upgrade, all of which tends to Just Work. Installation and upgrades are easy and hassle-free.

Windows Terminal is probably the best terminal emulator to use with Cygwin, and yazpt works on it without hassles or tweaking. Cygwin's default terminal is Mintty, and it's also quite nice; if you use it, you'll want to take a couple of minutes to [configure it](#mintty).

After you've installed Cygwin's zsh, the easiest way to make it your default shell, rather than bash, is by changing your Windows `SHELL` environment variable to `/usr/bin/zsh`.

### MSYS2

Yazpt also works well on [MSYS2](https://www.msys2.org), if you like that more than Cygwin. Windows Terminal works great with MSYS2. Mintty is also installed with MSYS2, so if you prefer it, just [configure it](#mintty) and you should be good to go.

### MobaXterm (and its embedded Cygwin-based environment)

Among [MobaXterm's](https://mobaxterm.mobatek.net) eleventy bajillion features is a "local console" which lets you run UNIX programs, including zsh -- it's basically a BusyBox + Cygwin + apt-cyg environment, bundled inside MobaXterm. Yazpt works fine on it, except the yolo preset's emoji are rendered as monochrome line drawings.
<p align="center">•</p>


## Terminal Emulators

Unless you're using MobaXterm's embedded environment, you have your choice of a few terminal emulators to use in place of each environment's default. Windows Terminal is a good pick in any case, but some of the other options are more configurable, look a bit better, and/or have additional features.

### Windows Terminal

Windows Terminal has surprisingly solid rendering of Unicode characters and emoji, and yazpt works well on it right out of the box, with no fuddling about. It's preinstalled on Windows 11, and available from the Microsoft Store for Windows 10, or can be downloaded directly from [its GitHub page](https://github.com/Microsoft/Terminal).

### Mintty

You'll get Mintty shortcuts automatically with Cygwin and MSYS2 installations, and it works very well, but needs a bit of configuration for best results.

You should ensure that Mintty is configured with `xterm-256color` as its terminal type (icon > `Options...` > `Terminal` pane > `Type`); otherwise colors, including yazpt's, might not show up. And I personally prefer the `flat-ui` color theme (on the `Looks` tab), but whatever floats your boat.

Mintty renders emoji as awkward monochrome line drawings by default. To get a nice full-color emoji experience, you need to [install emoji support for Mintty](https://github.com/mintty/mintty/wiki/Tips#emojis). This even works on Windows 7, where emoji are otherwise only rendered as empty boxes.

The easiest way to install Mintty's emoji support is to use this `svn` command at a zsh prompt:

```sh
emojis_dir=~/.config/mintty/emojis  # Or "$(wslpath $APPDATA)/wsltty/emojis" on WSL
mkdir -p $emojis_dir && cd $emojis_dir && \
svn export https://github.com/iamcal/emoji-data/trunk/img-apple-160 apple
```

_(Note that the directory you export into has to be named "apple", or the next step probably won't work.)_

Then open Mintty's options dialog, select the Text panel, and in the Emojis section, select `apple` in the Styles dropdown, and `align` in the Placement dropdown.

### Tabby

It's a bit heavyweight, but [Tabby](https://tabby.sh) is very pretty, and renders better-looking color emoji than most other Windows terminals I've tried. It also has macOS and Linux versions, which makes it possible to standardize your terminal across OSes. (I like its "Base16 Default Dark" color scheme, by the way, and the "Fluent" background type.)

You'll need to switch its font from the default Consolas to [DejaVu Sans Mono](https://dejavu-fonts.github.io) for yazpt's Unicode characters to all render well.

To enable the yolo theme's color emoji when running Tabby on WSL, you'll need to manually set the `$TERM_PROGRAM` environment variable (which Tabby normally does itself, but which doesn't work when it's running on WSL). You can set the environment variable before loading yazpt, or else reload yazpt after you've done so:

```sh
export TERM_PROGRAM=Tabby  # (Only needed when running Tabby on WSL)
yazpt_plugin_unload && source ~/.yazpt/yazpt.zsh-theme
```

### ConEmu

[ConEmu](https://conemu.github.io) has some nice features, and is incredibly configurable. It doesn't handle 256-color mode very well, though.

With its default settings, it mangles many of yazpt's Unicode characters, but you can fix that by installing the [DejaVu Sans Mono font](https://dejavu-fonts.github.io) and configuring ConEmu to use it, on its Fonts settings panel; choose DejaVu Sans Mono in the "Main console font" dropdown, and uncheck the "Alternative font" checkbox a bit further down.

ConEmu doesn't render the yolo preset's emoji correctly, even with DejaVu Sans Mono, so when yazpt detects it's running under ConEmu, it uses emoticons instead.

### MobaXterm (as a WSL terminal)

[MobaXterm](https://mobaxterm.mobatek.net) can be used as a terminal emulator for WSL. Yazpt works fine on it, except the yolo preset's emoji are rendered as monochrome line drawings.

### No Terminal Emulator

It's possible to run zsh on Cygwin, MSYS2 or WSL without a terminal emulator at all, i.e. just using Windows' console subsystem. It's the default for WSL, and with Cygwin and MSYS2 it's as easy as launching zsh.exe directly.

This actually works pretty well on Windows 10 and Windows 11 if you install the [DejaVu Sans Mono font](https://dejavu-fonts.github.io) and configure the console to use it (icon in title bar > Defaults > Font tab, then restart zsh.exe). Yazpt will then render decently, though without emoji support, so falling back to emoticons in the yolo preset.
<p align="center">•</p>


## Older Windows Versions

On **Windows 8**, Cygwin works just like as on Windows 10 and Windows 11, as [described above](#cygwin), and Mintty can be [configured](#mintty) as usual too.

On **Windows 7**, though, yazpt's Unicode characters are rendered poorly in Cygwin's Mintty; to fix that, install the [DevaVu Sans Mono font](https://dejavu-fonts.github.io), and configure Mintty to use it, on its options dialog's Text panel. Yazpt's yolo preset's emoji are rendered as empty boxes by default, too; fortunately, [installing Mintty's emoji support](#mintty) fixes that problem.
