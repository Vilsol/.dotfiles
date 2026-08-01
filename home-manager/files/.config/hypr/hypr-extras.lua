-- Converted from hypr-extras.conf for Hyprland 0.55+ Lua configs.
-- Include from your main hyprland.lua via:  require("hypr-extras")

------------------
---- MONITORS ----
------------------

hl.monitor({ output = "DP-2", mode = "3840x2160@60", position = "0x0",    scale = 1, bitdepth = 10 })
hl.monitor({ output = "DP-3", mode = "3840x2160@60", position = "3840x0", scale = 1, bitdepth = 10 })


---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = "wofi --show drun"


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE",              "24")
hl.env("HYPRCURSOR_SIZE",           "24")
hl.env("LIBVA_DRIVER_NAME",         "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")


-------------------
---- AUTOSTART ----
-------------------

-- Set wallpaper after monitors are initialized, plus apply per-device input
-- tweaks and plugin window-rules that don't have a clean Lua wrapper.
hl.on("hyprland.start", function()
    -- Wallpaper
    hl.exec_cmd("sleep 2 && hyprctl hyprpaper preload ~/.background-image.png")
    hl.exec_cmd("sleep 2 && hyprctl hyprpaper wallpaper 'DP-3,~/.background-image.png'")
    hl.exec_cmd("sleep 2 && hyprctl hyprpaper wallpaper 'DP-2,~/.background-image.png'")

    -- Per-device input config (no clean Lua wrapper for `device { ... }`)
    hl.exec_cmd("hyprctl keyword 'device[epic-mouse-v1]:sensitivity' -0.6")

    -- Gradient border colors (hl.config doesn't roundtrip the gradient
    -- string format cleanly; pass directly to the .conf-grade parser).
    hl.exec_cmd("hyprctl keyword general:col.active_border 'rgba(33ccffee) rgba(00ff99ee) 45deg'")


end)


-- hyprbars no-bar rules removed (plugin disabled, see hyprland.nix).
-- Restore from git history if you re-enable hyprbars.


-----------------
---- PLUGINS ----
-----------------

-- Plugin loading is handled in hyprland.lua (home-manager).
-- hyprbars is currently disabled (see hyprland.nix). DMS provides its own
-- window decorations natively, so the plugin's title bars are redundant.
-- All hyprbars config/window-rules below were removed when the plugin was
-- disabled; restore from git history if you re-enable hyprbars.
--
-- split-monitor-workspaces has no parse-time config (its keys all reported
-- "unknown" against the current plugin version; defaults are in effect).


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in     = 0,
        gaps_out    = 0,
        border_size = 0,
        col = {
            -- active_border is set via hyprctl in on-start (gradient string)
            inactive_border = "rgba(595959aa)",
        },
        resize_on_border = true,
        allow_tearing    = true,
        layout           = "dwindle",
    },
    decoration = {
        rounding         = 0,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },
    dwindle = {
        -- Removed: pseudotile (not a valid keyword; `pseudo` is a per-window
        -- dispatcher, bound to SUPER+P in the keybinds section)
        preserve_split = true,
    },
    master = {
        new_status = "master",
    },
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = true,
        focus_on_activate       = true,
        middle_click_paste      = false,
    },
})

-- Animations: bezier curve + per-animation directives. The Lua API is
-- (name, { type, points }) for curves and ({ leaf, enabled, speed, bezier, style }) for animations.
hl.config({ animations = { enabled = true } })
hl.curve("myBezier", { type = "bezier", points = {{0.05, 0.9}, {0.1, 1.05}} })
hl.animation({ leaf = "windows",     enabled = true, speed = 7,  bezier = "myBezier" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 7,  bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",      enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8,  bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 7,  bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 3,  bezier = "default" })


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout    = "us,lv",
        kb_variant   = ",apostrophe",
        follow_mouse = 1,
        sensitivity  = -0.85,
        touchpad = {
            natural_scroll = false,
        },
    },
    binds = {
        scroll_event_delay = 1000,
    },
})


---------------------
---- KEYBINDINGS ----
---------------------

-- Apps + window management
hl.bind("SUPER + Q",     hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + C",     hl.dsp.window.close())
hl.bind("SUPER + M",     hl.dsp.exec_cmd("hyprctl dispatch exit"))
hl.bind("SUPER + L",     hl.dsp.exec_cmd("lock-screen"))
hl.bind("SUPER + E",     hl.dsp.exec_cmd(fileManager))
hl.bind("SUPER + V",     hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + R",     hl.dsp.exec_cmd(menu))
hl.bind("SUPER + P",     hl.dsp.exec_cmd("hyprctl dispatch pseudo"))     -- dwindle
hl.bind("SUPER + J",     hl.dsp.exec_cmd("hyprctl dispatch togglesplit")) -- dwindle

-- Focus movement (arrow keys)
hl.bind("SUPER + Left",  hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + Right", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + Up",    hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + Down",  hl.dsp.focus({ direction = "d" }))

-- split-monitor-workspaces plugin: switch workspace
-- Call the plugin's Lua API directly. `hyprctl dispatch <name> <args>` is
-- broken in Hyprland 0.55 (server wraps it as `hl.dispatch(<name> <args>)`
-- which is invalid Lua). Plugin functions execute immediately rather than
-- returning a dispatcher, so they must be wrapped in a closure for hl.bind.
local smw = hl.plugin.split_monitor_workspaces
for i = 1, 9 do
    hl.bind("SUPER + " .. i,         function() smw.workspace(tostring(i)) end)
    hl.bind("SUPER + SHIFT + " .. i, function() smw.move_to_workspace_silent(tostring(i)) end)
end
hl.bind("SUPER + 0",         function() smw.workspace("10") end)
hl.bind("SUPER + SHIFT + 0", function() smw.move_to_workspace_silent("10") end)

hl.bind("SUPER + bracketleft",  function() smw.workspace("r-1") end)
hl.bind("SUPER + bracketright", function() smw.workspace("r+1") end)

hl.bind("SUPER + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind("SUPER + mouse_down", function() smw.workspace("r-1") end)
hl.bind("SUPER + mouse_up",   function() smw.workspace("r+1") end)

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Utils
hl.bind("SUPER + W",
    hl.dsp.exec_cmd("hyprctl activewindow -j | jq --sort-keys | wl-copy"),
    { description = "Window info" })

-- Screenshots with Swappy annotation
hl.bind("Print",         hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | swappy -f -"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(
    "grim -g \"$(hyprctl activewindow -j | jq -r '\"\\(.at[0]),\\(.at[1]) \\(.size[0])x\\(.size[1])\"')\" - | swappy -f -"))
hl.bind("CTRL + Print",  hl.dsp.exec_cmd("grim - | swappy -f -"))

-- Warp terminal
hl.bind("SHIFT + ALT + T",
    hl.dsp.exec_cmd("bash -c 'xdg-open warp://action/new_tab?path=~ && wmctrl -a \"vilsol@\"'"))

-- Vicinae
hl.bind("SUPER + Space", hl.dsp.exec_cmd("dms ipc call spotlight toggle"))
hl.layer_rule({ match = { namespace = "vicinae" }, blur = true, ignore_alpha = 0, no_anim = true })

-- Volume knob (Keychron Q6 Max consumer-control): turn = raise/lower, press = mute.
-- locked = active on the lock screen; repeating = a fast spin keeps firing.
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),        { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),        { locked = true })


------------------------------------
---- WINDOWS AND WORKSPACE RULES ----
------------------------------------

-- Apps pinned to specific monitor + workspace
hl.window_rule({ match = { class = "^(org.telegram.desktop)$" }, workspace = "1", monitor = "DP-2" })
hl.window_rule({ match = { class = "^(vesktop)$" },              workspace = "2", monitor = "DP-2" })
hl.window_rule({ match = { class = "^(discord)$" },              workspace = "2", monitor = "DP-2" })

-- 1Password popup
hl.window_rule({
    match              = { class = "^(1password)$" },
    float              = true,
    center             = true,
    min_size           = { 900, 900 },
    no_max_size        = true,
    border_color       = "rgb(FF0000)",
    border_size        = 10,
    persistent_size    = true,
    keep_aspect_ratio  = true,
    no_screen_share    = true,
    render_unfocused   = true,
})

-- Telegram media viewer
hl.window_rule({
    match      = { class = "^(org.telegram.desktop)$", title = "^(Media viewer)$" },
    float      = true,
    size       = { "80%", "80%" },
    center     = true,
    fullscreen = false,
})

-- Suppress maximize events globally
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })


----------------------
---- DEBUG / MISC ----
----------------------

hl.config({
    debug = {
        disable_logs = true,
        disable_time = true,
    },
    xwayland = {
        force_zero_scaling = true,
    },
})


--------------------------
---- DMS-MANAGED BITS ----
--------------------------

-- Lua ports of files DMS writes into ~/.config/hypr/dms/*.conf.
-- Re-run the port whenever DMS regenerates the .conf files.
-- outputs.lua is intentionally NOT loaded here because it duplicates the
-- monitor declarations above (different refresh rate, no bitdepth). Pick one.
-- local dms = os.getenv("HOME") .. "/.config/hypr/dms"
-- dofile(dms .. "/colors.lua")
-- dofile(dms .. "/cursor.lua")
-- dofile(dms .. "/layout.lua")
-- dofile(dms .. "/outputs.lua")
