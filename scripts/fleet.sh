#!/usr/bin/env boat

actions='task:;start a new activity or resume an existing one
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
    meeting_name=$(gum input --placeholder="$def_meeting_name" --prompt="Meeting name> ")
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
*)
  echo "$pick" | less
  ;;
esac
