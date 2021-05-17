# Tweaks to make yazpt look better in Haiku (https://www.haiku-os.org/).
# Copyright (c) 2020 Jason Jackson <jasonjackson@pobox.com>. Distributed under GPL v2.0, see LICENSE for details.

function .yazpt_tweak_checkmark() {
	YAZPT_EXIT_OK_CHAR="✓"
}

function .yazpt_tweak_emoji() {
	YAZPT_EXIT_ERROR_CHAR="☢"  # Radioactive
	YAZPT_EXIT_OK_CHAR="ッ"    # "oh"/"ah" Katakana, looks like a happy face

	# I think this right for "time elapsed", but I'm not positive...
	# https://www.nihongomaster.com/dictionary/entry/30144/jikan
	# https://japaneseparticlesmaster.xyz/jikan/
	YAZPT_EXECTIME_CHAR="時間 "
}
