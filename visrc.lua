require('vis')

local plug = (function()
  if not pcall(require, 'plugins/vis-plug') then
    os.execute('git clone --quiet https://github.com/erf/vis-plug ' ..
      (os.getenv('XDG_CONFIG_HOME') or os.getenv('HOME') .. '/.config')
      .. '/vis/plugins/vis-plug')
  end
  return require('plugins/vis-plug')
end)()

local plugins = {
  { 'https://codeberg.org/luxanna/vis-autoclose' },
  { 'https://codeberg.org/muhq/vis-lspc', alias = 'lspc' },
  { 'erf/vis-cursors' },
}

plug.init(plugins, true)

local lspc = require('plugins/vis-lspc')

lspc.highlight_diagnostics = false

vis:map(vis.modes.INSERT, '<C-v>', '<Escape>"+pa')

local function do_yank()
  vis:command('>vis-clipboard --copy')
  vis:feedkeys('<vis-operator-yank>')
end

vis:map(vis.modes.VISUAL, 'y', do_yank)
vis:map(vis.modes.VISUAL_LINE, 'y', do_yank)

local manual = require('plugins/manual')

vis:map(vis.modes.NORMAL, 'K', function()
  manual.open(vis.win)
end, 'Open manual for word under cursor')

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
  vis:command('set nu')
  vis:command('set rnu')
  vis:command('set ai')
  vis:command('set et')
  vis:command('set tw 4')
end)
