#!/bin/zsh
# Tests for various types of file/folder changes in a TFVC workspace.

# Initialize
script_name="$(basename -- "$0")"
cd -- "$(dirname -- "$0")"
source ./utils.zsh
before_tests $script_name "tfvc"
YAZPT_VCS_ORDER=(tfvc)

# Test
test_case "Adding a folder"
mkdir new-folder
touch new-folder/new-file.txt
tf_status
test_init_done
contains_status "dirty"
cd folder
test_init_done
contains_status "dirty"
cd ..
$tf_cli add ${=tf_args} new-folder
test_init_done
contains_status "dirty"
cd folder
test_init_done
contains_status "dirty"
cd .. && $tf_cli undo ${=tf_args} new-folder && rm -rf new-folder
tf_status
test_init_done
contains_status "clean"

test_case "Adding an ignored folder"
mkdir ignored-folder
touch ignored-folder/new-file.txt
tf_status
test_init_done
contains_status "clean"
rm -rf ignored-folder
test_init_done
contains_status "clean"

test_case "Adding a file"
touch new-file.txt
tf_status
test_init_done
contains_status "dirty"
cd folder
test_init_done
contains_status "dirty"
cd ..
$tf_cli add ${=tf_args} new-file.txt
test_init_done
contains_status "dirty"
cd folder
test_init_done
contains_status "dirty"
cd .. && $tf_cli undo ${=tf_args} new-file.txt && rm -f new-file.txt
tf_status
test_init_done
contains_status "clean"

test_case "Adding an ignored file"
touch ignored-file.txt
tf_status
test_init_done
contains_status "clean"
rm -f ignored-file.txt
test_init_done
contains_status "clean"

test_case "Changing a file"
echo "blah" >> change-me.txt
tf_status
test_init_done
contains_status "dirty"
cd folder
test_init_done
contains_status "dirty"
cd .. && $tf_cli undo ${=tf_args} "${tf_opt_char}noprompt" change-me.txt
test_init_done
contains_status "clean"

test_case "Adding an unchanged file"
$tf_cli add ${=tf_args} change-me.txt
test_init_done
contains_status "clean"

test_case "Renaming a file"
old_name=$(echo rename-me*)
new_name="rename-me.$(current_timestamp).txt"
mv $old_name $new_name
tf_status
test_init_done
contains_status "dirty"
cd folder
test_init_done
contains_status "dirty"
cd .. && mv $new_name $old_name
tf_status
test_init_done
contains_status "clean"

test_case "Renaming a file (tf rename)"
old_name=$(echo rename-me*)
new_name="rename-me.$(current_timestamp).txt"
$tf_cli rename ${=tf_args} $old_name $new_name
test_init_done
contains_status "dirty"
cd folder
test_init_done
contains_status "dirty"
cd .. && $tf_cli checkin ${=tf_args} "${tf_opt_char}comment:Renaming a file for testing" "${tf_opt_char}noprompt"
test_init_done
contains_status "clean"

test_case "Deleting a file"
delete_me_text="$(<delete-me.txt)"
rm delete-me.txt
tf_status
test_init_done
contains_status "dirty"
cd folder
test_init_done
contains_status "dirty"
cd .. && echo "$delete_me_text" > delete-me.txt
tf_status
test_init_done
contains_status "clean"

test_case "Deleting a file (tf delete)"
$tf_cli delete ${=tf_args} delete-me.txt
test_init_done
contains_status "dirty"
cd folder
test_init_done
contains_status "dirty"
cd .. && $tf_cli undo ${=tf_args} delete-me.txt
test_init_done
contains_status "clean"

# Clean up
after_tests
