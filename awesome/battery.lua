local upower = require('lgi').require('UPowerGlib').Client()

local awful = require('awful')
local gtable = require('gears.table')
local naughty = require('naughty')
local wibox = require('wibox')

local battery = {}

function battery.list_devices()
  local ret = {}
  local devices = upower:get_devices()

  for _, d in ipairs(devices) do
    table.insert(ret, d:get_object_path())
  end

  return ret
end

function battery.get_device(path)
  local devices = upower:get_devices()

  for _, d in ipairs(devices) do
    if d:get_object_path() == path then
      return d
    end
  end

  return nil
end

function battery.new(args)
  args = gtable.crush(
    {
      create_callback = nil,
      device_path = '',
      use_display_device = false
    },
    args or {}
  )

  args.screen = screen[args.screen or 1]

  local widget = wibox.widget {
    align = 'center',
    valign = 'center',
    forced_width = 30,
    widget = wibox.widget.textbox
  }

  widget.tooltip = awful.tooltip { objects = { widget } }

  widget.device =
    args.use_display_device and upower:get_display_device() or battery.get_device(args.device_path)

  if type(args.create_callback) == 'function' then
    args.create_callback(widget, widget.device)
  end

  function widget:update()
    local remaining = string.format("%d%%", self.device.percentage)
    local icons = {
      {10,  '', ''},
      {20,  '', '<span size="xx-large"></span>'},
      {30,  '', '<span size="xx-large"></span>'},
      {40,  '', '<span size="xx-large"></span>'},
      {50,  '', '<span size="xx-large"></span>'},
      {60,  '', '<span size="xx-large"></span>'},
      {70,  '', '<span size="xx-large"></span>'},
      {80,  '', '<span size="xx-large"></span>'},
      {90,  '', '<span size="xx-large"></span>'},
      {98,  '', '<span size="xx-large"></span>'},
      {999, '', '<span size="xx-large"></span>'}
    }

    local icon_unknown = ''
    local icon_empty = ''
    local icon_full = ''

    --[[ if (self.device.percentage <= 15 and self.device.percentage % 5 == 0 and self.device.state == 2) then
      naughty.notification {
        title = "Battery " .. self.device.native_path .. ' low!',
        message = 'Remaining: ' .. remaining,
        urgency = "critical",
      }
    end ]]

    for i = 1, #icons do
      local percentage = icons[i][1]

      if (self.device.percentage <= percentage) then
        local icon_discharging = icons[i][2]
        local icon_charging = icons[i][3]

        local state = {
          [0] = icon_unknown,
          [1] = icon_charging,
          [2] = icon_discharging,
          [3] = icon_empty,
          [4] = icon_full,
        }
        self.markup = state[self.device.state] or state[2] or icon_unknown
        self.tooltip:set_text(self.device.native_path .. ': ' .. remaining)
        return
      end
    end
  end

  widget.device.on_notify = function(d)
    widget:update()
  end

  widget:update()

  return widget
end

return setmetatable(battery, {
  __call = function(self, ...)
    return battery.new(...)
  end
})
