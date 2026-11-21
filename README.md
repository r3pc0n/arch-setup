# arch-setup

A Hyprland desktop on Arch Linux, built toward an Omarchy-like setup without Omarchy's own tooling.
Developed on a ThinkPad X230. One script puts it on a fresh Arch install.

**Status:** tested by running the installer in a throwaway `HOME` (files, theme generation and desktop settings come out
identical to the original machine). **Not yet run on a real fresh machine**, and the package/service/SDDM steps were
only dry-run. Expect to fix a few things on the first real run, and please open an issue if you do.

## What you get

- **Hyprland** (needs 0.56 or newer: the config is Lua, `hyprland.lua`), with `hypridle`, `hyprlock`, `hyprpaper`
- **Waybar** top bar, **swaync** notifications, **fuzzel** launcher, **foot** terminal, **Nautilus**
- **`theme-set`**: applies any of Omarchy's 22 colour themes to Hyprland, Waybar, foot, fuzzel and the lock screen,
  plus a matching wallpaper (`theme-set --list`, `theme-set tokyo-night`)
- **`webapp-install`**: Omarchy-style web apps as Chromium `--app` windows with their own profile
- Omarchy-style keybindings (`SUPER+Return` terminal, `SUPER+SPACE` launcher, `SUPER+W` close, `SUPER+1..0` workspaces)
- A hyprlock-style **SDDM login screen** with your wallpaper

## Install

Do a normal Arch install first (base system, bootloader, a user with sudo, network). Then, as that user:

    sudo pacman -S --needed git
    git clone https://github.com/r3pc0n/arch-setup ~/Projects/arch-setup
    cd ~/Projects/arch-setup
    ./install.sh --dry-run          # see exactly what it will do
    ./install.sh --extras --x230          # ThinkPad X230 (old Intel graphics)
    ./install.sh --extras --intel-modern  # newer Intel laptops (Broadwell and later)

Options: `--extras` (btop, tmux, vim, zsh, Obsidian, Syncthing...), `--x230` or `--intel-modern` (pick one: the
Intel video-acceleration driver for your laptop; leave both off for AMD/Nvidia/unknown),
`--personal-apps` (libraries for my own apps), `--theme NAME`, `--no-packages`, `--no-system` (skip everything needing
sudo), `--dry-run`. It is safe to re-run; any file it would replace with different content is backed up first to
`~/.config-backup/arch-setup-<date>/`.

What it does, in order: installs packages from `packages/*.txt` (and `yay` + `peaclock` from the AUR) → copies
`config/` into `~/.config` and `bin/` into `~/.local/bin` → builds the tray-icon override → runs `theme-set` (needs
internet) → sets dark mode, teal accent and tray icons through gsettings → enables `bluetooth`, `NetworkManager`
and `sddm`, sets the graphical target, installs the SDDM theme.

Then reboot and pick the **Hyprland (uwsm-managed)** session at the login screen.

**Networking:** the installer enables NetworkManager. If you set up the network during the Arch install some other
way (systemd-networkd, iwd, `dhcpcd`), you may need to reconnect with `nmcli` or `nmtui` after the first reboot.

## Adapting it to your hardware

- **Monitors:** the top of `config/hypr/hyprland.lua` sets two outputs (`VGA-1`, `LVDS-1`). Change these for your
  machine; `hyprctl monitors` lists your outputs.
- **Graphics driver:** chosen by `--x230` / `--intel-modern` and written to `~/.config/uwsm/env` as
  `LIBVA_DRIVER_NAME`. Edit that file to change it later.
- **Keyboard layout, touchpad:** the `input` block in the same file.
- **Fonts:** `JetBrainsMono Nerd Font` (installed by `core.txt`) is used by the terminal, launcher and lock screen.

## How the pieces fit

- `theme-set` generates `hypr/colors.conf`, `hypr/hyprlock.conf`, `foot/foot.ini`, `fuzzel/fuzzel.ini`,
  `mako/config` and `waybar/colors/colors.css`, so those are **not in the repo**. Don't hand-edit them. The installer
  copies files instead of symlinking so a theme switch never dirties your git checkout.
- The SDDM theme copies the `maya` theme from the `sddm` package and overlays `sddm/Main.qml` and
  `sddm/theme.conf`. It uses the wallpaper as it was when you installed; `theme-set` does not update it.
- `webapp-install` needs Chromium: `webapp-install` with no arguments prints its usage.

## Deliberately not in this repo

Secrets and anything personal: API keys, app logins (Telegram sessions, tokens), browser and Obsidian profiles,
Syncthing keys, Bluetooth pairings, files from `~/Documents` etc. `sshd` is not enabled by the installer. The
`.gitignore` blocks the usual secret filenames. If you fork this, keep it that way.

## Changes from the originals

`bin/theme-set` and `config/hypr/hyprland.lua` here differ slightly from the author's live copies, for portability:
the lock-screen name is `$USER`, `theme-set` uses your real user id and honours `THEME_SET_NO_RELOAD=1`, and the
Hyprland config only auto-starts a personal tool if it exists.

## Licence

MIT for my own files (`LICENSE`). Parts derive from other MIT-licensed projects, see `THIRD-PARTY.md`.
