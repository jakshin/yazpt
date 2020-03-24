# A preset with emoji and randomized but complimentary colors.
# The cwd and git branch colors are different each time the preset is loaded,
# then stay constant within that terminal session.

emulate -L zsh
declare -a yazpt_yolo_color_ranges=('22-39' '58-75' '94-111' '130-147')

function yazpt_random_int() {
	local lowest=$1
	local highest=$2
	local rand=$(hexdump -e '"%u"' -n 1 /dev/urandom)  # Seems better than $RANDOM
	local modulo=$((highest - lowest + 1))
	echo $((rand % modulo + lowest))
}

function yazpt_random_char() {
	local str=$1
	local rand=$(yazpt_random_int 1 $#str)
	echo $str[$rand]
}

function yazpt_random_color() {
	local rand=$(yazpt_random_int 1 $#yazpt_yolo_color_ranges)
	local range=$yazpt_yolo_color_ranges[$rand]
	echo $range | IFS=- read -A range
	yazpt_random_int $range[1] $range[2]	
}

source "$yazpt_default_preset_file"

YAZPT_LAYOUT=$'\n<exit><? ><cwd><? ><vcs>\n%# '
YAZPT_CWD_COLOR=$(yazpt_random_color)

YAZPT_EXIT_ERROR_CHAR=$(yazpt_random_char "😫😖😬")
YAZPT_EXIT_ERROR_COLOR=""
YAZPT_EXIT_ERROR_CODE_VISIBLE=false

YAZPT_EXIT_OK_CHAR=$(yazpt_random_char "🤘🤙👌")
YAZPT_EXIT_OK_COLOR=""
YAZPT_EXIT_OK_CODE_VISIBLE=false

YAZPT_VCS_BRANCH_COLOR=$((YAZPT_CWD_COLOR + 6))
YAZPT_VCS_WRAPPER_CHARS="❨❩"

unfunction yazpt_random_int yazpt_random_char yazpt_random_color
unset yazpt_yolo_color_ranges
