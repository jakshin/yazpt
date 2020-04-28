Presets configure yazpt by setting its YAZPT_* environment variables.
You can manually source any of these files to load the preset it contains,
or you can use the `yazpt_list_presets` function to list available presets,
and `yazpt_load_preset` to load one, e.g. `yazpt_load_preset tight`.

You can also load a preset from anywhere, by passing its path to `yazpt_load_preset`.
Note that the path must have a slash in it for `yazpt_load_preset` to realize it _is_ a path,
so to load a preset from the current directory, do like `yazpt_load_preset ./foo.zsh`.

You can create your own presets, and put them here in the `presets` folder;
if you name them like `foo-preset.zsh`, they'll automatically be listed by `yazpt_list_presets`,
and can be loaded by `yazpt_load_preset`, with auto-completion support.

The `yazpt_make_preset` function is helpful if you'd like to tinker with yazpt's settings
interactively, until you have them set up like you want, then save only the settings
which differ from the defaults to a new preset file.
