# 🐚 boat-fleet

A collection of shell scripts to augment the [`boat-cli`](https://github.com/coko7/boat-cli).

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

- [figlet](https://www.figlet.org/): ⬆️ used for big ASCII art text in the preview pane
- [lolcat](https://github.com/busyloop/lolcat): 🌈 used for colorful output in the preview pane and notifications

**Companion scripts:**

- [floating-neovide.sh](https://github.com/coko7/.dotfiles/blob/main/.config/local/bin-sh/global/floating-neovide.sh): a custom script to launch a floating [Neovide](https://neovide.dev) instance with a specific note file, used for activity notes
- [fzf-rofi.sh](https://github.com/coko7/.dotfiles/blob/main/.config/local/bin-sh/global/fzf-rofi.sh): a custom wrapper around fzf to use it with [rofi](https://github.com/davatorium/rofi), used for all interactive selection in this script
- [ntfy-toast.sh](https://github.com/coko7/.dotfiles/blob/main/.config/local/bin-sh/global/ntfy-toast.sh): a simple wrapper around [`notify-send`](https://man.archlinux.org/man/notify-send.1.en)
