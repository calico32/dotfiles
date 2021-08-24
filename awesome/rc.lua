pcall(function() jit.on() end)

local naughty = require('naughty')
naughty.connect_signal('request::display_error', function(message, startup)
  naughty.notification {
    urgency = 'critical',
    title = (startup and "Startup" or "Runtime") .. " error!",
    message = message
  }
end)

local awful = require('awful')
require('awful.autofocus')

local array = require('array')
local beautiful = require('beautiful')
local gears = require('gears')
local ruled = require('ruled')
local delayed_call = require('gears.timer').delayed_call
-- local round_up_client_corners = require('shape').round_up_client_corners

beautiful.init(os.getenv('XDG_CONFIG_HOME') .. '/awesome/theme.lua')

local globals = require('globals')
local bar = require('bar')
local keys = require('keys')
local utils = require('utils')

awful.layout.layouts = {
  awful.layout.suit.tile,
  awful.layout.suit.floating,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.max,
}

local function set_wallpaper(screen)
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    if type(wallpaper) == 'function' then
      wallpaper = wallpaper(screen)
    end
    gears.wallpaper.maximized(wallpaper, screen, true)
  end
end

-- set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal('property::geometry', set_wallpaper)

awful.screen.connect_for_each_screen(function(screen)
  -- wallpaper
  set_wallpaper(screen)

  -- set tags
  screen._tags = array.map(
    utils.table_pad_end(globals.tags, 9, function(i) return i end),
    function(t) return '  ' .. t .. '  ' end
  )
  awful.tag(screen._tags, screen, awful.layout.layouts[1])

  bar.init(screen)
end)

root.keys(keys.keyboard.global)
root.buttons(keys.mouse.global)

ruled.client.connect_signal("request::rules", function()
  ruled.client.append_rule {
    id = "global",
    rule = {},
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      raise = true,
      keys = keys.keyboard.client,
      buttons = keys.mouse.client,
      screen = awful.screen.preferred,
      -- placement = awful.placement.no_overlap + awful.placement.no_offscreen,
    }
  }
  ruled.client.append_rule {
    id = "floating",
    rule_any = {
      instance = {'pinentry'},
      class = {'feh', 'Msgcompose', 'KeePassXC', 'Blueman-manager'},
      name = {'Event Tester', 'Page Unresponsive', 'Address Book', 'Zoom - Free Account'},
      role = {'pop-up'},
      type = {'dialog'},
    },
    properties = { floating = true }
  }

  ruled.client.append_rule {
    id = "idea win0 floating",
    rule = {
      class = {'jetbrains-idea'},
      name = {'win0'},
    },
    properties = { floating = true }
  }

  ruled.client.append_rule {
    id = "idea welcome floating",
    rule = {
      class = {'jetbrains-idea'},
      name = {'Welcome to IntelliJ IDEA'},
    },
    properties = { floating = true }
  }

  ruled.client.append_rule {
    id = "not ytm floating",
    rule = {
      class = {'crx_cinhimbnkkaeohfgghhklpknlkffjgod'},
      name = {'YouTube Music'},
    },
    properties = { floating = false, screen = 1, tag = awful.screen.focused()._tags[5] }
  }

  ruled.client.append_rule {
    rule_any = { type = {'normal', 'dialog'} },
    properties = { titlebars_enabled = false }
  }
  ruled.client.append_rule {
    rule_any = { class = {'discord', 'element'} },
    properties = { tag = awful.screen.focused()._tags[3] }
  }
  ruled.client.append_rule {
    rule_any = { class = {'zoom'} },
    properties = { tag = awful.screen.focused()._tags[4] }
  }
end)

ruled.notification.connect_signal('request::rules', function()
  ruled.notification.append_rule {
    rule = {},
    properties = {
      screen = awful.screen.preferred,
      implicit_timeout = 2.5,
    }
  }
end)

-- client.connect_signal('request::manage', function(c)
--   local awesome_startup = awesome.startup
--   delayed_call(function()
--     if c == client.focus then
--       if awesome_startup then
--         round_up_client_corners(c, false, 'MF')
--       end
--     else
--       if awesome_startup then
--         round_up_client_corners(c, false, 'MU')
--       end
--     end
--   end)
-- end)

-- client.connect_signal('property::size', function(c)
--   if not awesome.startup then
--     round_up_client_corners(c, false, 'S')
--   end
-- end)

-- focus follows mouse
client.connect_signal('mouse::enter', function(c) c:activate { context = "mouse_enter", raise = false } end)
client.connect_signal('focus', function(c) c.border_color = beautiful.border_focus end)
client.connect_signal('unfocus', function(c) c.border_color = beautiful.border_normal end)

-- autostart
awful.spawn('fish ' .. os.getenv('XDG_CONFIG_HOME') .. '/awesome/autostart.fish', nil, nil, 'autostart')
