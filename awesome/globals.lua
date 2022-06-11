local utils = require('utils')

local globals = {}

globals.terminal        = 'alacritty'
globals.editor          = 'code-insiders' or os.getenv('EDITOR') or 'nano'
globals.editor_cmd      = globals.terminal .. ' -e ' .. globals.editor
globals.modkey          = 'Mod4'
globals.pulseaudio      = require('pulseaudio')
globals.tags            = utils.table_pad_end({}, 9, function(i) return i end)
globals.screenshot_tool = 'flameshot gui'

globals.rofi = {
  code      = 'rofi-code --code code-insiders -d ~/.config/Code\\ -\\ Insiders/',
  clipboard = 'rofi -modi "clipboard:greenclip print" -show clipboard -run-command "{cmd}"',
  emoji     = 'rofimoji -r Emoji',
  powermenu = 'rofi -show menu -modi "menu:rofi-power-menu"',
  calc      = 'rofi -show calc -modi calc -no-show-match -no-sort',
}

return globals
