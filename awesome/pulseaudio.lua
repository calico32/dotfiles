local awful = require("awful")

local wibox = require("wibox")
local naughty = require("naughty")

local utils = require("utils")

local widget = wibox.widget {
  align = 'center',
  valign = 'center',
  forced_width = 30,
  widget = wibox.widget.textbox,
}

widget.tooltip = awful.tooltip({ objects = { widget } })

--- @param notify? boolean
function widget:update(notify)
  if notify == nil then notify = true end

  awful.spawn.easy_async("pamixer --get-volume-human", function(stdout, stderr, reason, exit_code)
    local icons = {
      {33, '奄'},
      {66, '<span size="x-large">奔</span>'},
      {999, '<span size="x-large">墳</span>'},
    }

    local icon_muted = '<span size="x-large">婢</span>'

    local find_muted = string.find(stdout, 'muted')
    if find_muted ~= nil then
      self.markup = icon_muted
      self.tooltip:set_text(stdout)
      self:notify(stdout)
      return
    end

    local parsed = string.gsub(stdout, "%%", "")
    local current = tonumber(parsed)

    for i = 1, #icons do
      local percentage = icons[i][1]
      local icon = icons[i][2]

      if (current <= percentage) then
        self.markup = icon
        self.tooltip:set_text(string.format("%d%%", current))
        break
      end
    end

    if notify then widget:notify(stdout) end
  end)
end

function widget:notify(v)
  if self.notification then
    naughty.destroy(self.notification, naughty.notificationClosedReason.dismissedByCommand)
  end

  self.notification = naughty.notify {
    text = utils.string_trim(v),
    timeout = self.notification_timeout_seconds
  }
end

function widget:is_muted(callback)
  awful.spawn.easy_async("pamixer --get-mute", function(stdout, stderr, reason, exit_code)
  local muted = string.find(stdout, 'true')
    if muted == nil then
      callback(false)
    else
      callback(true)
    end
  end)
end

function widget:volume_up()
  widget:is_muted(function(muted)
    if not muted then
      awful.spawn.easy_async("pamixer --allow-boost -i 5", function() widget:update() end)
    else
      widget:update()
    end
  end)
end

function widget:volume_down()
  widget:is_muted(function(muted)
    if not muted then
      awful.spawn.easy_async("pamixer --allow-boost -d 5", function() widget:update() end)
    else
      widget:update()
    end
  end)
end

function widget:toggle_muted()
  awful.spawn.easy_async("pamixer -t", function() widget:update() end)
end

function widget:show_mixer()
  awful.spawn("pavucontrol")
end

function widget:init()
  self:buttons {
    awful.button({}, 1, function() self:toggle_muted() end),
    awful.button({}, 3, function() self:show_mixer() end),
    awful.button({}, 4, function() self:volume_up() end),
    awful.button({}, 5, function() self:volume_down() end),
  }

  widget:update(false)

  return self
end

return widget:init()
