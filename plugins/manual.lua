local commands = {
  c      = 'man 3 %s',
  cpp    = 'cppman %s',
}

local function manual(win)
  local range = win.file:text_object_word(win.selection.pos)
  local word = range and win.file:content(range)
  if not word or word == '' then
    return vis:info('No word under cursor')
  end

  local template = commands[win.syntax]
  if not template then
    return vis:info('No manual configured for: ' .. tostring(win.syntax))
  end

  local pipe = io.popen('MANPAGER=cat PAGER=cat ' .. template:format(word))
  local out = pipe:read('*a')
  pipe:close()

  if out == '' then
    return vis:info('No output for: ' .. word)
  end

  local tmp = os.tmpname()
  local f = io.open(tmp, 'w')
  f:write(out)
  f:close()

  vis:command('vsplit ' .. tmp)
  local manwin = vis.win

  local function close()
    manwin:close(true)
    os.remove(tmp)
    vis.win = win
  end

  manwin:map(vis.modes.NORMAL, 'q', close, 'close manual')
  manwin:map(vis.modes.NORMAL, '<Escape>', close, 'close manual')
end

vis:command_register('manual', function(_, _, win) manual(win) end)

return { open = manual }
