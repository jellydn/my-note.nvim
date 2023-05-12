<h1 align="center">Welcome to my-note.nvim 👋</h1>
<p>
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

## Show your support

Give a ⭐️ if this project helped you!

