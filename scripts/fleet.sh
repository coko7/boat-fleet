#!/usr/bin/env boat

function ensure_installed() {
  if ! command -v "$1" &>/dev/null; then
    echo "This script requires $1 to be installed."
    exit 1
  fi
}

###################################################################
#                                                                 #
#  ____                  _                               _        #
# |  _ \ ___  __ _ _   _(_)_ __ ___ _ __ ___   ___ _ __ | |_ ___  #
# | |_) / _ \/ _` | | | | | '__/ _ \ '_ ` _ \ / _ \ '_ \| __/ __| #
# |  _ <  __/ (_| | |_| | | | |  __/ | | | | |  __/ | | | |_\__ \ #
# |_| \_\___|\__, |\__,_|_|_|  \___|_| |_| |_|\___|_| |_|\__|___/ #
#               |_|                                               #
#                                                                 #
###################################################################

# Core
ensure_installed boat # the boat-cli itself
ensure_installed fzf  # a CLI fuzzy finder, used for interactive selection of activities and meetings
ensure_installed jq   # for parsing JSON output from boat-cli
ensure_installed gum  # for interactive input prompts, used when creating new activities or meetings

# Hyprland-specific
ensure_installed hyprctl # Hyprland dispatcher, used to launch floating neovide instances for activity notes

# Styling only
ensure_installed figlet # used for big ASCII art text in the preview pane
ensure_installed lolcat # used for colorful output in the preview pane and notifications

# custom scripts
ensure_installed floating-neovide.sh # a custom script to launch a floating neovide instance with a specific note file, used for activity notes
ensure_installed fzf-rofi.sh         # a custom wrapper around fzf to use it with rofi, used for all interactive selection in this script
ensure_installed ntfy-toast.sh       # a custom script to send notifications via ntfy, used for activity start/stop/cancel notifications

# Global declarations

NTFY_TOPIC='ntfy-boat-fleet'
TASK_NOTES_DIR="$HOME/Documents/boat-acts"

actions='new:;start a new activity
note:;view/take notes for the current activity
resume:;resume an existing activity
stop:;pause/stop the current activity
cancel:;cancel the current activity
meeting:;start a new meeting from a list of presets
edit:;modify activity logs'

meeting_presets='Daily meeting:daily
Weekly meeting:weekly
Miscellaneous meeting:misc'

# Actual script logic

pick=$(column --separator=';' --table <<<"$actions" | fzf-rofi.sh \
  --delimiter=':' --nth=1 --accept-nth=1 \
  --border-label ' Boat Fleet Actions ' --input-label ' Input ' \
  --list-label ' Actions ' --preview="figlet {1} | lolcat --force")

[[ -z "$pick" ]] && exit 1

function notify_info() {
  ntfy-toast.sh 'boat-fleet' "ℹ️ $1" boat-cli-icon "$NTFY_TOPIC" /usr/share/sounds/freedesktop/stereo/bell.oga
}

function notify_error() {
  ntfy-toast.sh 'boat-fleet' "⚠️ $1" boat-cli-icon "$NTFY_TOPIC" "$HOME/Music/sounds/nope.wav"
}

case "$pick" in
meeting)
  meeting_tag=$(echo -e "$meeting_presets" | fzf-rofi.sh \
    --delimiter=' ' --nth=1 --accept-nth=2 --with-nth=1 \
    --border-label ' Boat Fleet Actions ' --input-label ' Input ' \
    --list-label ' Actions ')
  [[ -z "$meeting_tag" ]] && exit 1

  case "$meeting_tag" in
  meeting:misc)
    now=$(date +"%Y-%m-%d %H:%M")
    def_meeting_name="unnamed meeting (at $now)"
    if ! meeting_name=$(gum input --placeholder="$def_meeting_name" --prompt="Meeting name> "); then
      exit 1
    fi

    if [ -z "$meeting_name" ]; then
      meeting_name=$def_meeting_name
    fi

    act_id=$(boat new "$meeting_name" --tags meeting:misc --start-now --json | jq '.id')
    notify_info "Started meeting: $meeting_name ($act_id)"
    exit 0
    ;;
  esac

  meet_id=$(boat report --filter-by-tags "$meeting_tag" --period 'all-time' --json | jq --raw-output '.[0].id')
  # echo "$meet_id" | less
  ;;
note)
  if ! current=$(boat get --json); then
    notify_error "No current activity"
    exit 1
  fi

  act_id=$(jq '.activity.id' <<<"$current")
  act_name=$(jq --raw-output '.activity.name' <<<"$current")

  note_path="$TASK_NOTES_DIR/note_${act_id}.md"
  if [ ! -f "$note_path" ]; then
    notify_info "No existing notes for current activity. Creating new note at $note_path"
    echo "# ${act_name} - Notes" >"$note_path"
  fi

  wm_class_prefix="boat-view-note-$act_id"
  hyprctl dispatch exec "floating-neovide.sh $wm_class_prefix $note_path"
  ;;

new)
  echo " New Activity" | figlet -f slant | lolcat --force --seed 42
  if ! act_name=$(gum input --placeholder="work on boat-cli" --prompt="Activity name> "); then
    exit 1
  fi

  [[ -z "$act_name" ]] && exit 1

  act_id=$(boat new "$act_name" --tags task:misc --start-now --json | jq '.id')
  notify_info "Started new activity: $act_name ($act_id)"
  exit 0
  ;;

cancel)
  if ! current=$(boat get --json); then
    notify_error "No current activity"
    exit 1
  fi

  act_id=$(jq '.activity.id' <<<"$current")
  act_name=$(jq --raw-output '.activity.name' <<<"$current")
  boat cancel
  notify_info "Canceled activity: $act_name ($act_id)"
  ;;

resume)
  activities=$(boat report --period=all-time --json)
  act_id=$(jq --raw-output '.[] | "\(.id): \(.name)"' <<<"$activities" |
    sort --numeric-sort --reverse |
    fzf-rofi.sh \
      --delimiter=':' --nth=1 --accept-nth=1 --input-label ' Input ' \
      --list-label ' Recent Activities ' --preview="figlet {1} | lolcat --force")

  [[ -z "$act_id" ]] && exit 1

  boat start "$act_id"
  current=$(boat get --json)
  act_name=$(jq --raw-output '.activity.name' <<<"$current")
  notify_info "Resumed activity: $act_name ($act_id)"

  ;;

edit)
  boat edit --period=today
  ;;
stop)
  activity=$(boat get --json | jq '.activity')
  act_id=$(jq '.id' <<<"$activity")
  act_name=$(jq --raw-output '.name' <<<"$activity")

  boat stop && notify_info "Stopping activity: $act_name ($act_id)"
  ;;
*)
  ;;
esac
