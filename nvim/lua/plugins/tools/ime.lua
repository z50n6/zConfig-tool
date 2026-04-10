-- 作用: 进入 Neovim/Neovide 时默认英文输入法（Windows）
-- 依赖: 系统 PATH 中可找到 im-select.exe
return {
  {
    "keaising/im-select.nvim",
    -- 需要在进入 UI / 恢复焦点时就生效
    event = { "VimEnter", "FocusGained" },
    opts = {
      default_command = "im-select.exe",
      -- 英文(US) 键盘：1033；常见中文输入法（如微软拼音）通常是 2052
      default_im_select = "1033",
      set_default_events = { "VimEnter", "FocusGained", "InsertLeave", "CmdlineLeave" },
      set_previous_events = { "InsertEnter", "CmdlineEnter" },
      async_switch_im = true,
      keep_quiet_on_no_binary = true,
    },
  },
}

