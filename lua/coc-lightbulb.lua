local M = {}

local fn = vim.fn
local api = vim.api

local SIGN_GROUP = 'CocCodeAction'
local SIGN_NAME = 'LightBulbSign'
local LIGHTBULB_VIRTUAL_TEXT_HL = 'LightBulbVirtualText'
local LIGHTBULB_VIRTUAL_TEXT_NS = api.nvim_create_namespace 'coc-lightbulb'

if vim.tbl_isempty(fn.sign_getdefined(SIGN_NAME)) then
  fn.sign_define(SIGN_NAME, { text = '💡', texthl = 'LspDiagnosticsDefaultInformation' })
end

local opts = {
  enable = true,
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
}

function M.setup(user_opts)
  user_opts = user_opts or {}
  if user_opts.enable ~= nil then
    opts.enable = user_opts.enable
  end
  for option, value in pairs(user_opts.sign or {}) do
    opts.sign[option] = value
  end
  for option, value in pairs(user_opts.virtual_text or {}) do
    opts.virtual_text[option] = value
  end
  for option, value in pairs(user_opts.status_text or {}) do
    opts.status_text[option] = value
  end
end

---@class Ctx
---@field show boolean: has available actions
---@field lnum number: current line number
---@field bufnr number: current buffer

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
      and vim.bo.buflisted
      and fn.exists '*CocHasProvider' == 1
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
  }

  update_sign(ctx)
  update_virtual_text(ctx)
  update_status_text(ctx)
end

return M
