local h = require("tests.helpers")

local new_set = MiniTest.new_set
local child = MiniTest.new_child_neovim()

local T = new_set({
  hooks = {
    pre_case = function()
      h.child_start(child)
      child.lua([[
        _G.echoes = 0
        vim.api.nvim_echo = function()
          _G.echoes = _G.echoes + 1
        end
        _G.spinner = require("inliber.utils.spinner").new({ message = "get_editor_state" })
      ]])
    end,
    post_once = child.stop,
  },
})

T["Spinner"] = new_set()

T["Spinner"]["DOES NOT draw while AT a hit-enter prompt"] = function()
  local echoes = child.lua([[
    vim.api.nvim_get_mode = function()
      return { mode = "r", blocking = true }
    end
    _G.spinner:_render()
    return _G.echoes
  ]])

  h.eq(0, echoes)
end

T["Spinner"]["draws while NOT at a prompt"] = function()
  local echoes = child.lua([[
    _G.spinner:_render()
    return _G.echoes
  ]])

  h.eq(1, echoes)
end

return T
