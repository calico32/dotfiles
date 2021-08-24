local awful = require('awful')
local gears = require('gears')
local hotkeys_popup = require('awful.hotkeys_popup')
local menubar = require('menubar')

local globals = require('globals')
local light = require('light')
local utils = require('utils')

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

local function keytable(t)
  local packed = {}
  for _, keydef in ipairs(t) do
    local keys = utils.string_split(keydef.keys or keydef[3], '+')
    local modifiers = {unpack(keys)}
    table.remove(modifiers, #modifiers)
    local key = {unpack(keys)}
    table.insert(packed, awful.key(
      mod(modifiers),
      key[#key],
      keydef.exec or keydef[4],
      { group = keydef.group or keydef[1], description = keydef.doc or keydef[2] }
    ))
  end
  return unpack(packed)
end


local view_tag = awful.key {
  modifiers = {globals.modkey},
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
  modifiers = {globals.modkey, "Control"},
  keygroup = "numrow",
  description = "toggle tag",
  group = "tag",
  on_press = function(n)
    local tag = awful.screen.focused().tags[n]
    if tag then awful.tag.viewtoggle(tag) end
  end,
}

local move_to_tag = awful.key {
  modifiers = {globals.modkey, "Shift"},
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
    c:emit_signal('request::activate', 'key.unminimize', {raise = true})
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

keys.keyboard.global = gears.table.join(view_tag, toggle_tag, move_to_tag, keytable {
  {'awesome',  'show help',         'mod+s',                hotkeys_popup.show_help},
  {'awesome',  'reload',            'mod+Shift+r',          awesome.restart},
  {'awesome',  'exit',              'mod+Shift+e',          function() awful.spawn(globals.exit_script) end},
  {'client',   'focus next',        'mod+Right',            function() awful.client.focus.byidx(1) end},
  {'client',   'focus prev',        'mod+Left',             function() awful.client.focus.byidx(-1) end},
  {'client',   'swap with next',    'mod+Shift+Right',      function() awful.client.swap.byidx(1) end},
  {'client',   'swap with prev',    'mod+Shift+Left',       function() awful.client.swap.byidx(-1) end},
  {'client',   'unminimize',        'mod+Shift+n',          unminimize},
  {'layout',   'inc master width',  'mod+Control+Right',    function() awful.tag.incmwfact(0.05) end},
  {'layout',   'dec master width',  'mod+Control+Left',     function() awful.tag.incmwfact(-0.05) end},
  {'layout',   'dec master count',  'mod+Control+Down',     function() awful.tag.incnmaster(-1, nil, true) end},
  {'layout',   'inc master count',  'mod+Control+Up',       function() awful.tag.incnmaster(1, nil, true) end},
  {'layout',   'tab layout',        'mod+w',                function() awful.layout.set(awful.layout.suit.max) end},
  {'layout',   'tiled/fair',        'mod+e',                tiled},
  {'layout',   'cycle layout',      'mod+space',            function() awful.layout.inc(1) end},
  {'programs', 'take screenshot',   'Print',                function() awful.spawn(globals.screenshot_tool) end},
  {'programs', 'open terminal',     'mod+Return',           function() awful.spawn(globals.terminal) end},
  {'programs', 'show exec prompt',  'mod+Shift+d',          function() awful.screen.focused().prompt_widget:run() end},
  {'programs', 'show launcher',     'mod+d',                function() menubar.show() end},
  {'programs', 'set backlight',     'mod+b',                function() awful.spawn('backlight') end},
  {'programs', 'xkill',             'mod+k',                function() awful.spawn('xkill-notify') end},
  {'programs', 'start picom',       'mod+p',                function() awful.spawn('picom -b --experimental-backends') end},
  {'programs', 'stop picom',        'mod+Shift+p',          function() awful.spawn('pkill picom') end},
  {'programs', 'lock',              'mod+Shift+l',          function() awful.spawn('lock') end},
  {'audio',    'inc volume',        'XF86AudioRaiseVolume', globals.pulseaudio.volume_up},
  {'audio',    'dec volume',        'XF86AudioLowerVolume', globals.pulseaudio.volume_down},
  {'audio',    'toggle mute',       'XF86AudioMute',        globals.pulseaudio.toggle_muted},
  {'iot',      'toggle light',      'mod+a',                light.toggle},
})

keys.keyboard.client = gears.table.join(keytable {
  {'client',   'swap with master',    'mod+Shift+Return',        function(c) c:swap(awful.client.getmaster()) end},
  {'client',   'kill',                'mod+Shift+q',             function(c) c:kill() end},
  {'client',   'minimize',            'mod+n',                   function(c) c.minimized = true end},
  {'client',   'toggle on top',       'mod+t',                   function(c) c.ontop = not c.ontop end},
  {'client',   'toggle maximized',    'mod+m',                   function(c) c.maximized = not c.maximized end},
  {'client',   'toggle sticky',       'mod+x',                   function(c) c.sticky = not c.sticky end},
  {'client',   'toggle fullscreen',   'mod+f',                   function(c) c.fullscreen = not c.fullscreen; c:raise() end},
  {'client',   'toggle floating',     'mod+Shift+space',         function(c) c.floating = not c.floating end},
  {'client',   'move to next screen', 'mod+Shift+Control+Right', function(c) c:move_to_screen(c.screen.index + 1) end},
  {'client',   'move to prev screen', 'mod+Shift+Control+Left',  function(c) c:move_to_screen(c.screen.index - 1) end},
})

keys.mouse.global = gears.table.join(
  awful.button({globals.modkey}, 4, awful.tag.viewprev),
  awful.button({globals.modkey}, 5, awful.tag.viewnext)
)

keys.mouse.client = gears.table.join(
  awful.button({},               1, function(c) c:activate { context = "mouse_click" } end),
  awful.button({globals.modkey}, 1, function(c) c:activate { context = "mouse_click", action = "mouse_move" } end),
  awful.button({globals.modkey}, 3, function(c) c:activate { context = "mouse_click", action = "mouse_resize" } end),
  awful.button({globals.modkey}, 4, function() awful.tag.viewprev() end),
  awful.button({globals.modkey}, 5, function() awful.tag.viewnext() end)
)

return keys
