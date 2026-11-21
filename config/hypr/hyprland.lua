-- Hyprland Lua config -- ThinkPad X230
-- Built with Neil / Echo, 2026-09-20.

local colors = {}
for line in io.lines(os.getenv("HOME") .. "/.config/hypr/colors.conf") do
    local var, val = line:match("%$(%w+)%s*=%s*(%w+)")
    if var and val then colors[var] = val end
end
local c = colors

-- Hardware-specific (ThinkPad X230 + an external VGA monitor). Edit for your machine; see README.
hl.monitor({ output = "VGA-1",  mode = "1920x1080@60", position = "0x0",    scale = "1" })
hl.monitor({ output = "LVDS-1", mode = "preferred",    position = "1920x0", scale = "1" })
hl.env("XCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("LIBVA_DRIVER_NAME", "i965")

hl.config({
    general = {
        gaps_in = 4, gaps_out = 8, border_size = 2,
        col = {
            active_border = { colors = {"rgba(" .. c.accent .. "ff)", "rgba(" .. c.accent2 .. "ff)"}, angle = 45 },
            inactive_border = "rgba(" .. c.muted .. "aa)",
        },
        layout = "dwindle", allow_tearing = false,
    },
    decoration = {
        rounding = 6,
        blur = { enabled = true, size = 4, passes = 1, new_optimizations = true },
        shadow = { enabled = true, range = 8, render_power = 2 },
    },
    input = {
        kb_layout = "us", follow_mouse = 1,
        touchpad = { natural_scroll = true, tap_to_click = true, disable_while_typing = true },
        sensitivity = 0,
    },
    misc = { disable_hyprland_logo = true, disable_splash_rendering = true },
    dwindle = { preserve_split = true },
    master = { new_status = "master" },
    animations = { enabled = true },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1}, {0.32, 1} } })
hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "easeOutQuint", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "easeOutQuint" })

hl.on("hyprland.start", function()
  hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
  hl.exec_cmd("hyprpaper")
  hl.exec_cmd("waybar")
  hl.exec_cmd("swaync")
  hl.exec_cmd("hypridle")
  local vg = os.getenv("HOME") .. "/vault-graph/server.py"   -- optional personal tool, only if present
  local f = io.open(vg)
  if f then f:close(); hl.exec_cmd("python3 " .. vg) end
end)

local terminal = "foot"
local launcher = "fuzzel"
local browser  = "chromium"
local mod      = "SUPER"

hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + SPACE", hl.dsp.exec_cmd(launcher))
hl.bind(mod .. " + W", hl.dsp.window.close())
hl.bind(mod .. " + SHIFT + Q", hl.dsp.exit())
hl.bind(mod .. " + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mod .. " + P", hl.dsp.window.pseudo({ action = "toggle" }))
hl.bind(mod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + CTRL + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mod .. " + SHIFT + F", hl.dsp.exec_cmd("uwsm-app -- nautilus --new-window"))
hl.bind(mod .. " + SHIFT + ALT + F", hl.dsp.exec_cmd("nautilus-here"))

hl.bind(mod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(mod .. " + L", hl.dsp.focus({ direction = "r" }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(mod .. " + left", hl.dsp.focus({ direction = "l" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mod .. " + up", hl.dsp.focus({ direction = "u" }))
hl.bind(mod .. " + down", hl.dsp.focus({ direction = "d" }))

hl.bind(mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "l" }))
hl.bind(mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "r" }))
hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "d" }))
hl.bind(mod .. " + SHIFT + left", hl.dsp.window.swap({ direction = "l" }))
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "r" }))
hl.bind(mod .. " + SHIFT + up", hl.dsp.window.swap({ direction = "u" }))
hl.bind(mod .. " + SHIFT + down", hl.dsp.window.swap({ direction = "d" }))

for i = 1, 10 do
    local ws = tostring(i == 10 and 0 or i)
    hl.bind(mod .. " + " .. ws, hl.dsp.focus({ workspace = tostring(i) }))
    hl.bind(mod .. " + SHIFT + " .. ws, hl.dsp.exec_cmd("hyprctl dispatch movetoworkspace " .. i))
    hl.bind(mod .. " + SHIFT + ALT + " .. ws, hl.dsp.exec_cmd("hyprctl dispatch movetoworkspacesilent " .. i))
end

hl.bind(mod .. " + O", hl.dsp.exec_cmd("obsidian"))

hl.bind(mod .. " + S", hl.dsp.exec_cmd("hyprctl dispatch workspace special:magic"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprctl dispatch movetoworkspace special:magic"))
hl.bind(mod .. " + mouse_down", hl.dsp.exec_cmd("hyprctl dispatch workspace e+1"))
hl.bind(mod .. " + mouse_up", hl.dsp.exec_cmd("hyprctl dispatch workspace e-1"))
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))
hl.bind(mod .. " + Print", hl.dsp.exec_cmd("grim - | wl-copy"))
hl.bind(mod .. " + SHIFT + Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"))

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { repeating = true })

-- Omarchy-matched binds (2026-11-14)
hl.bind(mod .. " + T", hl.dsp.exec_cmd(terminal .. " -e btop"))
hl.bind(mod .. " + CTRL + Return", hl.dsp.exec_cmd(terminal .. " -e herdr"))
hl.bind("SHIFT + F11", hl.dsp.exec_cmd("hyprctl dispatch fullscreen 0"))
hl.bind("ALT + F11", hl.dsp.exec_cmd("hyprctl dispatch fullscreen 1"))
hl.bind(mod .. " + TAB", hl.dsp.exec_cmd("hyprctl dispatch workspace e+1"))
hl.bind(mod .. " + SHIFT + TAB", hl.dsp.exec_cmd("hyprctl dispatch workspace e-1"))
hl.bind(mod .. " + CTRL + TAB", hl.dsp.exec_cmd("hyprctl dispatch workspace previous"))
hl.bind("ALT + TAB", hl.dsp.exec_cmd("hyprctl dispatch cyclenext"))
hl.bind("ALT + SHIFT + TAB", hl.dsp.exec_cmd("hyprctl dispatch cyclenext prev"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))

hl.window_rule({ suppress_event = "maximize" })