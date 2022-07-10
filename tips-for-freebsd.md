# Tips for using yazpt on FreeBSD derivatives


### GhostBSD 21+

For better rendering of yazpt's Unicode characters in MATE Terminal, uncheck its "Use the system fixed width font" checkbox in your profile preferences.

The yolo preset's emoji don't work out of the box, so emoticons are used by default. It's easy to fix: run `sudo pkg install noto-emoji` to get emoji support in MATE Terminal and XTerm.


### MidnightBSD 2.1.7

The yolo preset's emoji don't work out of the box, so emoticons are used by default. You can get emoji support in Xfce Terminal and XTerm with `sudo mport install noto-emoji`.


### NomadBSD 130R

NomadBSD uses Sakura as its default terminal, and has it configured with Source Code Pro as its font, which doesn't present yazpt's Unicode characters particularly well. There are a bunch of other monospace fonts preinstalled and available for use in Sakura, nearly all of which make yazpt look better.

The yolo preset's emoji don't work out of the box, so emoticons are used by default. Running `sudo pkg install noto-emoji` fixes things up, in both Sakura and XTerm.
