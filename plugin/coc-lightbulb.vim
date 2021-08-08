augroup CocLightbulb
  autocmd!
  autocmd CursorHold,CursorHoldI * lua require 'coc-lightbulb'.refresh()
  autocmd WinEnter * lua require 'coc-lightbulb'._do_action()
augroup END
