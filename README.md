<h1 align="center">Welcome to my-note.nvim 👋</h1>
<p>
MyNote is a Neovim plugin that allows you to take notes in a floating window. It is a reimplementation of the flote.nvim plugin using the nui.popup module. The nui.popup module provides more flexibility and customization options for the floating window. The MyNote plugin allows you to store your notes in Markdown files in a cache directory, with separate files for each directory and a global file. You can customize the appearance of the floating window using various configuration options. To use the plugin, simply run the :MyNote command to open the floating window and start taking notes.
</p>

![https://gyazo.com/c0d7d05f9280f78d6063703e285f7952.gif](https://gyazo.com/c0d7d05f9280f78d6063703e285f7952.gif)

## Usage

Install MyNote.nvim with [lazy.nvim](https://github.com/folke/lazy.nvim)

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

## Acknowledgements

MyNote is a reimplementation of the flote.nvim plugin by JellyApple102, which provides easy, minimal, per-project, and global markdown notes.

MyNote uses the nui.popup module by MunifTanjim, which is a UI component library for Neovim. We thank MunifTanjim for creating and maintaining this useful module.

Links to the original plugins:

- https://github.com/JellyApple102/flote.nvim Easy, minimal, per-project and global markdown notes.
- https://github.com/MunifTanjim/nui.nvim UI Component Library for Neovim.

## Show your support

Give a ⭐️ if this project helped you!
