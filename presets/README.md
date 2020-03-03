Presets configure yazpt by setting its YAZPT_* environment variables.
You can manually source any of these files to load the preset it contains,
or you can use the `yazpt_list_presets` function to list available presets,
and `yazpt_load_preset` to load one, e.g. `yazpt_load_preset tight`.

You can create your own presets, and put them here in the `presets` folder;
if you name them like `foo-preset.zsh`, they'll automatically be listed
by `yazpt_list_presets`, and can be loaded by `yazpt_load_preset`,
with auto-completion support.
