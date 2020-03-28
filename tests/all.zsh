#!/bin/zsh
# Runs all of yazpt's test suites.

script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
summaries="$(mktemp)"

declare -a failing_suites=()
first=true

for suite in *.zsh; do
	if [[ $suite == $script_name || ! -x $suite ]]; then
		continue  # Skip this file and utils.zsh
	fi

	[[ $first == true ]] || echo
	first=false

	{ ./$suite 2>&1 } \
		> >(awk '/===|---|✔|✖︎|↪/{print}') \
		> >(grep -F ↪ >> "$summaries")

	if ! tail -n 1 "$summaries" | grep -Fq " 0 failed"; then
		failing_suites+=$suite
	fi
done

# Summarize the summaries
total_passed=0
total_failed=0

cat $summaries | while read -rA result; do
	(( total_passed+=$result[5] ))
	(( total_failed+=$result[7] ))
done

if [[ $total_failed == 0 ]]; then
	color="$success"
	emoji="👍"
else
	color="$failure"
	emoji="😫"
fi

echo -e "\n${bright}~~~ Overall results ~~~${normal}"
echo -e "${emoji} ${color}Ran $(( total_passed + total_failed )) tests: $total_passed passed, $total_failed failed${normal}"

if [[ -n $failing_suites ]]; then
	echo -e "   ${color}Failing suites: $failing_suites${normal}"
fi

rm $summaries
