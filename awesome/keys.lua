local awful         = require('awful')
local gears         = require('gears')
local hotkeys_popup = require('awful.hotkeys_popup')
local menubar       = require('menubar')
local naughty       = require('naughty')

local globals = require('globals')
local utils   = require('utils')

require("awful.hotkeys_popup.keys")

---@diagnostic disable-next-line: deprecated
local unpack = table.unpack == nil and unpack or table.unpack

local function mod(keys)
  local mods = {}
  for _, key in ipairs(keys) do
    if key == 'mod' or key == 'Mod' then
      table.insert(mods, globals.modkey)
    else
      table.insert(mods, key)
    end
  end
  return mods
end

-- local function keytable(t)
--   local packed = {}
--   for _, keydef in ipairs(t) do
--     local keys = utils.string_split(keydef.keys or keydef[3], '+')
--     local modifiers = { unpack(keys) }
--     table.remove(modifiers, #modifiers)
--     local key = { unpack(keys) }
--     table.insert(packed, awful.key(
--       mod(modifiers),
--       key[#key],
--       keydef.exec or keydef[4],
--       { group = keydef.group or keydef[1], description = keydef.doc or keydef[2] }
--     ))
--   end
--   return unpack(packed)
-- end

local function keytable(t)
  local packed = {}

  for k, def in pairs(t) do
    local split_keys = utils.string_split(k, '+')
    local modifiers = { unpack(split_keys) }
    table.remove(modifiers, #modifiers) -- remove last key (the key to be bound)
    local key = split_keys[#split_keys] -- get the last key

    table.insert(packed, awful.key {
      modifiers = mod(modifiers),
      key = key,
      group = def.group or def[1],
      description = def.doc or def[2],
      on_press = def.exec or def[3],
    })
  end

  return unpack(packed)
end

local view_tag = awful.key {
  modifiers = { globals.modkey },
  keygroup = "numrow",
  description = "only view tag",
  group = "tag",
  on_press = function(n)
    local screen = awful.screen.focused()
    local tag = screen.tags[n]
    if tag then tag:view_only() end
  end,
}

local toggle_tag = awful.key {
  modifiers = { globals.modkey, "Control" },
  keygroup = "numrow",
  description = "toggle tag",
  group = "tag",
  on_press = function(n)
    local tag = awful.screen.focused().tags[n]
    if tag then awful.tag.viewtoggle(tag) end
  end,
}

local move_to_tag = awful.key {
  modifiers = { globals.modkey, "Shift" },
  keygroup = "numrow",
  description = "move focused client to tag",
  group = "tag",
  on_press = function(n)
    if client.focus then
      local tag = client.focus.screen.tags[n]
      if tag then client.focus:move_to_tag(tag) end
    end
  end,
}

local function unminimize()
  local c = awful.client.restore()
  if c then
    c:emit_signal('request::activate', 'key.unminimize', { raise = true })
  end
end

local function tiled()
  if (awful.layout.get(awful.screen.focused()) == awful.layout.suit.tile) then
    awful.layout.set(awful.layout.suit.tile.bottom)
  else
    awful.layout.set(awful.layout.suit.tile)
  end
end

local keys = { keyboard = {}, mouse = {} }

local function _t(t) return function(desc, exec) return { t, desc, exec } end end

local awe = _t('aweesome')
local cli = _t('client')
local lay = _t('layout')
local prg = _t('programs')
local sys = _t('system')

keys.keyboard.global = gears.table.join(view_tag, toggle_tag, move_to_tag, keytable {
  ['mod+h']                 = awe('show help', hotkeys_popup.show_help),
  ['mod+Shift+r']           = awe('reload', awesome.restart),
  ['mod+Shift+e']           = awe('exit', function() awful.spawn("sudo systemctl restart ly") awesome.quit() end),
  ['mod+Right']             = cli('focus next', function() awful.client.focus.byidx(1) end),
  ['mod+Left']              = cli('focus prev', function() awful.client.focus.byidx(-1) end),
  ['mod+Shift+Right']       = cli('swap with next', function() awful.client.swap.byidx(1) end),
  ['mod+Shift+Left']        = cli('swap with prev', function() awful.client.swap.byidx(-1) end),
  ['mod+Shift+n']           = cli('unminimize', unminimize),
  ['mod+Control+Right']     = lay('inc master width', function() awful.tag.incmwfact(0.05) end),
  ['mod+Control+Left']      = lay('dec master width', function() awful.tag.incmwfact(-0.05) end),
  ['mod+Control+Down']      = lay('dec master count', function() awful.tag.incnmaster(-1, nil, true) end),
  ['mod+Control+Up']        = lay('inc master count', function() awful.tag.incnmaster(1, nil, true) end),
  ['mod+w']                 = lay('tab layout', function() awful.layout.set(awful.layout.suit.max) end),
  ['mod+o']                 = lay('tiled/fair', tiled),
  ['mod+space']             = lay('cycle layout', function() awful.layout.inc(1) end),
  ['Print']                 = prg('take screenshot', function() awful.spawn(globals.screenshot_tool) end),
  ['mod+Return']            = prg('open terminal', function() awful.spawn(globals.terminal) end),
  ['mod+Shift+d']           = prg('show exec prompt', function() awful.screen.focused().prompt_widget:run() end),
  ['mod+d']                 = prg('show launcher', function() menubar.show() end),
  ['mod+b']                 = prg('set backlight', function() awful.spawn('backlight') end),
  ['mod+k']                 = prg('xkill', function() awful.spawn('xkill-notify') end),
  ['mod+Shift+c']           = prg('color picker', function() awful.spawn('sh -c "gpick -so | xclip -selection clipboard"') end),
  ['mod+c']                 = prg('vscode', function() awful.spawn(globals.rofi.code) end),
  ['mod+apostrophe']        = prg('greenclip', function() awful.spawn(globals.rofi.clipboard) end),
  ['mod+e']                 = prg('emoji picker', function() awful.spawn(globals.rofi.emoji) end),
  ['mod+s']                 = prg('calculator', function() awful.spawn(globals.rofi.calc) end),
  ['mod+z']                 = prg('authy', function() awful.spawn('/usr/bin/electron9 --app /usr/lib/authy/app.asar') end),
  ['mod+p']                 = sys('power menu', function() awful.spawn(globals.rofi.powermenu) end),
  ['mod+Shift+l']           = sys('lock', function() awful.spawn('lock') end),
  ['XF86MonBrightnessUp']   = sys('inc backlight', function() awful.spawn('light -A 5') end),
  ['XF86MonBrightnessDown'] = sys('dec backlight', function() awful.spawn('light -U 5') end),
  ['XF86KbdBrightnessUp']   = sys('inc kbd backlight', function() awful.spawn('light -s sysfs/leds/asus::kbd_backlight -r -A 1') end),
  ['XF86KbdBrightnessDown'] = sys('dec kbd backlight', function() awful.spawn('light -s sysfs/leds/asus::kbd_backlight -r -U 1') end),
  ['XF86AudioRaiseVolume']  = sys('inc volume', globals.pulseaudio.volume_up),
  ['XF86AudioLowerVolume']  = sys('dec volume', globals.pulseaudio.volume_down),
  ['XF86AudioMute']         = sys('toggle mute', globals.pulseaudio.toggle_muted),
})

keys.keyboard.client = gears.table.join(keytable {
  ['mod+Shift+Return']        = cli('swap with master', function(c) c:swap(awful.client.getmaster()) end),
  ['mod+Shift+q']             = cli('kill', function(c) c:kill() end),
  ['mod+n']                   = cli('minimize', function(c) c.minimized = true end),
  ['mod+a']                   = cli('toggle on top', function(c) c.ontop = not c.ontop end),
  ['mod+m']                   = cli('toggle maximized', function(c) c.maximized = not c.maximized end),
  ['mod+x']                   = cli('toggle sticky', function(c) c.sticky = not c.sticky end),
  ['mod+f']                   = cli('toggle fullscreen', function(c) c.fullscreen = not c.fullscreen; c:raise() end),
  ['mod+Shift+space']         = cli('toggle floating', function(c) c.floating = not c.floating end),
  ['mod+Shift+Control+Right'] = cli('move to next screen', function(c) c:move_to_screen(c.screen.index + 1) end),
  ['mod+Shift+Control+Left']  = cli('move to prev screen', function(c) c:move_to_screen(c.screen.index - 1) end),
})

keys.mouse.global = gears.table.join(
  awful.button({ globals.modkey }, 4, awful.tag.viewprev),
  awful.button({ globals.modkey }, 5, awful.tag.viewnext)
)

keys.mouse.client = gears.table.join(
  awful.button({}, 1, function(c) c:activate { context = "mouse_click" } end),
  awful.button({ globals.modkey }, 1, function(c) c:activate { context = "mouse_click", action = "mouse_move" } end),
  awful.button({ globals.modkey }, 3, function(c) c:activate { context = "mouse_click", action = "mouse_resize" } end),
  awful.button({ globals.modkey }, 4, function() awful.tag.viewprev() end),
  awful.button({ globals.modkey }, 5, function() awful.tag.viewnext() end)
)

return keys
