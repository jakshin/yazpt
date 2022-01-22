# Tips for using yazpt on GNU/Linux

Yazpt mostly just works on recently-released Linux distros, with the default terminal emulator, but sometimes a little tweaking is needed to get its Unicode characters and/or emoji rendering well.


## Distros where yazpt just works

* CentOS 8.3 and CentOS Stream 8, installed as a "server with GUI"
* Debian 10.9 and 11.x, installed with defaults ("Debian desktop environment")
* Kali Linux 2021.1, 2021.3
* KDE neon
* Kubuntu 20.04 and newer
* Linux Mint 20.1 and newer (Cinnamon, MATE or XFCE)
* openSUSE Leap 15.3 and openSUSE Tumbleweed, running KDE Plasma 5
* Pop!_OS 20.04 and newer

In many of these distros, yazpt's yolo preset uses emoticons by default when running on XTerm, but you can [upgrade to monochrome emoji](#xterm-and-emoji) by installing the [Noto Emoji font](https://github.com/googlefonts/noto-emoji/blob/main/fonts/NotoEmoji-Regular.ttf).
<p align="center">•</p>


## Distros where a little tinkering is needed for best results

### Amazon Linux 2, running MATE Desktop

Yazpt works fine, except MATE Terminal doesn't render yolo's emoji, so it falls back to emoticons.

### antiX 19.3

Yazpt works well out of the box, except emojis aren't rendered in ROXTerm, so the yolo preset falls back to emoticons. For the full color emoji experience, just install the Noto Color Emoji font: `sudo apt install fonts-noto-color-emoji`.

### Bodhi Linux 5.1 and 6.0 (Moksha/Enlightenment)

In Terminology, yazpt's Unicode characters are rendered a bit poorly with the default font; you can fix it by changing the font to, say, DejaVu Sans Mono (right click anywhere in a Terminology window > Settings > Font).

Terminology also renders the yolo preset's emoji as awful little monochrome line drawings, so yazpt automatically switches to emoticons instead. Emoticons are also used in XTerm by default, but you can easily [upgrade to monochrome emoji](#xterm-and-emoji) there.

### elementary OS 5.1 (Hera) and 6 (Odin)

In elementary OS's default terminal emulator, Pantheon Terminal, everything _almost_ just works (including color emoji), but yazpt's Unicode characters are rendered a bit awkwardly. That can be fixed by [changing the terminal's font](https://elementaryos.stackexchange.com/questions/1149/how-can-i-change-the-default-terminal-font) to DejaVu Sans Mono, which is among the pre-installed fonts.

### Fedora Workstation 33 and newer

GNOME Terminal doesn't render yazpt's Unicode characters very well by default; to fix things up, click `Terminal` in the menu bar > `Preferences` > `Unnamed` (or whatever your profile is named) > `Text` tab > check `Custom font`. Otherwise everything just works.

### Lubuntu 20.04 LTS and newer

QTerminal doesn't render emoji well, so the yolo preset falls back to emoticons. You can get decent monochrome emoji in QTerminal and XTerm by manually installing the [Noto Emoji font](https://github.com/googlefonts/noto-emoji/blob/main/fonts/NotoEmoji-Regular.ttf); copy it to the ~/.local/share/fonts directory, run `fc-cache -f`, and restart your terminal.

### Manjaro 20.0 (Lysia), running XFCE

In Xfce Terminal, most of the yolo preset's emoji aren't rendered; to fix things up, install `noto-fonts-emoji` in Manjaro's "Add/Remove Software" application. That will also make XTerm start [displaying monochrome emoji](#xterm-and-emoji) instead of emoticons.

Xfce Terminal's "Dark Pastels" color scheme is much nicer than the default, by the way, especially when using yazpt's sapphire preset.

### MX Linux 19.4 and 21

In Xfce Terminal, the yolo preset's emoji are rendered as monochrome line drawings by default; if you'd prefer the full-color experience, install `fonts-noto-color-emoji` in MX Package Installer. The "Dark Pastels" terminal color scheme is much nicer than the default, by the way, especially when using yazpt's sapphire preset.

### Puppy Linux FossaPup 9.5

For somewhat nicer rendering of yazpt's Unicode characters in urxvt and rxvt, switch to the DejaVu Sans Mono font, by replacing "Droid Sans Mono" with "DejaVu Sans Mono" twice in ~/.Xdefaults. I haven't found a way to make the yolo preset's emoji work in those terminals.

### Slackware, installed from Live Edition, running KDE

Install the [Noto Color Emoji font](https://github.com/googlefonts/noto-emoji/blob/main/fonts/NotoColorEmoji.ttf) to get nice rendering of the yolo preset's emoji in Konsole, Yakuake, and Xfce Terminal. You can install the [Noto Emoji font](https://github.com/googlefonts/noto-emoji/blob/main/fonts/NotoEmoji-Regular.ttf) for decent [monochrome emoji in XTerm](#xterm-and-emoji), but note that doing so will cause Konsole and Yakuake to revert to monochrome emoji as well.

### Solus 4.3 (with Budgie, GNOME, MATE, or Plasma)

Color emoji aren't rendered in Konsole by default; you can fix that by [adjusting some font settings](https://gist.github.com/IgnoredAmbience/7c99b6cf9a8b73c9312a71d1209d9bbb). In MATE Terminal, yazpt's Unicode characters look a bit nicer if you go to `Edit` > `Profile Preferences` > `General` tab and uncheck `Use the system fixed width font`.

### Ubuntu Desktop 20.04 LTS (Focal Fossa), 21.04 (Hirsute Hippo), 21.10 (Impish Indri)

GNOME Terminal doesn't render yazpt's Unicode characters very well by default; to fix things up, click `Terminal` in the menu bar > `Preferences` > `Unnamed` (or whatever your profile is named) > `Text` tab > check `Custom font`. Otherwise everything just works.

In XTerm, yazpt's yolo preset uses emoticons by default, but you can easily [upgrade to monochrome emoji](#xterm-and-emoji), by installing the [Noto Emoji font](https://github.com/googlefonts/noto-emoji/blob/main/fonts/NotoEmoji-Regular.ttf).

### Ubuntu MATE 20.04 LTS and newer

MATE Terminal doesn't render yazpt's Unicode characters very well by default; to fix things up, click the `Edit` menu > `Profile Preferences` > `General` tab > uncheck `Use the system fixed width font`.

In XTerm, yazpt's yolo preset uses emoticons by default, but you can easily [upgrade to monochrome emoji](#xterm-and-emoji).

### Zorin OS Core 15.3 and 16

For nicer rendering of yazpt's Unicode characters in GNOME Terminal, click `Edit` in the menu bar > `Preferences` > `Unnamed` (or whatever your profile is named) > `Text` tab > check `Custom font`.

XTerm on Zorin can [display yolo's emoji](#xterm-and-emoji) if you install a font, though only in monochrome.
<p align="center">•</p>


## XTerm and emoji

Regardless of distro, using XTerm is kind of miserable unless you put a little time into configuring it via an [.Xresources file](./resources/Xresources). (Yazpt includes one, and it's [easy to install](./resources/install-resources.zsh).)

Even when it's well-configured, in many environments XTerm doesn't render emoji well, so yazpt's yolo preset tries to detect those cases, and substitute emoticons for emoji. But in many distros, you can upgrade from emoticons to fairly decent monochrome emoji in XTerm, by installing the [Noto Emoji font](https://github.com/googlefonts/noto-emoji/blob/main/fonts/NotoEmoji-Regular.ttf); usually that involves copying it into the ~/.local/share/fonts directory, running `fc-cache -f`, and restarting XTerm.
