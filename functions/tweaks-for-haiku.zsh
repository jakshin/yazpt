# Tweaks to make yazpt look better in Haiku (https://www.haiku-os.org/).
# Copyright (c) 2020 Jason Jackson <jasonjackson@pobox.com>. Distributed under GPL v2.0, see LICENSE for details.

# Changes the checkmark character for better rendering.
#
function .yazpt_tweak_checkmark() {
	YAZPT_EXIT_OK_CHAR="✓"
}

# Changes the hand and face emoji, which don't render in Haiku Terminal,
# to Unicode symbols that do.
#
function .yazpt_tweak_emoji() {
	YAZPT_EXIT_ERROR_CHAR="☢"  # Radioactive
	YAZPT_EXIT_OK_CHAR="ッ"    # "oh"/"ah" Katakana, looks like a happy face
}

# Changes the hourglass character, which doesn't render in Haiku Terminal,
# to one that does.
#
function .yazpt_tweak_hourglass() {
	YAZPT_EXECTIME_CHAR="$yazpt_clock"
}

# Changes the hourglass emoji, which doesn't render in Haiku Terminal,
# to some Kanji characters that do.
#
function .yazpt_tweak_hourglass_emoji() {
	# I think this right for "time elapsed", but I'm not positive...
	# https://www.nihongomaster.com/dictionary/entry/30144/jikan
	# https://japaneseparticlesmaster.xyz/jikan/
	YAZPT_EXECTIME_CHAR="時間 "
}
