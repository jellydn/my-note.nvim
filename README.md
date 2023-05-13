<h1 align="center">Welcome to my-note.nvim 👋</h1>
<p>
MyNote is a Neovim plugin that allows you to take notes in a floating window. It is a reimplementation of the flote.nvim plugin using the nui.popup module. The nui.popup module provides more flexibility and customization options for the floating window. The MyNote plugin allows you to store your notes in Markdown files in a cache directory, with separate files for each directory and a global file. You can customize the appearance of the floating window using various configuration options. To use the plugin, simply run the :MyNote command to open the floating window and start taking notes.
</p>

## Usage

```lua
return {
  {
    "jellydn/my-note.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    keys = {
      {
        "<leader>n",
        "<cmd>MyNote<cr>",
        desc = "Open note",
      },
    },
    opts = {
      files = {
        -- Using the parent .git folder as the current working directory
        cwd = function()
          local bufPath = vim.api.nvim_buf_get_name(0)
          local cwd = require("lspconfig").util.root_pattern(".git")(bufPath)

          return cwd
        end,
      },
    },
  },
}
```

## Note

This plugin is mainly for learning purposes and is not intended to be a full-featured note-taking solution.

## Show your support

Give a ⭐️ if this project helped you!
