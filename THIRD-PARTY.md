# Third-party material

This repo's own files are MIT (see `LICENSE`). Some files started from other people's MIT-licensed work.

## cebem1nt/dotfiles (MIT, Copyright (c) 2026 cebem1nt)

https://github.com/cebem1nt/dotfiles. Used as the starting point for:

- `config/waybar/` (`config.jsonc`, `modules.hyprland.jsonc`, `style.css`, `context/*.xml`)
- `bin/caffeine`, `bin/powersafe`, `bin/refreshrate`, `bin/toggle_bluetooth`

All modified here: Hyprland-Lua syntax fixes, X230-sized layout, `theme-set` colour wiring, removed modules.

The MIT licence text and copyright notice for that work:

> Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
> documentation files (the "Software"), to deal in the Software without restriction, including without limitation
> the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
> to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above
> copyright notice and this permission notice shall be included in all copies or substantial portions of the
> Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
> LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT
> SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
> OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
> DEALINGS IN THE SOFTWARE.

## SDDM "maya" theme (MIT for QML; icons CC-BY 4.0; font Apache 2.0)

`sddm/Main.qml` is a rewrite of the `maya` theme's `Main.qml` that ships with the `sddm` package. The installer copies
the rest of `maya` from your own machine and overlays these two files; no `maya` assets are bundled here.

## Omarchy (MIT)

https://github.com/omacom/omarchy. `bin/theme-set` downloads Omarchy's theme palettes and wallpapers from GitHub at
run time. None are bundled. `webapp-install` and the keybindings follow Omarchy's behaviour; the code is original.
