local awful     = require('awful')
local beautiful = require('beautiful')
local gears     = require('gears')
local naughty   = require('naughty')
local wibox     = require('wibox')
local lain      = require('lain')
local markup    = lain.util.markup
local dpi       = require('beautiful.xresources').apply_dpi

local battery = require('battery')
local color   = require('twcolor')
local globals = require('globals')
local menu    = require('menu')
local utils   = require('utils')

local w = utils.table_template('widget')
local l = utils.table_template('layout')

local bar = {}

function bar.init(screen)
  screen.prompt_widget = awful.widget.prompt()
  -- screen.launcher_widget = awful.widget.launcher {
  --   image = beautiful.awesome_icon,
  --   menu = menu.main,
  -- }
  -- screen.launcher_widget.clip_shape = function(cr, width, height) return gears.shape.rounded_rect(cr, width, height, 4) end

  screen.taglist_widget = awful.widget.taglist {
    screen = screen,
    filter = awful.widget.taglist.filter.noempty,
    layout = {
      spacing = 6,
      layout = wibox.layout.fixed.horizontal,
    },

    style = {
      squares_sel = '',
      squares_unsel = '',
      squares_sel_empty = '',
      squares_unsel_empty = '',
      -- shape = function(cr, width, height) return gears.shape.rounded_rect(cr, width, height, 4) end,
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
      w(wibox.layout.stack) {
        fill_space = true,
        w(wibox.container.place) {
          valign = 'center',
          halign = 'center',
          w(wibox.container.margin) {
            left = 8,
            right = 8,
            w(wibox.widget.textbox) {
              id = 'text_role',
            }
          },
        },
      }
    }
  }

  screen.tasklist_widget = awful.widget.tasklist {
    screen = screen,
    filter = awful.widget.tasklist.filter.currenttags,
    style = {
      -- shape = function(cr, width, height) return gears.shape.rounded_rect(cr, width, height, 4) end,
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
      awful.button({}, 3, function() awful.menu.client_list() end),
      awful.button({}, 4, function() awful.client.focus.byidx(1) end),
      awful.button({}, 5, function() awful.client.focus.byidx(-1) end)
    ),
    layout = l(wibox.layout.flex.horizontal) {
      spacing = 6,
    },
    widget_template = w(wibox.container.background) {
      id = 'background_role',
      w(wibox.container.margin) {
        left = 10,
        right = 10,

        l(wibox.layout.fixed.horizontal) {
          w(wibox.container.margin) {
            left = -2,
            right = 8,

            w(wibox.container.place) {

              w(wibox.container.constraint) {
                height = 16,
                width = 16,

                w(wibox.widget.imagebox) {
                  id = 'icon_role',
                },
              },
            },
          },
          w(wibox.widget.textbox) {
            id = 'text_role'
          },
        },
      },
    },
  }

  screen.tray_widget = wibox.widget.systray {}

  -- screen.battery_widget = battery {
  --   screen = screen,
  --   device_path = '/org/freedesktop/UPower/devices/battery_BAT0',
  -- }

  screen.layout_widget = awful.widget.layoutbox {
    screen = screen,
    buttons = gears.table.join(
      awful.button({}, 1, function() awful.layout.inc(1) end),
      awful.button({}, 4, function() awful.layout.inc(1) end),
      awful.button({}, 3, function() awful.layout.inc(-1) end),
      awful.button({}, 5, function() awful.layout.inc(-1) end)
    ),
  }

  local colors = color.generator:new(400)
  local color_index = colors:init()

  local function span(color, text)
    return string.format("<span foreground='%s'>%s</span>", color, text)
  end

  local netdowncolor = colors:next()
  screen.network_down = lain.widget.net {
    timeout = 2,
    settings = function()
      widget:set_markup(span(netdowncolor, "net↓ " .. net_now.received .. " KB/s"))
    end
  }

  local netupcolor = colors:next()
  screen.network_up = lain.widget.net {
    timeout = 2,
    settings = function()
      widget:set_markup(span(netupcolor, "net↑ " .. net_now.sent .. " KB/s"))
    end
  }

  local cpucolor = colors:next()
  screen.cpu = lain.widget.cpu {
    timeout = 2,
    settings = function()
      widget:set_markup(span(cpucolor, "cpu " .. cpu_now.usage .. "%"))
    end
  }

  local memcolor = colors:next()
  screen.memory = lain.widget.mem {
    timeout = 2,
    settings = function()
      widget:set_markup(span(memcolor, "mem " .. mem_now.used .. "MB"))
    end
  }

  local batcolor = colors:next()
  screen.battery = lain.widget.bat {
    timeout = 2,
    settings = function()
      local perc = bat_now.perc ~= "N/A" and bat_now.perc .. "%" or bat_now.perc

      if bat_now.ac_status == 1 then
        perc = "+" .. perc
      end

      widget:set_markup(span(batcolor, "bat " .. perc))
    end
  }

  local tempcolor = colors:next()
  screen.temp = lain.widget.temp {
    timeout = 2,
    settings = function()
      widget:set_markup(span(tempcolor, "temp " .. coretemp_now .. "°C"))
    end
  }

  local volcolor = colors:next()
  screen.volume = lain.widget.pulse {
    timeout = 2,
    settings = function()
      if volume_now.status == "off" then
        volume_now.level = volume_now.level .. "M"
      end

      -- naughty.notify { text = utils.table_tostring(volume_now) }

      widget:set_markup(span(volcolor, "vol 50%"))
    end
  }

  local function recolor()
    colors.current = color_index + 1
    if colors.current > #colors.list then
      colors.current = 1
    end
    color_index  = colors.current
    netdowncolor = colors:next()
    netupcolor   = colors:next()
    cpucolor     = colors:next()
    memcolor     = colors:next()
    batcolor     = colors:next()
    tempcolor    = colors:next()
    volcolor     = colors:next()
  end

  local color_timer = gears.timer.new {
    timeout = 8,
    autostart = true,
    callback = recolor,
  }

  local do_recolor = function(_, _, _, button)
    if button == 1 then
      recolor()
    end
    screen.network_down.update()
    screen.network_up.update()
    screen.cpu.update()
    screen.memory.update()
    screen.battery.update()
    screen.temp.update()
    screen.volume.update()
  end

  screen.network_down.widget:connect_signal("button::press", do_recolor)
  screen.network_up.widget:connect_signal("button::press", do_recolor)
  screen.cpu.widget:connect_signal("button::press", do_recolor)
  screen.memory.widget:connect_signal("button::press", do_recolor)
  screen.battery.widget:connect_signal("button::press", do_recolor)
  screen.temp.widget:connect_signal("button::press", do_recolor)
  screen.volume.widget:connect_signal("button::press", do_recolor)

  screen.date_widget = w(wibox.widget.textclock) {
    format = '<span color="#eee">%a %b %d</span>',
    refresh = 1,
  }

  screen.time_widget = w(wibox.widget.textclock) {
    format = '<span color="#eee">%I:%M:%S %p</span>',
    refresh = 1,
  }


  screen.bar = awful.wibar {
    position = 'top',
    screen = screen,
  }

  local function spacer(width) return wibox.widget { forced_width = width or dpi(10) } end

  local widgets = utils.table_intersperse(spacer) {
    screen.network_down.widget,
    screen.network_up.widget,
    screen.cpu.widget,
    screen.memory.widget,
    screen.battery.widget,
    screen.temp.widget,
    screen.volume.widget,
    screen.date_widget,
    screen.time_widget,
    screen.layout_widget
  }

  screen.bar:setup(l(wibox.layout.align.horizontal) {
    -- left
    l(wibox.layout.fixed.horizontal) {
      -- screen.launcher_widget,
      -- spacer(6),
      screen.taglist_widget,
      spacer(6),
    },
    -- middle
    screen.tasklist_widget,
    -- right
    l(wibox.layout.fixed.horizontal) {
      spacer(dpi(4)),
      screen.tray_widget,
      spacer(dpi(10)),
      unpack(widgets),
    }
  })

  return screen.bar
end

return bar
