# A space-conserving preset almost like the default, but on a single line,
# and without a blank line before the prompt.

source "$yazpt_default_preset_file"
YAZPT_LAYOUT=${YAZPT_LAYOUT//$'\n'/}
YAZPT_LAYOUT=${YAZPT_LAYOUT//<blank>/}
