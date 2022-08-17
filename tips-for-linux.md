# Tips for using yazpt on GNU/Linux

Yazpt mostly just works on recently-released Linux distros, with the distro's standard terminal emulator and default settings,
but sometimes a little tweaking is needed to get its Unicode characters and/or emoji rendering well.


## Distros where yazpt just works, with distro default settings

* CentOS 8.3, CentOS Stream 8 and 9, installed as a "server with GUI"
* Debian 10.9 and 11.x, installed with defaults ("Debian desktop environment")
* Kali Linux 2021.1 and newer
* KDE neon
* Kubuntu 20.04 and newer
* Linux Mint 20.1 and newer (Cinnamon, MATE or XFCE)
* openSUSE Leap 15.3 and newer (KDE Plasma 5)
* openSUSE Tumbleweed (KDE Plasma 5)
* Pop!_OS 20.04 and newer
* Solus Budgie 4.3
* Solus GNOME 4.3
* Zorin OS 16.1

In some other distros, everything _almost_ just works, but yazpt's Unicode characters are rendered a bit awkwardly in the distro's standard terminal with default settings, and the fix is as simple as checking or unchecking a single checkbox:

* Solus MATE 4.3
* Ubuntu Desktop 20.04 and newer
* Ubuntu MATE 20.04 and newer

In GNOME Terminal, just click `Terminal` in the menu bar > `Preferences` > `Unnamed` (or whatever your profile is named) > `Text` tab > check `Custom font`. In MATE Terminal, click the `Edit` menu > `Profile Preferences` > `General` tab > uncheck `Use the system fixed width font`.


## Troubleshooting

If yazpt's Unicode characters look awkward (e.g. some of the Unicode characters are too small, or too big, or characters look squished together), try switching terminal fonts. Yazpt looks great in most popular monospace fonts, so just pick one and try it out. You can also run the `.yazpt_check` function at a prompt to see how the various characters look. If you don't feel like experimenting, though, DejaVu Sans Mono is a good choice that's usually preinstalled, or available via package manager; it's [easy to download](https://dejavu-fonts.github.io/Download.html) if not.

If the yolo preset's emoji don't render properly, sometimes you can fix it by installing the Noto Color Emoji font. It's usually available via package manager, or you can [download it](https://github.com/googlefonts/noto-emoji/blob/main/fonts/NotoColorEmoji.ttf) and install it manually.

If yazpt looks okay but has no colors, you probably need to adjust your `$TERM` environment variable. For example, if it's empty or `xterm`, change it to `xterm-256color`, or if it's `screen`, try `screen-256color`.


## XTerm

In many distros, XTerm doesn't render emoji well, so yazpt's yolo preset tries to detect those cases, and substitute emoticons for emoji. But you can often upgrade from emoticons to fairly decent monochrome emoji in XTerm, by installing the [Noto Emoji font](https://github.com/googlefonts/noto-emoji/blob/9a5261d871451f9b5183c93483cbd68ed916b1e9/fonts/NotoEmoji-Regular.ttf). If the distro has no GUI way to install fonts, copy it into the ~/.local/share/fonts directory, and run `fc-cache -f`; either way, restart XTerm afterward.

Regardless of distro, using XTerm is kind of miserable unless you put a little time into configuring it.
For convenience, Yazpt bundles an [.Xresources file](./resources/Xresources) containing XTerm settings.
It's [easy to install](./resources/install-resources.zsh).

<!--
Distros where I know that installing the Noto Emoji font will let XTerm render monochrome emoji:
- Bodhi Linux 5.1 and 6.0 (Moksha/Enlightenment)
- Lubuntu 20.04 and newer (but only bad line-drawing emoji; same in QTerminal)
- Manjaro 20.0 (Lysia), running XFCE
- Ubuntu Desktop 20.04 and newer
- Ubuntu MATE 20.04 and newer
-->
<p align="center">•</p>


## Configuring various distros for best results

### Bodhi Linux 5.1 and 6.0 (Moksha/Enlightenment)

In Terminology, yazpt's Unicode characters are rendered a bit poorly with the default font; you can fix it by changing the font to, say, DejaVu Sans Mono (right click anywhere in a Terminology window > Settings > Font). Terminology also renders the yolo preset's emoji as awful little monochrome line drawings, so yazpt automatically switches to emoticons instead.

### elementary OS 5.1 and 6.0

In elementary OS's default terminal emulator, Pantheon Terminal, everything _almost_ just works (including color emoji), but yazpt's Unicode characters are rendered a bit awkwardly. That can be fixed by [changing the terminal's font](https://elementaryos.stackexchange.com/questions/1149/how-can-i-change-the-default-terminal-font) to DejaVu Sans Mono, which is among the pre-installed fonts.

### EndeavourOS

Xfce Terminal doesn't render emoji well on EndeavourOS, so the yolo preset falls back to emoticons. You can get full-color emoji by installing the Noto Color Emoji font: `sudo pacman -S noto-fonts-emoji`

### Fedora Workstation 36

Yazpt's Unicode characters aren't rendered very well by default, in either GNOME Terminal or XTerm. The solution is to install the DejaVu Sans Mono font: `sudo dnf install dejavu-sans-mono-fonts`

### Lubuntu 20.04 and newer

QTerminal doesn't render emoji well, so the yolo preset falls back to emoticons. You can get monochrome line-drawing emoji by installing the [Noto Emoji font](https://github.com/googlefonts/noto-emoji/blob/9a5261d871451f9b5183c93483cbd68ed916b1e9/fonts/NotoEmoji-Regular.ttf).

### MX Xfce 19.4 and newer

In Xfce Terminal, the yolo preset's emoji are rendered as monochrome line drawings by default; for the full-color experience, install `fonts-noto-color-emoji` in MX Package Installer.

### MX KDE 21.1

Konsole renders emoji as monochrome line drawings. You can upgrade to proper color emoji by [adjusting some font settings](./resources/99-noto-color-emoji.conf).

### Solus Plasma 4.3

Konsole renders emoji as monochrome line drawings. You can upgrade to proper color emoji by [adjusting some font settings](./resources/99-noto-color-emoji.conf).
