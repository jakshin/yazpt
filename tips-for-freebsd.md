# Tips for using yazpt on FreeBSD and derivative BSDs

I have yet to encounter a FreeBSD/derivative installation that handles emoji in terminal out of the box, so yazpt's yolo presets defaults to using emoticons when it detects that it's running under FreeBSD. Run `sudo pkg install noto-emoji` to get monochrome emoji with the yolo preset in XTerm (but not MATE Terminal or Xfce Terminal, sadly).


## FuryBSD 12.1, running XFCE   

Yazpt works rather poorly out of the box in Xfce Terminal; to fix it, add this to your `~/.zshenv` (or your shell's rough equivalent, if zsh isn't your login shell):   

```sh
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 LC_CTYPE=en_US.UTF-8
```


## GhostBSD 20.04.1

For better rendering of yazpt's Unicode characters in MATE Terminal, uncheck its "Use the system fixed width font" checkbox in your profile preferences.
