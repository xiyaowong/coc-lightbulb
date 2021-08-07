augroup CocLightbulb
  autocmd!
  autocmd CursorHold,CursorHoldI * lua require 'coc-lightbulb'.refresh()
augroup END
