#!/usr/bin/env bash
# Install this Arch desktop (Hyprland + Waybar + theme-set) on a fresh Arch install.
# Run as your normal user, not root. Needs internet and sudo. Safe to re-run.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY=0; PACKAGES=1; SYSTEM=1; EXTRAS=0; X230=0; PERSONAL=0; THEME="gruvbox"
BACKUP="$HOME/.config-backup/arch-setup-$(date +%Y%m%d-%H%M%S)"

usage() {
cat <<EOF
Usage: ./install.sh [options]
  --extras         also install packages/extras.txt (btop, tmux, vim, zsh, obsidian, syncthing, ...)
  --x230           also install packages/x230.txt (ThinkPad X230 Intel graphics and thermals)
  --personal-apps  also install packages/personal-apps.txt (libraries for backtalk-ui and Murmur)
  --theme NAME     starting theme for theme-set (default: gruvbox; see 'theme-set --list')
  --no-packages    skip pacman/AUR installs
  --no-system      skip every step that needs sudo (services, SDDM theme)
  --dry-run        print what would happen, change nothing
  -h, --help       this text
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --extras) EXTRAS=1 ;; --x230) X230=1 ;; --personal-apps) PERSONAL=1 ;;
    --theme) THEME="${2:?--theme needs a name}"; shift ;;
    --no-packages) PACKAGES=0 ;; --no-system) SYSTEM=0 ;; --dry-run) DRY=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

say()  { printf '\n==> %s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
die()  { printf 'error: %s\n' "$*" >&2; exit 1; }
run()  { if [ "$DRY" = 1 ]; then printf '+ %s\n' "$*"; else "$@"; fi; }

[ "$(id -u)" -ne 0 ] || die "run as your normal user, not root (the script uses sudo where needed)"
if [ "$PACKAGES" = 1 ] || [ "$SYSTEM" = 1 ]; then
  command -v pacman >/dev/null || die "this is for Arch Linux (pacman not found)"
fi
[ "$SYSTEM" = 0 ] || [ "$DRY" = 1 ] || sudo -v || die "sudo is needed (or use --no-system)"

packages_in() { grep -hv -e '^[[:space:]]*#' -e '^[[:space:]]*$' "$@" | awk '{print $1}'; }

# ---------------------------------------------------------------- packages
if [ "$PACKAGES" = 1 ]; then
  say "Installing packages"
  lists=("$REPO/packages/core.txt")
  [ "$EXTRAS" = 1 ] && lists+=("$REPO/packages/extras.txt")
  [ "$X230" = 1 ] && lists+=("$REPO/packages/x230.txt")
  [ "$PERSONAL" = 1 ] && lists+=("$REPO/packages/personal-apps.txt")
  mapfile -t pkgs < <(packages_in "${lists[@]}")
  run sudo pacman -S --needed "${pkgs[@]}"

  mapfile -t aur < <(packages_in "$REPO/packages/aur.txt")
  if [ "${#aur[@]}" -gt 0 ]; then
    if ! command -v yay >/dev/null; then
      say "Installing yay (AUR helper) from the AUR; read its PKGBUILD when asked"
      if [ "$DRY" = 1 ]; then
        echo "+ git clone https://aur.archlinux.org/yay-bin.git && makepkg -si"
      else
        tmp="$(mktemp -d)"; git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
        (cd "$tmp/yay-bin" && makepkg -si)
      fi
    fi
    run yay -S --needed "${aur[@]}"
  fi
fi

# ---------------------------------------------------------------- files
copy_tree() {  # copy_tree SRC_DIR DEST_DIR: copies files, backing up any different file it would replace
  local src="$1" dest="$2" f rel
  while IFS= read -r -d '' f; do
    rel="${f#"$src"/}"
    if [ -e "$dest/$rel" ] && ! cmp -s "$f" "$dest/$rel"; then
      run mkdir -p "$BACKUP/$(dirname "$rel")"
      run cp -a "$dest/$rel" "$BACKUP/$rel"
      echo "backed up $dest/$rel"
    fi
    run install -D -m "$([ -x "$f" ] && echo 755 || echo 644)" "$f" "$dest/$rel"
  done < <(find "$src" -type f -print0)
}

say "Copying configs to ~/.config and scripts to ~/.local/bin"
copy_tree "$REPO/config" "$HOME/.config"
copy_tree "$REPO/bin" "$HOME/.local/bin"
run ln -sfn modules.hyprland.jsonc "$HOME/.config/waybar/modules.jsonc"
# folders theme-set writes into
run mkdir -p "$HOME/.config"/{foot,fuzzel,mako,waybar/colors,hypr/assets} "$HOME/Pictures/Screenshots" "$HOME/.local/state/omarchy/current"

say "Building the tray-icon override (symbolic Wi-Fi icons)"
icons="$HOME/.local/share/icons/neil-tray"
if [ -d /usr/share/icons/hicolor/scalable/apps ]; then
  run mkdir -p "$icons/scalable/apps"
  if [ "$DRY" = 1 ]; then
    echo "+ write $icons/index.theme and copy nm-signal-*-symbolic.svg from hicolor"
  else
    cat > "$icons/index.theme" <<'EOF'
[Icon Theme]
Name=Neil Tray Override
Comment=Redirects specific tray icon names to their symbolic variants; falls through to Adwaita/hicolor for everything else
Inherits=Adwaita,hicolor
Directories=scalable/apps

[scalable/apps]
Size=22
MinSize=8
MaxSize=512
Type=Scalable
Context=Applications
EOF
    for s in /usr/share/icons/hicolor/scalable/apps/nm-signal-*-symbolic.svg; do
      [ -e "$s" ] || continue
      b="$(basename "$s")"; cp "$s" "$icons/scalable/apps/${b/-symbolic/}"
    done
    command -v gtk-update-icon-cache >/dev/null && gtk-update-icon-cache -q -f -t "$icons" || true
  fi
else
  warn "hicolor icons not found (install networkmanager's icon deps); skipping the tray override"
fi

# ---------------------------------------------------------------- theme
say "Applying theme '$THEME' (downloads palette and wallpaper from GitHub)"
if [ "$DRY" = 1 ]; then
  echo "+ THEME_SET_NO_RELOAD=1 ~/.local/bin/theme-set $THEME"
else
  THEME_SET_NO_RELOAD=1 "$HOME/.local/bin/theme-set" "$THEME" \
    || die "theme-set failed (internet? imagemagick?). Hyprland needs the colour files it writes, so fix this and re-run."
fi

# ---------------------------------------------------------------- desktop settings
say "Setting GNOME/GTK settings (dark mode, teal accent, tray icons)"
gs() {  # gs SCHEMA KEY VALUE
  if [ "$DRY" = 1 ]; then echo "+ gsettings set $1 $2 $3"; return; fi
  if [ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then gsettings set "$1" "$2" "$3"
  else dbus-run-session -- gsettings set "$1" "$2" "$3" >/dev/null 2>&1; fi || warn "could not set $1 $2 (run it after logging in)"
}
gs org.gnome.desktop.interface color-scheme prefer-dark
gs org.gnome.desktop.interface accent-color teal
gs org.gnome.desktop.interface icon-theme neil-tray
gs org.gnome.desktop.interface cursor-size 24
gs org.blueman.general symbolic-status-icons true

# ---------------------------------------------------------------- system (sudo)
if [ "$SYSTEM" = 1 ]; then
  say "Enabling services"
  run sudo systemctl enable bluetooth.service NetworkManager.service sddm.service
  run sudo systemctl set-default graphical.target
  if [ "$EXTRAS" = 1 ]; then
    run systemctl --user enable syncthing.service || warn "could not enable syncthing for your user (run it after logging in)"
  fi

  say "Installing the SDDM login theme 'neil' (maya + a wallpaper background)"
  maya=/usr/share/sddm/themes/maya; neil=/usr/share/sddm/themes/neil
  if [ -d "$maya" ] || [ "$DRY" = 1 ]; then
    [ -d "$neil" ] || run sudo cp -a "$maya" "$neil"
    run sudo install -m 644 "$REPO/sddm/theme.conf" "$neil/theme.conf"
    if [ "$DRY" = 1 ]; then echo "+ sudo tee $neil/Main.qml (with @USER@ -> $USER)"
    else sed "s/@USER@/$USER/g" "$REPO/sddm/Main.qml" | sudo tee "$neil/Main.qml" >/dev/null; fi
    [ ! -f "$HOME/.config/hypr/assets/wallpaper.png" ] || run sudo install -m 644 "$HOME/.config/hypr/assets/wallpaper.png" "$neil/background.png"
    run sudo mkdir -p /etc/sddm.conf.d
    if [ "$DRY" = 1 ]; then echo "+ write /etc/sddm.conf.d/theme.conf (Current=neil)"
    else printf '[Theme]\nCurrent=neil\n' | sudo tee /etc/sddm.conf.d/theme.conf >/dev/null; fi
  else
    warn "$maya not found (is sddm installed?); skipping the login theme"
  fi
fi

# ---------------------------------------------------------------- done
cat <<EOF

==> Done$([ "$DRY" = 1 ] && echo " (dry run: nothing was changed)").

Still yours to do:
  * Reboot. At the SDDM login pick the "Hyprland (uwsm-managed)" session.
  * Monitors: edit the hl.monitor / hl.env lines at the top of ~/.config/hypr/hyprland.lua for your hardware.
  * Secrets and app logins (API keys, Telegram, etc.) are not in this repo; set those up yourself.
  * Switch theme any time with: theme-set --list, then theme-set <name>
  * Replaced files were backed up under $BACKUP (only if any differed).
EOF
