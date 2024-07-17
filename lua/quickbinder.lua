-- Copyright 2024 Merzekel

-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

local map, assert, type, pairs = vim.keymap.set, assert, type, pairs

local function bind(mode, keys, act, dsc, opts)
  local ops = opts
  ops.callback = true
  ops.desc = dsc
  local act_type = type(act)
  assert(((act_type == 'function') or (act_type == 'string')), 'keybind ' .. keys .. ' has an invalid action type')
  map(mode, keys, act, ops)
end

local function quickbind(tbl, keys)
  local keybind = keys or ''
  local t_mode = {'n', 'v'}
  local t_opts = { remap = true }

  if tbl.mode ~= nil then
    local m = tbl.mode
    local m_t = type(m)
    if m_t == 'table' then
      t_mode = m
    elseif m_t == 'string' then
      if #m > 1 then
        t_mode = {}
        for i = 1, #m do
          t_mode[i] = m:sub(i,i)
        end
      else
        t_mode = {m}
      end
    end
    tbl.mode = nil
  end

  if tbl.opts ~= nil then
    local o = tbl.opts
    assert(type(o), "opts must be a table\nopts type: " .. type(o))
    t_opts = o
    tbl.opts = nil
  end

  for key, val in pairs(tbl) do
    assert(type(key) == 'string', 'key must be a string\n' .. vim.inspect(tbl))
    assert(type(val) == 'table', 'value must be a table\nkey: ' .. key .. '\nval\'s type: ' .. type(val))
    local mode = val.mode or t_mode
    if (val.act ~= nil) then
      local v1_t = type(val[1])
      local v2_t = type(val[2])
      local desc = nil
      local opts = t_opts

      if (v1_t == 'table') then
        opts = val[1]
      elseif (v2_t == 'table') then
        opts = val[2]
      elseif (type(val.opts) == 'table') then
        opts = val.opts
      end

      if (v1_t == 'string') then
        desc = val[1]
      elseif (v2_t == 'string') then
        desc = val[2]
      elseif (type(val.desc) == 'string') then
        desc = val.desc
      end

      bind(mode, keybind .. key, val.act, desc, opts)
    else
      quickbind(val, keybind .. key)
    end
  end
end

-- Quick wrapper for command strings
local function run(str)
  return function()
    vim.cmd(str)
  end
end

return {
  bind = bind,
  quickbind = quickbind,
  qb = quickbind,
  run = run
}
