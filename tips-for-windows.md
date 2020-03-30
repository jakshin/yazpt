# Tips for using yazpt on Windows

There are a handful of ways to run zsh and git on Windows, but I've only done so using [Cygwin](https://cygwin.com), and I haven't tried it on server versions of Windows.

Once you've installed Cygwin's zsh, the easiest way to make it your default shell, rather than bash, is by changing your Windows `SHELL` environment variable to `/usr/bin/zsh`.

Windows' native console doesn't render yazpt very well; Mintty is a far better choice, for a variety of reasons. You'll get Mintty shortcuts automatically with a normal Cygwin installation, so using it is mostly effort-free, but you still need to think about it from time to time. For instance, when using Cygwin's `chere` tool to add a "Zsh Prompt Here" to folders in Explorer, you'll need to specify the `-t mintty` option:

```
chere -i -c1 -s zsh -t mintty
```

## Color Emoji in Cygwin Mintty

Although Windows 8.1 and Windows 10 handle emoji, including the ones in yazpt's yolo preset, they render them as monochrome line drawings. To get color emoji, you need to [install emoji support for Mintty](https://github.com/mintty/mintty/wiki/Tips#emojis). The easiest way, if you have the Subversion CLI installed already, is to run this at a zsh prompt:

```sh
mkdir -p ~/.config/mintty/emojis && \
cd ~/.config/mintty/emojis && \
svn export https://github.com/iamcal/emoji-data/trunk/img-apple-160 apple
```

*(Note that the directory you export into has to be named "apple", or the next step probably won't work.)*

Then open Mintty's options dialog, select the Text panel, and in the Emojis section, select `apple` in the Styles dropdown, and `align` in the Placement dropdown.


## Windows 10 Pro (version 1909)

Mintty 3.x uses the Lucida Console font by default, and yazpt is rendered nicely, including its Unicode characters. The yolo preset's emoji are rendered as ugly little line drawings, though; install color emoji support for Mintty as described above for a slightly nicer experience.


## Windows 8.1 Pro

Mintty 3.x uses the Lucida Console font by default, and yazpt is rendered nicely, including its Unicode characters. The yolo preset's emoji are rendered as ugly little line drawings, though; install color emoji support for Mintty as described above for a slightly nicer experience.


## Windows 7 Professional

Yazpt's Unicode characters are rendered poorly. To fix it, install the [DevaVu Sans Mono font](https://dejavu-fonts.github.io), and configure Mintty to use it, on its options dialog's Text panel.

The yolo preset's emoji emoji aren't rendered at all. To fix it, install color emoji support for Mintty as described above.
