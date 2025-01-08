-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

lvim.plugins = {
  { "lunarvim/colorschemes" },
  {
    "nvim-pack/nvim-spectre",
    event = "BufRead",
    config = function()
      require("spectre").setup()
    end,
  },
  {
    "echasnovski/mini.nvim",
    version = '*',
    config = function()
      require("mini.trailspace").setup()
    end
  },
}

lvim.format_on_save.enabled = true
lvim.colorscheme = "tomorrow"
lvim.builtin.lualine.options.theme = "gruvbox"
