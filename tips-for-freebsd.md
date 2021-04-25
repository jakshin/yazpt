# Tips for using yazpt on FreeBSD and derivative BSDs

I have yet to encounter a FreeBSD/derivative installation that handles emoji in terminal out of the box, so yazpt's yolo presets defaults to using emoticons when it detects that it's running under FreeBSD.


## FuryBSD 12.1**, running XFCE   

Yazpt works rather poorly out of the box in Xfce Terminal; to fix it, add this to your `~/.zshenv` (or your shell's rough equivalent, if zsh isn't your login shell):   

```sh
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 LC_CTYPE=en_US.UTF-8
```

Install the `noto-emoji` package to get an hourglass character in the exectime segment, and monochrome emoji with the yolo preset in XTerm (but not Xfce Terminal), and/or install `noto-extra` to get a smaller hourglass character that looks a little better.


## GhostBSD 20.04.1

For better rendering of yazpt's Unicode characters in MATE Terminal, uncheck its "Use the system fixed width font" checkbox in your profile preferences.

Install the `noto-emoji` package to get an hourglass character in the exectime segment, and monochrome emoji with the yolo preset in XTerm (but not Xfce Terminal), and/or install `noto-extra` to get a smaller hourglass character that looks a little better.
