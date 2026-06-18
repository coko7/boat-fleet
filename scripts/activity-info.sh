#!/usr/bin/env bash

export CLICOLOR_FORCE=1

current=$(boat get --json 2>/dev/null)

if [[ -z "$current" ]]; then
  gum style --foreground 196 --margin "1" "No current activity"
  exit 0
fi

act_id=$(jq '.activity.id' <<<"$current")
act_name=$(jq --raw-output '.activity.name' <<<"$current")
act_tags=$(jq --raw-output '.activity.tags | join(", ")' <<<"$current")
starts_at=$(jq --raw-output '.log.starts_at' <<<"$current")
ends_at=$(jq --raw-output '.log.ends_at // empty' <<<"$current")
start_epoch=$(date -d "$starts_at" +%s)
end_epoch=$([[ -n "$ends_at" ]] && date -d "$ends_at" +%s || date +%s)
elapsed_secs=$((end_epoch - start_epoch))
elapsed="$((elapsed_secs / 3600))h $(((elapsed_secs % 3600) / 60))m"
customer=$(jq --raw-output '[.activity.tags[] | select(startswith("customer:"))] | first // "" | ltrimstr("customer:")' <<<"$current")
jira_tag=$(jq --raw-output '[.activity.tags[] | select(startswith("jira:"))] | first // "" | ltrimstr("jira:")' <<<"$current")

gum style \
  --border rounded --border-foreground 212 \
  --padding "1 2" --margin "1" \
  "$(gum style --foreground 212 --bold 'Current Activity')" \
  "" \
  "$(gum style --foreground 99 'Name:    ')$act_name" \
  "$(gum style --foreground 99 'ID:      ')$act_id" \
  "$(gum style --foreground 99 'Elapsed: ')$elapsed" \
  "$(gum style --foreground 99 'Customer:')${customer:--}" \
  "$(gum style --foreground 99 'Jira:    ')${jira_tag:--}" \
  "$(gum style --foreground 99 'Tags:    ')$act_tags"
