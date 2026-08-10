# 🐚 boat-fleet

A collection of shell scripts to augment the [`boat-cli`](https://github.com/coko7/boat-cli).

<img width="997" height="795" alt="image" src="https://github.com/user-attachments/assets/a3310b4e-159d-4029-8ae6-295e28af5731" />

## ⚠️ Requirements

Here are all the programs/scripts you need to have in your `$PATH` to be able to make full use of the **boat fleet scripts**.

**Core dependencies:**

- [boat](https://github.com/coko7/boat-cli): ⛵ The core activity tracking library
- [fzf](https://github.com/junegunn/fzf): 🌸 A command-line fuzzy finder
- [jq](https://github.com/jqlang/jq): ✨ A command-line JSON processor
- [gum](https://github.com/charmbracelet/gum): 🎀 A tool for glamorous shell scripts

**Hyprland-specific dependencies:**

- [hyprctl](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Using-hyprctl): [Hyprland](https://hypr.land) dispatcher, used to launch floating [Neovide](https://neovide.dev) instances for activity notes

**Styling dependencies:**

- [cfonts](https://github.com/dominikwilkowski/cfonts): 🖋️ used for big ASCII art text headers
- [figlet](https://www.figlet.org/): ⬆️ used for big ASCII art text in the preview pane
- [lolcat](https://github.com/busyloop/lolcat): 🌈 used for colorful output

**Companion scripts:**

- [floating-neovide.sh](https://github.com/coko7/.dotfiles/blob/main/.config/local/bin-sh/global/floating-neovide.sh): a custom script to launch a floating [Neovide](https://neovide.dev) instance with a specific note file, used for activity notes
- [fzf-rofi.sh](https://github.com/coko7/.dotfiles/blob/main/.config/local/bin-sh/global/fzf-rofi.sh): a custom wrapper around fzf to use it with [rofi](https://github.com/davatorium/rofi), used for all interactive selection in this script
- [ntfy-toast.sh](https://github.com/coko7/.dotfiles/blob/main/.config/local/bin-sh/global/ntfy-toast.sh): a simple wrapper around [`notify-send`](https://man.archlinux.org/man/notify-send.1.en)

## 🚀 Actions

| Action | Description |
|--------|-------------|
| `quick` | Prompt for a name and immediately start a new activity |
| `new` | Create a new activity with full details (name, customer, Jira issue) |
| `get` | Display info about the current activity (name, ID, elapsed time, customer, Jira issue, tags) |
| `note` | Open or create notes for the current activity in Neovide |
| `jira` | Open the current activity's Jira issue in the browser (only shown if a `jira:*` tag is set) |
| `resume` | Pick and resume a past activity |
| `stop` | Pause/stop the current activity |
| `cancel` | Cancel the current activity |
| `meeting` | Start a meeting from a list of presets (daily, weekly, misc) |
| `edit` | Edit today's activity logs |
| `config` | Open the boat configuration file in Neovide |

## 🚩 CLI Options

`fleet.sh` also accepts a single flag instead of opening the interactive menu:

| Option | Description |
|--------|-------------|
| `-w`, `--current-activity-workspace` | Print the notes dir path for the current activity |
| `-h`, `--help` | Show usage and exit |

Passing any other/unknown option prints usage to stderr and exits with a non-zero status.
