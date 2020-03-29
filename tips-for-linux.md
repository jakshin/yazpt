# Tips for using yazpt on GNU/Linux

Yazpt mostly just works on recently-released Linux distros, but sometimes a little tweaking is needed to get its Unicode characters and/or emoji rendering well. Here are a few tips based on my experiences using yazpt on various distros.

Regardless of distro, using XTerm is kind of miserable unless you put a little time into configuring it. Using a reasonable [.Xresources file](./resources/Xresources) goes a long way.


## Linux Mint Cinnamon 19.3 (Tricia)

_GNOME Terminal 3.28.1, XTerm v330_

Everything just works, out of the box.


## Linux Mint Cinnamon 18.3 (Sylvia)

_GNOME Terminal 3.18.3, XTerm v322_

Everything works well out of the box, except the yolo preset, whose emoji renders poorly in GNOME Terminal. You can upgrade to correctly-rendered but monochrome emojis by installing the [Noto Emoji font](https://github.com/googlefonts/noto-emoji/blob/master/fonts/NotoEmoji-Regular.ttf).


## openSUSE Tumbleweed with KDE Plasma

_Konsole 19.12.3, XTerm v345_

Everything just works out of the box.

"Hack" is the default font in Konsole, and it's nice. XTerm is configured to use black text on a white background by default, which is especially awful - [.Xresources](./resources/Xresources) to the rescue!


## Ubuntu 19.10 (Eoan Ermine)

_GNOME Terminal 3.34.2, XTerm v348_

Terminal doesn't render yazpt's Unicode characters very well by default; to fix it, click `Terminal` in the menu bar > `Preferences` > `Unnamed` (or whatever your profile is named) > `Text` tab > check `Custom font`.

in XTerm, the blues preset's exit-status characters aren't rendered (which is weird, because they _are_ rendered on earlier Ubuntu versions); to fix it, use my [.Xresources file](./resources/Xresources), or at least its `xterm*faceName: DejaVu Sans Mono` line (or a similar one).


## Ubuntu 18.04 (Bionic Beaver)

_GNOME Terminal 3.28.2, XTerm v330_

Terminal doesn't render yazpt's Unicode characters very well by default; to fix it, click the `Edit` menu > `Preferences` > `Unnamed` (or whatever your profile is named) > `Text` tab > check `Custom font`.


## Ubuntu 16.04 (Xenial Xerus)

_GNOME Terminal 3.18.3, XTerm v322_

Terminal doesn't render yazpt's Unicode characters very well by default; to fix it, click the `Edit` menu > `Profile Preferences` > `General` tab > check `Custom font`.

The yolo preset's emoji look terrible in Terminal; to upgrade to correctly-rendered but monochrome emojis, install the [Noto Emoji font](https://github.com/googlefonts/noto-emoji/tree/master/fonts/NotoEmoji-Regular.ttf), and create `~/.config/fontconfig/fonts.conf` with this text:

```xml
<alias>
  <family>monospace</family>
  <prefer>
    <family>Noto Emoji</family>
  </prefer>
</alias>
```
