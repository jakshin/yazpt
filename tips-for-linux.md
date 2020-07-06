# Tips for using yazpt on GNU/Linux

Yazpt mostly just works on recently-released Linux distros, but sometimes a little tweaking is needed to get its Unicode characters and/or emoji rendering well. Here are a few tips based on my experiences using yazpt on various distros, primarily in their default terminal emulators (usually GNOME Terminal or a related project, or Konsole).

I also tested yazpt in XTerm when I could. Regardless of distro, using XTerm is kind of miserable unless you put a little time into configuring it - so much so, in fact, that I only ever run XTerm, or test yazpt in XTerm, with a reasonable [.Xresources file](./resources/Xresources) installed. Using yazpt in XTerm without first [installing](./resources/install-resources.zsh) my `.Xresources` isn't recommended (if you try it, you'll see why 😉). Even when well-configured, in many environments XTerm doesn't render emoji well, so yazpt's yolo preset tries to detect those cases, and substitute emoticons for emoji.


## Bodhi Linux 5.1 (Enlightenment)

In Terminology, yazpt's Unicode characters are rendered a bit poorly with the default font; you can fix it by changing the font to, say, DejaVu Sans Mono (right click anywhere in a Terminology window > Settings > Font).

The yolo preset's emoji are also rendered as awful little monochrome line drawings by default, so yazpt automatically switches to emoticons instead. To get emoji in the prompt, just install the [Noto Color Emoji font](https://github.com/googlefonts/noto-emoji/blob/master/fonts/NotoColorEmoji.ttf), by copying it to the `~/.local/share/fonts` directory and then running `fc-cache -f` -- next time you load yazpt, it'll automatically use emoji.


## CentOS 8.1, installed as a "server with GUI"

By default, all of yazpt's emoji and the `<exectime>` segment's Unicode hourglass get rendered as ugly "missing glyph" boxes in GNOME Terminal. You can fix both issues by installing the [Noto Color Emoji](https://github.com/googlefonts/noto-emoji/blob/master/fonts/NotoColorEmoji.ttf) and [Noto Emoji](https://github.com/googlefonts/noto-emoji/blob/master/fonts/NotoEmoji-Regular.ttf) fonts.

CentOS doesn't automatically load `~/.Xresources`, which I suppose has something to do with the transition to Wayland. This leaves XTerm's unfortunate default configuration active. One way to address the problem is to use `~/.Xdefaults-HOSTNAME` instead, e.g. `ln -sv ~/.yazpt/resource/Xresources ~/.Xdefaults-$(hostname)`.


## Debian 10.3, installed with default settings

In GNOME Terminal, yazpt's default hourglass as rendered as a colored emoji, rather than in monochrome and the same color as the execution time text next to it. If this bothers you, you can fix it by installing the [Noto Emoji font](https://github.com/googlefonts/noto-emoji/blob/master/fonts/NotoEmoji-Regular.ttf). This will also give you decent monochrome rendering of yolo's emoji in XTerm.

On a default installation of Debian, `~/.Xresources` isn't automatically loaded, I guess because Wayland. This leaves XTerm's unfortunate default configuration active. One way to fix it is to use `~/.Xdefaults-HOSTNAME` instead, e.g. `ln -sv ~/.yazpt/resource/Xresources ~/.Xdefaults-$(hostname)`.


## elementary OS 5.1 (Hera)

In elementary OS's default terminal emulator, Pantheon Terminal, everything _almost_ just works (including color emoji), but yazpt's Unicode characters are rendered a bit awkwardly. That can be fixed by [changing the terminal's font](https://elementaryos.stackexchange.com/questions/1149/how-can-i-change-the-default-terminal-font) to DejaVu Sans Mono, which is among the pre-installed fonts.


## Fedora Workstation 32

GNOME Terminal doesn't render yazpt's Unicode characters very well by default; to fix things up, click `Terminal` in the menu bar > `Preferences` > `Unnamed` (or whatever your profile is named) > `Text` tab > check `Custom font`. Otherwise everything just works.


## Kali Linux 2020.2

In both LXTerminal and QTerminal, everything works out of the box -- except emoji, so yazpt's yolo theme automatically downgrades to emoticons. To get emoji in the prompt, just install the [Noto Color Emoji font](https://github.com/googlefonts/noto-emoji/blob/master/fonts/NotoColorEmoji.ttf), by copying it to the `~/.local/share/fonts` directory and then running `fc-cache -f` -- next time you load yazpt, it'll automatically use emoji.


## Kubuntu 20.04

In Konsole, yazpt works well out of the box, except the default hourglass Unicode character is rendered as a color emoji instead of monochrome in the same color as nearby text, as intended. I haven't found a way to fix this. 🤷


## Linux Mint Cinnamon 19.3 (Tricia)

Everything just works out of the box.


## Linux Mint Cinnamon 18.3 (Sylvia)

Everything works well out of the box, except the yolo preset's emoji, which are rendered poorly in GNOME Terminal. You can upgrade to correctly-rendered but monochrome emoji by installing the [Noto Emoji font](https://github.com/googlefonts/noto-emoji/blob/master/fonts/NotoEmoji-Regular.ttf).


## Manjaro 20.0 (Lysia), running XFCE

In Xfce Terminal, most of the yolo preset's emoji aren't rendered; to fix things up, install `noto-fonts-emoji` in Manjaro's "Add/Remove Software" application. The "Dark Pastels" terminal color scheme is much nicer than the default, by the way, especially when using yazpt's sapphire preset.

In XTerm, you can get decent monochrome rendering of yolo's emoji by installing the [Noto Emoji font](https://github.com/googlefonts/noto-emoji/blob/master/fonts/NotoEmoji-Regular.ttf). It's not listed in "Add/Remove Software", so you'll need install it manually, by downloading it and copying it into ~/.local/share/fonts.


## MX Linux 19.1 (patito feo)

In Xfce Terminal, the yolo preset's emoji are rendered as monochrome line drawings by default; if you'd prefer the full-color experience, install `fonts-noto-color-emoji` in "MX Package Installer". The "Dark Pastels" terminal color scheme is much nicer than the default, by the way, especially when using yazpt's sapphire preset.


## openSUSE Tumbleweed, running KDE Plasma 5

Everything just works out of the box.

In XTerm, you can get decent monochrome rendering of yolo's emoji by downloading the [Noto Emoji font](https://github.com/googlefonts/noto-emoji/blob/master/fonts/NotoEmoji-Regular.ttf), and manually installing it with Font Viewer - BUT note that doing so will cause Konsole to switch from full-color emoji to awkward monochrome emoji. Lame. 😞


## Pop!_OS 20.04

Everything just works out of the box.


## Solus 4.1 (Fortitude), running Budgie

GNOME Terminal doesn't render yazpt's Unicode characters very well by default; to fix things up, click the kebab button in the menu bar > `Preferences` > `Unnamed` (or whatever your profile is named) > `Text` tab > check `Custom font`. Otherwise everything just works.

Solus is a very pretty distro, by the way, but I found the default theme a bit too dark - choosing the Adapta-Nokto-Eta theme in Budgie Desktop Settings > Style > Widgets made everything more comfortable.


## Ubuntu 20.04 (Focal Fossa) and 19.10 (Eoan Ermine)

GNOME Terminal doesn't render yazpt's Unicode characters very well by default; to fix things up, click `Terminal` in the menu bar > `Preferences` > `Unnamed` (or whatever your profile is named) > `Text` tab > check `Custom font`. Otherwise everything just works.

In XTerm, you can get decent monochrome rendering of yolo's emoji by downloading and manually installing the [Noto Emoji font](https://github.com/googlefonts/noto-emoji/blob/master/fonts/NotoEmoji-Regular.ttf).


## Ubuntu 18.04 (Bionic Beaver)

GNOME Terminal doesn't render yazpt's Unicode characters very well by default; to fix things up, click the `Edit` menu > `Preferences` > `Unnamed` (or whatever your profile is named) > `Text` tab > check `Custom font`. Otherwise everything just works.


## Ubuntu 16.04 (Xenial Xerus)

GNOME Terminal doesn't render yazpt's Unicode characters very well by default; to fix things up, click the `Edit` menu > `Profile Preferences` > `General` tab > check `Custom font`.

The yolo preset's emoji look terrible in GNOME Terminal; to upgrade to correctly-rendered but monochrome emoji, install the [Noto Emoji font](https://github.com/googlefonts/noto-emoji/tree/master/fonts/NotoEmoji-Regular.ttf), and create `~/.config/fontconfig/fonts.conf` with this text:

```xml
<alias>
  <family>monospace</family>
  <prefer>
    <family>Noto Emoji</family>
  </prefer>
</alias>
```


## Ubuntu MATE 20.04 and 19.10

MATE Terminal doesn't render yazpt's Unicode characters very well by default; to fix things up, click the `Edit` menu > `Profile Preferences` > `General` tab > uncheck `Use the system fixed width font`.

In XTerm, you can get decent monochrome rendering of yolo's emoji by downloading and manually installing the [Noto Emoji font](https://github.com/googlefonts/noto-emoji/blob/master/fonts/NotoEmoji-Regular.ttf).
