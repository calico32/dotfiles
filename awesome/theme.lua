local theme_assets = require('beautiful.theme_assets')
local xresources = require('beautiful.xresources')

local gfs = require('gears.filesystem')
local themes_path = gfs.get_themes_dir()

local dpi = xresources.apply_dpi
local taglist_square_size = dpi(6)

local theme = {}

theme.wallpaper  = os.getenv('XDG_DATA_HOME') .. '/wallpapers/current'
theme.icon_theme = 'Paper-Mono-Dark'

theme.font              = 'Terminus, 9'
theme.notification_font = 'Source Sans Pro, 12'

theme.bg_normal   = '#00000000'
theme.bg_focus    = '#ffffff40'
theme.bg_urgent   = '#cc2500'
theme.bg_minimize = theme.bg_normal
theme.bg_systray  = '#172434'
theme.fg_normal   = '#aaaaaa'
theme.fg_focus    = '#ffffff'
theme.fg_urgent   = '#ffffff'
theme.fg_minimize = '#666666'

theme.useless_gap          = dpi(0) -- 3
theme.border_width         = dpi(2)
theme.border_radius        = dpi(0)
theme.client_border_radius = dpi(0)

theme.border_normal = '#2f2f2f'
theme.border_focus  = '#505050'
theme.border_marked = '#cc2500'

theme.systray_icon_spacing = dpi(2)

theme.taglist_squares_sel   = theme_assets.taglist_squares_sel(taglist_square_size, theme.fg_normal)
theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(taglist_square_size, theme.fg_normal)

theme.notification_max_height = 150
theme.notification_icon_size  = 100

theme.menu_submenu_icon = themes_path .. 'default/submenu.png'
theme.menu_border_width = dpi(1)
theme.menu_height       = dpi(15)
theme.menu_width        = dpi(200)


theme.layout_fairh      = themes_path .. 'default/layouts/fairhw.png'
theme.layout_fairv      = themes_path .. 'default/layouts/fairvw.png'
theme.layout_floating   = themes_path .. 'default/layouts/floatingw.png'
theme.layout_magnifier  = themes_path .. 'default/layouts/magnifierw.png'
theme.layout_max        = themes_path .. 'default/layouts/maxw.png'
theme.layout_fullscreen = themes_path .. 'default/layouts/fullscreenw.png'
theme.layout_tilebottom = themes_path .. 'default/layouts/tilebottomw.png'
theme.layout_tileleft   = themes_path .. 'default/layouts/tileleftw.png'
theme.layout_tile       = themes_path .. 'default/layouts/tilew.png'
theme.layout_tiletop    = themes_path .. 'default/layouts/tiletopw.png'
theme.layout_spiral     = themes_path .. 'default/layouts/spiralw.png'
theme.layout_dwindle    = themes_path .. 'default/layouts/dwindlew.png'
theme.layout_cornernw   = themes_path .. 'default/layouts/cornernww.png'
theme.layout_cornerne   = themes_path .. 'default/layouts/cornernew.png'
theme.layout_cornersw   = themes_path .. 'default/layouts/cornersww.png'
theme.layout_cornerse   = themes_path .. 'default/layouts/cornersew.png'

theme.awesome_icon = theme_assets.awesome_icon(theme.menu_height * 8, theme.bg_focus, theme.fg_focus)

local function span(text) return '<span foreground="#EEE" font-family="MesloLGS NF" size="large">' .. text .. '</span>' end

theme.tasklist_sticky               = span ' '
theme.tasklist_ontop                = span '﯁ '
theme.tasklist_above                = span ' '
theme.tasklist_below                = span ' '
theme.tasklist_floating             = span '禎 '
theme.tasklist_maximized            = span ' '
theme.tasklist_maximized_horizontal = span '易 '
theme.tasklist_maximized_vertical   = span '祈 '
theme.tasklist_minimized            = span '- '

return theme
