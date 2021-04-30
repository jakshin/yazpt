# A preset with randomized but complementary colors, and emoji (emoticons under XTerm).
# The current directory and VCS context colors change each time the preset is loaded,
# then stay constant within that terminal session.

declare -a _yazpt_yolo_color_ranges=('22-39' '58-75' '94-111' '130-147')
declare -a _yazpt_yolo_happy_chars=("👌 " "👍 " "👊 ")
declare -a _yazpt_yolo_sad_chars=("😫 " "😖 " "😬 ")

function .yazpt_random_char() {
	emulate -L zsh
	local char_array_name=$1
	local char_array=(${(P)${char_array_name}})

	local rand=$(.yazpt_random_int 1 $#char_array)
	local rand_char=$char_array[$rand]
	rand_char=${rand_char// /}

	local space=""
	if [[ $OSTYPE == "linux-gnu" ]]; then
		local width=$(echo $rand_char | wc -L)
		[[ $width == 1 ]] && space=" "  # Add a manual space to pad wide emoji on the right
	fi

	echo "$rand_char$space"
}

function .yazpt_random_color() {
	emulate -L zsh
	local rand=$(.yazpt_random_int 1 $#_yazpt_yolo_color_ranges)
	local range=$_yazpt_yolo_color_ranges[$rand]
	echo $range | IFS=- read -A range
	.yazpt_random_int $range[1] $range[2]
}

function .yazpt_random_int() {
	emulate -L zsh
	local lowest=$1
	local highest=$2

	local rand=$(hexdump -e '"%u"' -n 1 /dev/urandom 2> /dev/null)  # Seems better than $RANDOM
	[[ -n $rand ]] || rand=$RANDOM

	local modulo=$((highest - lowest + 1))
	echo $((rand % modulo + lowest))
}

source "$yazpt_default_preset_file"
_yazpt_yolo_base_color=$(.yazpt_random_color)

YAZPT_LAYOUT=$'\n<exit><? ><cwd><? ><vcs>\n<char> '
YAZPT_CWD_COLOR=$_yazpt_yolo_base_color

YAZPT_EXECTIME_CHAR="$yazpt_hourglass_emoji"
YAZPT_EXECTIME_COLOR=$(( _yazpt_yolo_base_color + 12 ))

YAZPT_EXIT_ERROR_CHAR=$(.yazpt_random_char _yazpt_yolo_sad_chars)
YAZPT_EXIT_ERROR_COLOR="217"
YAZPT_EXIT_ERROR_CODE_VISIBLE=false

YAZPT_EXIT_OK_CHAR=$(.yazpt_random_char _yazpt_yolo_happy_chars)
YAZPT_EXIT_OK_COLOR="229"
YAZPT_EXIT_OK_CODE_VISIBLE=false

YAZPT_VCS_CONTEXT_COLOR=$(( _yazpt_yolo_base_color + 6 ))
YAZPT_VCS_WRAPPER_CHARS=('❨' '❩')

# Tweaks and fixups for various environments
if [[ -z $YAZPT_NO_TWEAKS ]]; then
	if [[ $OS == "Windows"* ]]; then
		_yazpt_tweaks_file="tweaks-for-windows.zsh"
	elif [[ -n $WSL_DISTRO_NAME ]]; then
		_yazpt_tweaks_file="tweaks-for-wsl.zsh"
	elif [[ $OSTYPE == "linux-gnu" ]]; then
		_yazpt_tweaks_file="tweaks-for-linux.zsh"
	elif [[ $OSTYPE == "freebsd"* ]]; then
		_yazpt_tweaks_file="tweaks-for-freebsd.zsh"
	elif [[ $OSTYPE == "haiku" ]]; then
		_yazpt_tweaks_file="tweaks-for-haiku.zsh"
	else
		unset _yazpt_tweaks_file
	fi

	if [[ -n $_yazpt_tweaks_file ]]; then
		functions .yazpt_tweak_emoji > /dev/null || source "$yazpt_base_dir/functions/$_yazpt_tweaks_file"
		unset _yazpt_tweaks_file
		.yazpt_tweak_emoji
		.yazpt_tweak_hourglass_emoji
	fi
fi

unfunction .yazpt_random_int .yazpt_random_char .yazpt_random_color
unset _yazpt_yolo_base_color _yazpt_yolo_color_ranges _yazpt_yolo_happy_chars _yazpt_yolo_sad_chars
