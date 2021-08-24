local utils = require('utils')

local globals = {}

globals.terminal = 'alacritty'
globals.editor = 'code-git' or os.getenv('EDITOR') or 'nano'
globals.editor_cmd = globals.terminal .. ' -e ' .. globals.editor
globals.modkey = 'Mod4'
globals.pulseaudio = require("pulseaudio")
globals.tags = utils.table_pad_end({}, 9, function(i) return i end)
globals.exit_script = os.getenv('HOME') .. '/.local/bin/exit-awesome'
globals.screenshot_tool = 'flameshot gui'

return globals
