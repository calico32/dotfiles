local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local naughty = require('naughty')
local wibox = require('wibox')

local battery = require('battery')
local light = require('light')
local globals = require('globals')
local menu = require('menu')

local bar = {}

function bar.init(screen)
  screen.prompt_widget = awful.widget.prompt()
  screen.launcher_widget = awful.widget.launcher {
    image = beautiful.awesome_icon,
    menu = menu.main,
  }
  screen.launcher_widget.clip_shape = function(cr, width, height) return gears.shape.rounded_rect(cr, width, height, 4) end

  screen.taglist_widget = awful.widget.taglist {
    screen = screen,
    filter  = awful.widget.taglist.filter.noempty,
    layout = {
      spacing = 6,
      layout = wibox.layout.fixed.horizontal,
    },
    style = {
      squares_sel = '',
      squares_unsel = '',
      squares_sel_empty = '',
      squares_unsel_empty = '',
      shape = function(cr, width, height) return gears.shape.rounded_rect(cr, width, height, 4) end,
    },
    buttons = gears.table.join(
      awful.button({}, 1, function(t) t:view_only() end),
      awful.button({}, 3, awful.tag.viewtoggle),
      awful.button({}, 4, function(t) awful.tag.viewprev(t.screen) end),
      awful.button({}, 5, function(t) awful.tag.viewnext(t.screen) end)
    ),
    widget_template = {
      widget = wibox.container.background,
      id = 'background_role',
      {
        widget = wibox.layout.stack,
        fill_space = true,
        {
          widget = wibox.container.place,
          valign = 'center',
          halign = 'center',
          {
            widget = wibox.container.margin,
            left = 3,
            right = 3,
            { widget = wibox.widget.textbox, id = 'text_role' },
          },
        },
      }
    }
  }

  screen.tasklist_widget = awful.widget.tasklist {
    screen = screen,
    filter = awful.widget.tasklist.filter.currenttags,
    style = {
      shape = function(cr, width, height) return gears.shape.rounded_rect(cr, width, height, 4) end,
      bg_minimize = beautiful.bg_normal,
      shape_border_width_minimized = 1,
      shape_border_color_minimized = beautiful.bg_focus,
    },
    buttons = gears.table.join(
      awful.button({}, 1, function(c)
        if c == client.focus then c.minimized = true
        else c:activate { context = "tasklist", action = "toggle_minimization" } end
      end),
      awful.button({}, 2, function(c) c:kill() end),
      awful.button({}, 3, function() awful.menu.client_list({ theme = { width = 500 } }) end),
      awful.button({}, 4, function() awful.client.focus.byidx(1) end),
      awful.button({}, 5, function() awful.client.focus.byidx(-1) end)
    ),
    layout   = {
      spacing = 6,
      layout = wibox.layout.flex.horizontal
    },
    widget_template = {
      widget = wibox.container.background,
      id = 'background_role',
      {
        widget = wibox.container.margin,
        left = 10,
        right = 10,
        {
          layout = wibox.layout.fixed.horizontal,
          {
            widget = wibox.container.margin,
            left = -2,
            right = 8,
            {
              widget = wibox.container.place,
              {
                widget = wibox.container.constraint,
                height = 24,
                width = 24,
                { id = 'icon_role', widget = wibox.widget.imagebox },
              },
            },
          },
          { widget = wibox.widget.textbox, id = 'text_role' },
        },
      },
    },
  }

  screen.tray_widget = wibox.widget.systray()

  screen.clock_widget = wibox.widget {
    widget = wibox.container.margin,
    left = 8,
    right = 8,
    {
      -- forced_width = 280,
      format = '<span size="small">%a %b %d, %I:%M:%S %p</span>',
      refresh = 1,
      font = 'Iosevka Custom',
      widget = wibox.widget.textclock
    }
  }

  -- screen.light_widget = light {
  --   screen = screen
  -- }

  -- screen.battery1_widget = battery {
  --   screen = screen,
  --   device_path = '/org/freedesktop/UPower/devices/battery_BAT1',
  -- }

  screen.battery2_widget = battery {
    screen = screen,
    device_path = '/org/freedesktop/UPower/devices/battery_BAT2',
  }

  screen.layout_widget = awful.widget.layoutbox {
    screen = screen,
    buttons = gears.table.join(
      awful.button({}, 1, function() awful.layout.inc(1) end),
      awful.button({}, 4, function() awful.layout.inc(1) end),
      awful.button({}, 3, function() awful.layout.inc(-1) end),
      awful.button({}, 5, function() awful.layout.inc(-1) end)
    ),
  }

  screen.bar = awful.wibar {
    position = 'top',
    screen = screen,
    border_width = 6,
    border_color = beautiful.bg_normal
  }
  screen.bar:setup {
    layout = wibox.layout.align.horizontal,
    -- left
    {
      layout = wibox.layout.fixed.horizontal,
      screen.launcher_widget,
      wibox.widget { forced_width = 6 },
      screen.taglist_widget,
      wibox.widget { forced_width = 6 },
    },
    -- middle
    screen.tasklist_widget,
    -- right
    {
      layout = wibox.layout.fixed.horizontal,
      wibox.widget { forced_width = 10 },
      screen.tray_widget,
      wibox.widget { forced_width = 6 },
      screen.clock_widget,
      -- screen.light_widget,
      -- screen.battery1_widget,
      screen.battery2_widget,
      globals.pulseaudio,
      wibox.widget { forced_width = 6 },
      screen.layout_widget,
    }
  }

  return screen.bar
end

return bar
