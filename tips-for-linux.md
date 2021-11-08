# Tips for using yazpt on GNU/Linux

Yazpt mostly just works on recently-released Linux distros, with the default terminal emulator, but sometimes a little tweaking is needed to get its Unicode characters and/or emoji rendering well.

I also tested yazpt in XTerm when I could. Regardless of distro, using XTerm is kind of miserable unless you put a little time into configuring it - so much so, in fact, that I only ever run XTerm, or test yazpt in XTerm, with a reasonable [.Xresources file](./resources/Xresources) installed. Using yazpt in XTerm without first [installing](./resources/install-resources.zsh) my Xresources isn't recommended (if you try it, you'll see why 😉). Even when well-configured, in many environments XTerm doesn't render emoji well, so yazpt's yolo preset tries to detect those cases, and substitute emoticons for emoji. Often XTerm can display fairly decent monochrome emoji instead, if you install the [Noto Emoji font](https://github.com/googlefonts/noto-emoji/blob/master/fonts/NotoEmoji-Regular.ttf).


## Distros where yazpt just works

* CentOS 8.3 and CentOS Stream 8, installed as a "server with GUI"
* Debian 10.9, installed with defaults ("Debian desktop environment")
* Kali Linux 2021.1
* KDE neon
* Kubuntu 21.04 and 20.04 LTS
* Linux Mint Cinnamon 20.1 (Ulyssa) and 19.3 (Tricia)
* openSUSE Tumbleweed, running KDE Plasma 5
* Pop!_OS 21.04, 20.10 and 20.04
* Solus 4.2 (Fortitude), running Budgie


## Distros where a little tinkering is needed for best results

### Amazon Linux 2, running MATE Desktop

Yazpt works fine, except MATE Terminal doesn't render yolo's emoji, so it falls back to emoticons.

### antiX 19.3

Yazpt works well out of the box, except emojis aren't rendered in ROXTerm, so the yolo preset falls back to emoticons. For the full color emoji experience, just install the Noto Color Emoji font: `sudo apt install fonts-noto-color-emoji`.

### Bodhi Linux 5.1 (Moksha/Enlightenment)

In Terminology, yazpt's Unicode characters are rendered a bit poorly with the default font; you can fix it by changing the font to, say, DejaVu Sans Mono (right click anywhere in a Terminology window > Settings > Font).

The yolo preset's emoji are also rendered as awful little monochrome line drawings by default, so yazpt automatically switches to emoticons instead. To get emoji in the prompt, just install the [Noto Color Emoji font](https://github.com/googlefonts/noto-emoji/blob/master/fonts/NotoColorEmoji.ttf), by copying it to the ~/.local/share/fonts directory and then running `fc-cache -f` -- next time you load yazpt, it'll automatically use emoji.

### elementary OS 5.1 (Hera)

In elementary OS's default terminal emulator, Pantheon Terminal, everything _almost_ just works (including color emoji), but yazpt's Unicode characters are rendered a bit awkwardly. That can be fixed by [changing the terminal's font](https://elementaryos.stackexchange.com/questions/1149/how-can-i-change-the-default-terminal-font) to DejaVu Sans Mono, which is among the pre-installed fonts.

### Fedora Workstation 33 and 34

GNOME Terminal doesn't render yazpt's Unicode characters very well by default; to fix things up, click `Terminal` in the menu bar > `Preferences` > `Unnamed` (or whatever your profile is named) > `Text` tab > check `Custom font`. Otherwise everything just works.

### Lubuntu 21.04 and 20.04 LTS

QTerminal doesn't render emoji well, so the yolo preset falls back to emoticons. You can get decent monochrome emoji in QTerminal and XTerm by manually installing the [Noto Emoji font](https://github.com/googlefonts/noto-emoji/blob/master/fonts/NotoEmoji-Regular.ttf); copy it to the ~/.local/share/fonts directory, run `fc-cache -f`, and restart your terminal.

### Manjaro 20.0 (Lysia), running XFCE

In Xfce Terminal, most of the yolo preset's emoji aren't rendered; to fix things up, install `noto-fonts-emoji` in Manjaro's "Add/Remove Software" application. The "Dark Pastels" terminal color scheme is much nicer than the default, by the way, especially when using yazpt's sapphire preset.

In XTerm, you can get decent monochrome rendering of yolo's emoji by installing the [Noto Emoji font](https://github.com/googlefonts/noto-emoji/blob/master/fonts/NotoEmoji-Regular.ttf). It's not listed in "Add/Remove Software", so you'll need install it manually, by downloading it and copying it into ~/.local/share/fonts.

### MX Linux 19.4 (patito feo)

In Xfce Terminal, the yolo preset's emoji are rendered as monochrome line drawings by default; if you'd prefer the full-color experience, install `fonts-noto-color-emoji` in MX Package Installer. The "Dark Pastels" terminal color scheme is much nicer than the default, by the way, especially when using yazpt's sapphire preset.

### Puppy Linux FossaPup 9.5

For somewhat nicer rendering of yazpt's Unicode characters in urxvt and rxvt, switch to the DejaVu Sans Mono font, by replacing "Droid Sans Mono" with "DejaVu Sans Mono" twice in ~/.Xdefaults. I haven't found a way to make the yolo preset's emoji work in those terminals.

### Slackware, installed from Live Edition, running KDE

Install the [Noto Color Emoji font](https://github.com/googlefonts/noto-emoji/blob/master/fonts/NotoColorEmoji.ttf) to get nice rendering of the yolo preset's emoji in Konsole, Yakuake, and Xfce Terminal. You can install the [Noto Emoji font](https://github.com/googlefonts/noto-emoji/blob/master/fonts/NotoEmoji-Regular.ttf) for decent monochrome emoji in XTerm, but note that doing so will cause Konsole and Yakuake to revert to monochrome emoji as well.

### Ubuntu Desktop 21.04 (Hirsute Hippo) and 20.04 LTS (Focal Fossa)

GNOME Terminal doesn't render yazpt's Unicode characters very well by default; to fix things up, click `Terminal` in the menu bar > `Preferences` > `Unnamed` (or whatever your profile is named) > `Text` tab > check `Custom font`. Otherwise everything just works.

In XTerm, you can get decent monochrome rendering of yolo's emoji by downloading and manually installing the [Noto Emoji font](https://github.com/googlefonts/noto-emoji/blob/master/fonts/NotoEmoji-Regular.ttf).

### Ubuntu MATE 21.04 and 20.04 LTS

MATE Terminal doesn't render yazpt's Unicode characters very well by default; to fix things up, click the `Edit` menu > `Profile Preferences` > `General` tab > uncheck `Use the system fixed width font`.

In XTerm, you can get decent monochrome rendering of yolo's emoji by downloading and manually installing the [Noto Emoji font](https://github.com/googlefonts/noto-emoji/blob/master/fonts/NotoEmoji-Regular.ttf).

### Zorin OS 15.3 Core

For nicer rendering of yazpt's Unicode characters in GNOME Terminal, click `Edit` in the menu bar > `Preferences` > `Unnamed` (or whatever your profile is named) > `Text` tab > check `Custom font`.
