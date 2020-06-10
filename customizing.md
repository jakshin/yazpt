# Customizing Yazpt

Yazpt thinks of itself as an add-on or power-up, not a replacement, for zsh's built-in prompt logic, which uses the value of the `PS1` and `RPS1` environment variables to control what appears in the prompt.

Using the `YAZPT_LAYOUT` and `YAZPT_RLAYOUT` environment variables as templates, yazpt builds new values for `PS1` and `RPS1` just before each time zsh uses them to display the prompt. So anything that's valid and useful in `PS1`/`RPS1` is okay in `YAZPT_LAYOUT`/`YAZPT_RLAYOUT`, but _also_ - and here's where the power-up part comes in - you can add "segments" to `YAZPT_LAYOUT` and/or `YAZPT_RLAYOUT`, i.e. simple bits of text like `<git>`, which yazpt will expand for you into something complex and useful, such as a full summary of your Git working state.

Yazpt's behavior as it interprets `YAZPT_LAYOUT` and `YAZPT_RLAYOUT` can be configured and customized in a variety of ways, some of them very easy, and others a bit more involved.

_(Note that zsh's `prompt_subst` option is very powerful, but might also be considered a bit dangerous, depending on how much control you have of your environment variables, so yazpt keeps it turned off by default; if you want to turn `prompt_subst` on so you can use parameter/arithmetic expansion and/or command substitution in your prompt, you'll need to create a file at `~/.yazpt_allow_subst` to tell yazpt not to force it back off.)_


## Load a preset

The easiest way to configure yazpt's appearance is to load one of its presets. You can see a list of them using the `yazpt_list_presets` function, or by browsing the [presets](./presets) directory (a comment at the top of each preset describes it).

If you've [installed](./resources/install-resources.zsh) yazpt's [integration with zsh's prompt theme system](./resources/prompt_yazpt_setup), you can preview a preset by running like `prompt -p "yazpt sapphire"` (note the quotes), or preview all of them by running `prompt -p "yazpt all"`. Your current directory should be in a Git repo or Subversion working copy if you want to preview the VCS parts of the prompt.

Once you've decided on a preset, use the `yazpt_load_preset` function to load it. It's usually handiest to put this in your `.zshrc`.

Or, if you're using zsh's prompt theme system, you can instead run `prompt yazpt`, optionally with a preset, like `prompt yazpt spearmint` (note the lack of quotes), if you prefer.


## Set YAZPT_* environment variables

The next step in customization is to set yazpt's environment variables directly. Every option yazpt understands can be controlled by an environment variable whose name begins with `YAZPT_` (presets are just groups of statements that set a few environment variables at the same time).

All of the environment variables are documented in [yazpt's default preset](./presets/default-preset.zsh), which is automatically loaded with yazpt, so the values in that file serve as defaults. You can override those values to anything you'd like, changing the characters and colors yazpt uses, hiding certain VCS statuses, etc.

You also need to use environment variables to customize yazpt's _behavior_ (as opposed to appearance). If you want to disable VCSs or change their priority, change `YAZPT_VCS_ORDER`. If you know that your Git repos, Subversion working copies and/or TFVC local workspaces will always be in subdirectories of certain root directories, like say `~/Code`, you can configure `YAZPT_GIT_PATHS`, `YAZPT_SVN_PATHS` and/or `YAZPT_TFVC_PATHS` for better prompt performance when you're working in other directories, i.e. that'll never contain repos, working copies, or local workspaces.


## Set the YAZPT_LAYOUT and YAZPT_RLAYOUT environment variables

`YAZPT_LAYOUT` and `YAZPT_RLAYOUT` are the most interesting variables to play with. You can put anything into them that [zsh's prompt expansion](http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html) can handle, plus:

* Any segment supported by Yazpt: `<char>`, `<cwd>`, `<exectime>`, `<exit>`, `<git>`, `<svn>`, or `<tfvc>`
  (or `<vcs>` to handle Git/Subversion/TFVC automatically, as configured in `YAZPT_VCS_ORDER`)

* One or more "separators", which are sort of like segments, but look like `<?text>` (with the question mark
  just after the opening bracket), and only output the text in them if the text in `PS1`/`RPS1` both just before
  and just after them was created by a yazpt segment

Note that yazpt expects zsh's `prompt_percent` option to be on (and will turn it on for you when it loads). It'll work just fine with the `prompt_bang`, `prompt_subst`, and `prompt_sp` [options](http://zsh.sourceforge.net/Doc/Release/Options.html#Prompting) on or off, though, so set those however you'd like.

Since yazpt needs to parse `YAZPT_LAYOUT` and `YAZPT_RLAYOUT` looking for segments, which are surrounded by angle brackets, you need to escape those characters to include them literally. Inside a separator, escape both angle brackets with a `<`, so like `<<.<>` to produce `<.>`; elsewhere in `YAZPT_LAYOUT`/`YAZPT_RLAYOUT`, only escape left angle brackets, so like `<<.>` to produce `<.>`.


## Create your own preset

Once you've set yazpt's environment variables up exactly how you like them, by the way, feel free to save your preferences into a new preset for easy loading. If you name your shell script like `*-preset.zsh` and put it in yazpt's `presets` directory, it'll be shown by `yazpt_list_presets`, and you'll be able to load it with `yazpt_load_preset`, using auto-complete. Or you can save it anywhere you'd like, and load it with `yazpt_load_preset` by passing its path.

Either way, the `yazpt_make_preset` function might be helpful: it lets you save your current settings to a new preset file, saving only the settings which differ from the defaults. Or you can copy an existing preset file and use it as a starting point.

If you need to run some code logic to decide how to configure yazpt's environment variables, you can do that in a preset, too - see the [yolo preset](./presets/yolo-preset.zsh) for an example.


## Create your own custom segment

If you'd like to add new capabilities to yazpt, it's straightforward to implement a new segment.

For example, to make a new segment `<cheer>`, just create a shell function named `@yazpt_segment_cheer`, and inside that function, set the value of the pre-declared `yazpt_state` associative array's `cheer` key with whatever text you want to put into the prompt. For example:

```sh
function @yazpt_segment_cheer() {
	local cheers=('nice one' 'yay you' "you're rockin' it")
	(( cheer_num++ ))
	(( cheer_num > $#cheers )) && cheer_num=1
	
	local cheer=$cheers[$cheer_num]
	[[ -o prompt_bang ]] && cheer+='!!' || cheer+='!'

	yazpt_state[cheer]=$cheer
}
```

Then set `YAZPT_LAYOUT` set to something that includes `<cheer>`, like `<cheer> %~ %% `...   
Wow, what a cheerful prompt. 🙂

The `yazpt_state` variable is reset to contain only the last command's exit status (as `exit_code`) before each evaluation of `YAZPT_LAYOUT` and then `YAZPT_RLAYOUT`, so if you want to persist some state across calls to your segment function, you'll need to find somewhere else to stick it. (In the example above, we just used a global variable.)

Any segments to the left of your new segment in `YAZPT_LAYOUT` or `YAZPT_RLAYOUT` will already have been evaluated, so you can check their output in `yazpt_state`, e.g. with `$yazpt_state[cwd]`, if that's useful to you, or even change their output if you're adventurous that way.

You can also call other segments' functions from your segment's function; that's how the `<vcs>` segment works.


## Override an existing segment's implementation

If you want, say, the `<svn>` segment to work a bit differently than it does, there's nothing stopping you from just creating your own `@yazpt_segment_svn` function to replace the existing one. Go wild!

You can even keep the old segment function around under a different name, like if you want to call it in certain cases, using shell script like this:

```sh
# Copy the existing segment function under a new name...
eval "@yazpt_old_svn() { $(functions @yazpt_segment_svn | tail -n +2)"

# ...Then replace it...
function @yazpt_segment_svn() {
	local hour=$(date +%H)
	if (( 23 <= $hour || $hour <= 6 )); then
		yazpt_state[svn]="%F{52}it's late, yo - get some sleep\!%f"
	else
		@yazpt_old_svn  # ...And call the old version when you need it
	fi
}
```


## Fork the repo

If none of the above get you what you want out of yazpt, you can always [fork the repo](https://github.com/jakshin/yazpt), and hack on it yourself. 🙂  I think its code is pretty clean and fairly easy to understand.

If you come up with something good, please feel free to [make a pull request](https://github.com/jakshin/yazpt/pulls)!
