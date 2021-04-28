# Tips for using yazpt on GNU/Linux

Yazpt mostly just works on recently-released Linux distros, with the default terminal emulator, but sometimes a little tweaking is needed to get its Unicode characters and/or emoji rendering well.

I also tested yazpt in XTerm when I could. Regardless of distro, using XTerm is kind of miserable unless you put a little time into configuring it - so much so, in fact, that I only ever run XTerm, or test yazpt in XTerm, with a reasonable [.Xresources file](./resources/Xresources) installed. Using yazpt in XTerm without first [installing](./resources/install-resources.zsh) my Xresources isn't recommended (if you try it, you'll see why 😉). Even when well-configured, in many environments XTerm doesn't render emoji well, so yazpt's yolo preset tries to detect those cases, and substitute emoticons for emoji.


## Distros where yazpt just works

* CentOS 8.3, installed as a "server with GUI"
* KDE neon
* Kubuntu 21.04 and 20.04 LTS
* Linux Mint Cinnamon 20.1 (Ulyssa) and 19.3 (Tricia)
* openSUSE Tumbleweed, running KDE Plasma 5
* Pop!_OS 20.10 and 20.04
* Solus 4.2 (Fortitude), running Budgie


## antiX 19.3

Yazpt works well out of the box, except emojis aren't rendered in ROXTerm, so the yolo preset falls back to emoticons. For the full color emoji experience, just install the Noto Color Emoji font: `sudo apt install fonts-noto-color-emoji`.


## Bodhi Linux 5.1 (Enlightenment)

In Terminology, yazpt's Unicode characters are rendered a bit poorly with the default font; you can fix it by changing the font to, say, DejaVu Sans Mono (right click anywhere in a Terminology window > Settings > Font).

The yolo preset's emoji are also rendered as awful little monochrome line drawings by default, so yazpt automatically switches to emoticons instead. To get emoji in the prompt, just install the [Noto Color Emoji font](https://github.com/googlefonts/noto-emoji/blob/master/fonts/NotoColorEmoji.ttf), by copying it to the `~/.local/share/fonts` directory and then running `fc-cache -f` -- next time you load yazpt, it'll automatically use emoji.


## Debian 10.9, installed with defaults ("Debian desktop environment")

Everything just works, except that in GNOME Terminal, yazpt's default hourglass as rendered as a colored emoji, rather than in monochrome and the same color as the execution time text next to it. If this bothers you, you can fix it by installing the [Noto Emoji font](https://github.com/googlefonts/noto-emoji/blob/master/fonts/NotoEmoji-Regular.ttf). This will also give you decent monochrome rendering of yolo's emoji in XTerm.

Also, `~/.Xresources` isn't automatically loaded, for whatever reason. This leaves XTerm's unfortunate default configuration active. One way to fix it is to use `~/.Xdefaults-HOSTNAME` instead, e.g. `ln -sv ~/.yazpt/resource/Xresources ~/.Xdefaults-$(hostname)`.


## elementary OS 5.1 (Hera)

In elementary OS's default terminal emulator, Pantheon Terminal, everything _almost_ just works (including color emoji), but yazpt's Unicode characters are rendered a bit awkwardly. That can be fixed by [changing the terminal's font](https://elementaryos.stackexchange.com/questions/1149/how-can-i-change-the-default-terminal-font) to DejaVu Sans Mono, which is among the pre-installed fonts.


## Fedora Workstation 33 and 34

GNOME Terminal doesn't render yazpt's Unicode characters very well by default; to fix things up, click `Terminal` in the menu bar > `Preferences` > `Unnamed` (or whatever your profile is named) > `Text` tab > check `Custom font`. Otherwise everything just works.


## Lubuntu 21.04 and 20.04 LTS

QTerminal doesn't render emoji well, so the yolo preset falls back to emoticons. You can get decent monochrome emoji in QTerminal and XTerm by manually installing the [Noto Emoji font](https://github.com/googlefonts/noto-emoji/blob/master/fonts/NotoEmoji-Regular.ttf); copy it to the ~/.local/share/fonts directory, run `fc-cache -f`, and restart your terminal.


## Manjaro 20.0 (Lysia), running XFCE

In Xfce Terminal, most of the yolo preset's emoji aren't rendered; to fix things up, install `noto-fonts-emoji` in Manjaro's "Add/Remove Software" application. The "Dark Pastels" terminal color scheme is much nicer than the default, by the way, especially when using yazpt's sapphire preset.

In XTerm, you can get decent monochrome rendering of yolo's emoji by installing the [Noto Emoji font](https://github.com/googlefonts/noto-emoji/blob/master/fonts/NotoEmoji-Regular.ttf). It's not listed in "Add/Remove Software", so you'll need install it manually, by downloading it and copying it into ~/.local/share/fonts.


## MX Linux 19.4 (patito feo)

In Xfce Terminal, the yolo preset's emoji are rendered as monochrome line drawings by default; if you'd prefer the full-color experience, install `fonts-noto-color-emoji` in "MX Package Installer". The "Dark Pastels" terminal color scheme is much nicer than the default, by the way, especially when using yazpt's sapphire preset.


## Ubuntu Desktop 21.04 (Hirsute Hippo) and 20.04 LTS (Focal Fossa)

GNOME Terminal doesn't render yazpt's Unicode characters very well by default; to fix things up, click `Terminal` in the menu bar > `Preferences` > `Unnamed` (or whatever your profile is named) > `Text` tab > check `Custom font`. Otherwise everything just works.

In XTerm, you can get decent monochrome rendering of yolo's emoji by downloading and manually installing the [Noto Emoji font](https://github.com/googlefonts/noto-emoji/blob/master/fonts/NotoEmoji-Regular.ttf).


## Ubuntu MATE 21.04 and 20.04 LTS

MATE Terminal doesn't render yazpt's Unicode characters very well by default; to fix things up, click the `Edit` menu > `Profile Preferences` > `General` tab > uncheck `Use the system fixed width font`.

In XTerm, you can get decent monochrome rendering of yolo's emoji by downloading and manually installing the [Noto Emoji font](https://github.com/googlefonts/noto-emoji/blob/master/fonts/NotoEmoji-Regular.ttf).
