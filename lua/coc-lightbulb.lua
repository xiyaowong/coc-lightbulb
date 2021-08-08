local M = {}

local fn = vim.fn
local api = vim.api
local npcall = vim.F.npcall

local SIGN_GROUP = 'CocCodeAction'
local SIGN_NAME = 'LightBulbSign'
local LIGHTBULB_VIRTUAL_TEXT_HL = 'LightBulbVirtualText'
local LIGHTBULB_VIRTUAL_TEXT_NS = api.nvim_create_namespace 'coc-lightbulb'
local LIGHTBULB_FLOAT_HL = 'LightBulbFloatWin'

if vim.tbl_isempty(fn.sign_getdefined(SIGN_NAME)) then
  fn.sign_define(SIGN_NAME, { text = '💡', texthl = 'LspDiagnosticsDefaultInformation' })
end

local opts = {
  enable = true,
  disabled_filetyps = {},
  sign = {
    enabled = true,
    priority = 10,
  },
  virtual_text = {
    enabled = false,
    text = '💡',
  },
  status_text = {
    enabled = false,
    text = '💡',
  },
  float = {
    enabled = false,
    text = '💡',
  },
}

function M.setup(user_opts)
  user_opts = user_opts or {}
  for _, option in ipairs(user_opts) do
    if vim.tbl_contains({ 'sign', 'virtual_text', 'status_text', 'float' }, option) then
      opts[option] = vim.tbl_extend('force', opts[option], user_opts[option])
    else
      opts[option] = user_opts[option]
    end
  end
end

---@class Ctx
---@field show boolean: has available actions
---@field lnum number: current line number
---@field bufnr number: current buffer
---@field winnr number: current window

---Update sign
---@param ctx Ctx
local function update_sign(ctx)
  if not opts.sign.enabled then
    return
  end
  fn.sign_unplace(SIGN_GROUP, { buffer = ctx.bufnr })
  if ctx.show then
    fn.sign_place(
      ctx.lnum,
      SIGN_GROUP,
      SIGN_NAME,
      ctx.bufnr,
      { lnum = ctx.lnum, priority = opts.sign.priority }
    )
  end
end

---@param ctx Ctx
local function update_virtual_text(ctx)
  if not opts.virtual_text.enabled then
    return
  end
  api.nvim_buf_clear_namespace(ctx.bufnr, LIGHTBULB_VIRTUAL_TEXT_NS, 0, -1)
  if ctx.show then
    api.nvim_buf_set_virtual_text(
      ctx.bufnr,
      LIGHTBULB_VIRTUAL_TEXT_NS,
      ctx.lnum - 1,
      { { opts.virtual_text.text, LIGHTBULB_VIRTUAL_TEXT_HL } },
      {}
    )
  end
end

---@param ctx Ctx
local function update_float(ctx)
  if not opts.float.enabled then
    return
  end

  -- close existed float
  local existing_float = npcall(api.nvim_buf_get_var, ctx.bufnr, 'coc_lightbulb_float')
  if existing_float and api.nvim_win_is_valid(existing_float) then
    api.nvim_win_close(existing_float, true)
  end

  if not ctx.show then
    return
  end

  local f_bufnr = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(f_bufnr, 0, -1, true, { opts.float.text })
  vim.bo[f_bufnr].modifiable = false
  vim.bo[f_bufnr].bufhidden = 'wipe'
  vim.bo[f_bufnr].filetype = 'coc_lightbulb'

  -- TODO: find the best position to show
  local f_row = 0
  local f_col = fn.col '$' - fn.col '.' + 3

  local f_winnr = api.nvim_open_win(f_bufnr, false, {
    width = #opts.float.text,
    height = 1,
    relative = 'cursor',
    row = f_row,
    col = f_col,
    style = 'minimal',
  })
  vim.wo[f_winnr].winhighlight = 'Normal:' .. LIGHTBULB_FLOAT_HL
  vim.wo[f_winnr].winblend = 100

  -- automatically close float window
  vim.cmd(
    'autocmd CursorMoved,CursorMovedI,BufHidden,InsertCharPre <buffer> ++once lua pcall(vim.api.nvim_win_close, '
      .. f_winnr
      .. ', true)'
  )
  api.nvim_buf_set_var(ctx.bufnr, 'coc_lightbulb_float', f_winnr)
  -- for calling code action on click
  api.nvim_buf_set_var(f_bufnr, 'coc_lightbulb_action_winnr', ctx.winnr)
end

function M._do_action()
  if vim.bo.filetype ~= 'coc_lightbulb' then
    return
  end
  -- FIXME: If I execute immediately, the cursor can't goto position as expected.
  -- I set a delay and it works fine, but I don't know why
  vim.defer_fn(function()
    api.nvim_set_current_win(vim.b.coc_lightbulb_action_winnr)
    fn.CocAction('codeAction', 'cursor')
  end, 10)
end

---@param ctx Ctx
local function update_status_text(ctx)
  if not opts.status_text.enabled then
    return
  end
  vim.b.lightbulb_status_text = ctx.show and opts.status_text.text or ''
end

function M.get_status()
  return vim.b.lightbulb_status_text or ''
end

function M.refresh()
  if
    not (
      opts.enable
      and vim.g.coc_service_initialized == 1
      and vim.bo.buflisted
      and not vim.tbl_contains(opts.disabled_filetyps, vim.bo.filetype)
      and fn.CocHasProvider 'codeAction'
    )
  then
    return
  end

  local actions = fn.CocAction('codeActions', 'cursor')
  local ctx = {
    show = type(actions) == 'table' and #actions > 0,
    lnum = fn.line '.',
    bufnr = api.nvim_get_current_buf(),
    winnr = api.nvim_get_current_win(),
  }

  update_sign(ctx)
  update_virtual_text(ctx)
  update_status_text(ctx)
  update_float(ctx)
end

return M
