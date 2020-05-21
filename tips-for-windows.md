# Tips for using yazpt on Windows

There are a handful of ways to run UNIX programs like zsh on Windows. I mostly use [Cygwin](https://cygwin.com) and [Mintty](http://mintty.github.io), but I've also tested yazpt in a few other scenarios.


## Environments/Frameworks

When choosing an environment or framework for running UNIX programs on Windows 10, you have a handful of options, each of which has strengths and weaknesses.

### Cygwin

Of all the options I've tried, [Cygwin](https://cygwin.com) has been the most flexible and hassle-free for me. It can be a bit slow to run at times, especially when launching new processes, but it has a wide selection of software which is easy to install and upgrade, all of which tends to Just Work. Its default terminal, Mintty, is quite capable, and plenty configurable for my needs; its biggest missing feature IMHO is a tabbed UI.

After you've installed Cygwin's zsh, the easiest way to make it your default shell, rather than bash, is by changing your Windows `SHELL` environment variable to `/usr/bin/zsh`. You'll also want to take a couple of minutes to [configure Mintty](#configuring-mintty).

### MSYS2

Yazpt also works well on [MSYS2](https://www.msys2.org), if you prefer that to Cygwin. Mintty is installed with MSYS2, with Start Menu entries whose names begin with "MSYS2", and with just a couple of tweaks, you'll be in business.

Make zsh your default shell:
* EITHER change the "MSYS2 MinGW 64-bit" and/or similarly-named shortcuts so they run zsh instead of bash
  (In Windows 10: right-click the shortcut in the Start Menu, and select More > Open file location; right-click it in Explorer and select Properties; lastly, in the properties dialog's Shortcut tab, add `-shell zsh` to the end of the Target field)
* OR put this at the top of your ~/.bash_profile: `[[ $- != *i* ]] || exec /usr/bin/zsh`

And [configure Mintty](#configuring-mintty).

### Windows Subsystem for Linux (WSL)

When [WSL](https://docs.microsoft.com/en-us/windows/wsl/) is [installed](https://www.howtogeek.com/249966/how-to-install-and-use-the-linux-bash-shell-on-windows-10/), it uses Windows Console by default, which unfortunately mangles yazpt's Unicode characters and emoji, and so only really supports yazpt's "plain" preset. The good news is that it's quick and easy to use Mintty instead, by [installing WSLtty](https://github.com/mintty/wsltty) and then [configuring it](#configuring-mintty).

You can change your default shell the normal UNIX way, by running `chsh -s /usr/bin/zsh` at a bash or zsh prompt.

### MobaXterm (and its embedded Cygwin-based environment)

Among [MobaXterm's](https://mobaxterm.mobatek.net) eleventy bajillion features is a "local console" which lets you run UNIX programs, including zsh - it's basically a BusyBox + Cygwin + apt-cyg environment, bundled inside MobaXterm. Yazpt works fine on it, except the yolo preset's emoji are rendered as funky little monochrome line drawings.

### Cmder

[Cmder](https://cmder.net) is a popular tool for running UNIX programs on Windows, which basically bundles [ConEmu](#conemu) and some UNIX software together. Unfortunately, there doesn't appear to be a way to install zsh on it.


## Configuring Mintty

You'll get Mintty shortcuts automatically with Cygwin and MSYS2 installations, so using it is mostly effort-free, but you still need to think about it from time to time. For instance, when using Cygwin's `chere` tool to add a "Zsh Prompt Here" item to folders' context menu in Explorer, you'll need to specify the `-t mintty` option: `chere -i -c1 -s zsh -t mintty`.

You should ensure that Mintty is configured with `xterm-256color` as its terminal type (icon > `Options...` > `Terminal` pane > `Type`); otherwise colors, including yazpt's, might not show up. And I personally prefer the `flat-ui` color theme (on the `Looks` tab), but whatever floats your boat.

You'll probably also want to set up color emoji support, especially if you like yazpt's yolo preset: although Windows 8.1 and Windows 10 handle emoji natively, including the ones in yazpt's yolo preset, they render emoji as monochrome line drawings by default. To get a nice full-color emoji experience, you need to [install emoji support for Mintty](https://github.com/mintty/mintty/wiki/Tips#emojis). This even works on Windows 7, where emoji are otherwise only rendered as empty boxes.

The easiest way to install Mintty's emoji support is to use this `svn` command at a zsh prompt:

```sh
emojis_dir=~/.config/mintty/emojis  # Or "$(wslpath $APPDATA)/wsltty/emojis" on WSL
mkdir -p $emojis_dir && cd $emojis_dir && \
svn export https://github.com/iamcal/emoji-data/trunk/img-apple-160 apple
```

_(Note that the directory you export into has to be named "apple", or the next step probably won't work.)_

Then open Mintty's options dialog, select the Text panel, and in the Emojis section, select `apple` in the Styles dropdown, and `align` in the Placement dropdown.


## Other Terminal Emulators

Unless you're using MobaXterm's embedded environment, there are a few alternative terminal emulator you can use in place of the environment's default. While Mintty has never failed me, some of the other choices available are more configurable, look a bit better, and/or have features Mintty lacks, such as a tabbed UI.

### ConEmu

[ConEmu](https://conemu.github.io) has some nice features, like tabs, and makes running cmd.exe and PowerShell more pleasant too. With its default settings, it mangles many of yazpt's Unicode characters, but you can fix that by installing the [DejaVu Sans Mono font](https://dejavu-fonts.github.io) and configuring ConEmu to use it, on its Fonts settings panel; choose DejaVu Sans Mono in the "Main console font" dropdown, and uncheck the "Alternative font" checkbox a bit further down.

As of version 191012, ConEmu doesn't render the yolo preset's emoji correctly, even with DejaVu Sans Mono, so when yazpt detects it's running under ConEmu, it uses emoticons instead.

### MobaXterm (as a WSL terminal)

[MobaXterm](https://mobaxterm.mobatek.net) can be used as a terminal emulator for WSL. Yazpt works fine on it, except the yolo preset's emoji are rendered as funky little monochrome line drawings.

### Terminus

It's heavyweight and feels slower than Mintty or ConEmu, but [Terminus](https://eugeny.github.io/terminus) is very pretty, and renders better-looking color emoji than other Windows terminals I've tried. (I like its "Base16 Default Dark" color scheme, by the way, and the "Fluent" background type.)

Terminus works well with either Cygwin or Windows Subsystem for Linux, but it, MSYS2 and zsh don't all play nicely together (Terminus locks up a lot, only the ANSI 16-color palette is rendered properly, etc).

Terminus v1.0.110's emoji support seems a bit tenuous and flaky on Windows - it's alpha software, after all - so while I've added a few (fairly hacky) workarounds in yazpt to get the yolo preset's emoji working, my tweaks are probably fragile. Those tweaks come into play when yazpt detects that it's running under Terminus; it detects Terminus correctly on Cygwin, but can't so do without a little help when running on WSL: you'll need to manually set the `$TERM_PROGRAM` environment variable (which Terminus normally does itself, but which doesn't work when it's running on WSL). You can set the environment variable before loading yazpt, or else reload yazpt after you've done so:

```sh
export TERM_PROGRAM=Terminus  # (Only needed when running Terminus on WSL)
source ~/.yazpt/yazpt.zsh-theme
```


## Older Windows Versions

I only use older versions of Windows from time to time these days, but when I do, I run zsh and yazpt, using [Cygwin](#cygwin) and Mintty. 

On **Windows 8.1 Pro**, Cygwin works just like as on Windows 10, as [described above](#cygwin), and Mintty can be [configured](#configuring-mintty) as usual too.

On **Windows 7 Professional**, though, yazpt's Unicode characters are rendered poorly; to fix that, install the [DevaVu Sans Mono font](https://dejavu-fonts.github.io), and configure Mintty to use it, on its options dialog's Text panel. Yazpt's yolo preset's emoji are rendered as empty boxes by default, too; fortunately, installing Mintty's emoji support fixes that problem.
