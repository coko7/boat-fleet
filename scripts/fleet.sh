#!/usr/bin/env boat

actions='resume:;resume an existing activity
new:;start a new activity
stop:;pause/stop the current activity
cancel:;cancel the current activity
meeting:;start a new meeting from a list of presets
edit:;modify activity logs'

meeting_presets='Daily meeting:daily
Weekly meeting:weekly
Miscellaneous meeting:misc'

pick=$(column --separator=';' --table <<<"$actions" | fzf-rofi.sh \
  --delimiter=':' --nth=1 --accept-nth=1 \
  --border-label ' Boat Fleet Actions ' --input-label ' Input ' \
  --list-label ' Actions ' --preview="figlet {1} | lolcat --force")

[[ -z "$pick" ]] && exit 1

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
    ntfy-toast.sh 'boat-fleet' "Started meeting: $meeting_name ($act_id)"
    exit 0
    ;;
  esac

  meet_id=$(boat report --filter-by-tags "$meeting_tag" --period 'all-time' --json | jq --raw-output '.[0].id')
  echo "$meet_id" | less
  ;;

new)
  if ! act_name=$(gum input --placeholder="work on boat-cli" --prompt="Activity name> "); then
    exit 1
  fi

  [[ -z "$act_name" ]] && exit 1

  act_id=$(boat new "$act_name" --tags task:misc --start-now --json | jq '.id')
  ntfy-toast.sh 'boat-fleet' "Started new task: $act_name ($act_id)"
  exit 0
  ;;

cancel)
  current=$(boat get --json)
  act_id=$(jq '.activity.id' <<<"$current")
  act_name=$(jq --raw-output '.activity.name' <<<"$current")
  boat cancel
  ntfy-toast.sh 'boat-fleet' "Cancelled activity: $act_name ($act_id)"
  ;;

resume)
  activities=$(boat report --period=all-time --json)
  act_id=$(jq --raw-output '.[] | "\(.id): \(.name)"' <<<"$activities" | sort --numeric-sort --reverse | fzf-rofi.sh \
    --delimiter=':' --nth=1 --accept-nth=1 --input-label ' Input ' \
    --list-label ' Recent Activities ' --preview="figlet {1} | lolcat --force")

  [[ -z "$act_id" ]] && exit 1

  boat start "$act_id"
  current=$(boat get --json)
  act_name=$(jq --raw-output '.activity.name' <<<"$current")
  ntfy-toast.sh 'boat-fleet' "Resumed activity: $act_name ($act_id)"

  ;;

edit)
  boat edit --period=today
  ;;
stop)
  activity=$(boat get --json | jq '.activity')
  act_id=$(jq '.id' <<<"$activity")
  act_name=$(jq --raw-output '.name' <<<"$activity")

  boat stop && ntfy-toast.sh 'boat-fleet' "Stopped tracking activity: $act_name ($act_id)"
  ;;
*)
  ;;
esac
