# A preset which uses only plain ascii characters, so it should render anywhere.
# Otherwise just like the default.

source "$yazpt_default_preset_file"

YAZPT_EXIT_ERROR_CHAR="x"
YAZPT_EXIT_OK_CHAR=""

YAZPT_VCS_STATUS_CLEAN_CHAR="="
YAZPT_VCS_STATUS_CONFLICT_CHAR="#"
YAZPT_VCS_STATUS_DIRTY_CHAR="*"
YAZPT_VCS_STATUS_DIVERGED_CHAR="^"
YAZPT_VCS_STATUS_LINKED_BARE_CHAR=""
YAZPT_VCS_STATUS_LOCKED_CHAR="!"
YAZPT_VCS_STATUS_NO_UPSTREAM_CHAR="~"
YAZPT_VCS_STATUS_UNKNOWN_CHAR="??"
