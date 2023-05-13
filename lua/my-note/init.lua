-- Define a module table
local M = {}

-- Set default configuration options
M.config = {
  q_to_quit = true, -- Whether to show "press 'q' to quit" at the bottom of the window
  -- Can be one of the pre-defined styles: "double", "none", "rounded", "shadow", "single" or "solid".
  window_border = "rounded", -- Style of the border around the window
  window_title = true, -- Whether to show the name of the note file at the top of the window
  notes_dir = vim.fn.stdpath("cache") .. "/my-note", -- Directory to store note files
  files = {
    global = "my-note-global.md", -- Name of the global note file
    cwd = function()
      return vim.fn.getcwd()
    end,
    file_name = function(cwd) -- Function to generate the name of the note file for the current directory
      local base_name = vim.fs.basename(cwd)
      local parent_base_name = vim.fs.basename(vim.fs.dirname(cwd))
      return parent_base_name .. "_" .. base_name .. ".md"
    end,
  },
}

-- Helper function to create the cache directory if it doesn't exist
local check_cache_dir = function(dir)
  local my_note_cache_dir = vim.fs.normalize(dir)

  if vim.fn.isdirectory(my_note_cache_dir) == 0 then
    os.execute("mkdir " .. my_note_cache_dir)
  end

  return my_note_cache_dir
end

-- Helper function to create the note file if it doesn't exist
local check_note_file = function(file)
  local note_file_path = vim.fs.normalize(M.my_note_cache_dir .. "/" .. file)
  if vim.tbl_isempty(vim.fs.find(file, { type = "file", path = M.my_note_cache_dir })) then
    os.execute("touch " .. note_file_path)
  end

  return note_file_path
end

-- Helper function to open the floating window
local open_float = function(file_path, file_name)
  -- Load required modules
  local Popup = require("nui.popup")
  local event = require("nui.utils.autocmd").event

  -- Calculate the width and height of the floating window
  local ui = vim.api.nvim_list_uis()[1]
  local width = math.floor((ui.width * 0.5) + 0.5)
  local height = math.floor((ui.height * 0.5) + 0.5)

  -- Create a new buffer for the note
  local note_buf = vim.api.nvim_create_buf(false, true)

  -- Set the options for the floating window
  local win_opts = {
    relative = "editor",
    position = "50%",
    size = {
      width = width,
      height = height,
    },
    enter = true,
    focusable = true,
    zindex = 50,
    border = {
      style = M.config.window_border,
      text = {
        top = " My Note ",
        top_align = "center",
        bottom = "",
        bottom_align = "left",
      },
    },
    win_options = {
      winblend = 10,
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
    },
    bufnr = note_buf,
  }

  -- Customize the window title and bottom text if specified in the configuration
  if M.config.window_title then
    win_opts.border.text.top = file_name
    if M.config.q_to_quit then
      win_opts.border.text.bottom = " - press 'q' to quit"
    end
  end

  -- Create the popup object
  local popup = Popup(win_opts)

  -- Mount the popup component
  popup:mount()

  -- Unmount the popup component when the cursor leaves the buffer
  popup:on(event.BufLeave, function()
    popup:unmount()
  end)

  -- Open the note file in the buffer
  vim.cmd("edit " .. file_path)

  -- Set the buffer options
  vim.api.nvim_buf_set_option(note_buf, "bufhidden", "wipe")
  if M.config.q_to_quit then
    vim.api.nvim_buf_set_keymap(note_buf, "n", "q", "<cmd>wq<CR>", { noremap = true, silent = false })
  end
end

-- Set up the plugin
M.setup = function(config)
  -- Merge the user-specified configuration with the default configuration
  M.config = vim.tbl_deep_extend("force", M.config, config or {})

  -- Create the cache directory and set the path to it
  M.my_note_cache_dir = check_cache_dir(M.config.notes_dir)

  -- Define the MyNote command
  vim.api.nvim_create_user_command("MyNote", function(opts)
    -- Determine whether to open the global note or the note for the current directory
    if opts.fargs[1] == "global" then
      local note_file_path = check_note_file(M.config.files.global)
      open_float(note_file_path, M.config.files.global)
    else
      local cwd = vim.fs.normalize(M.config.files.cwd())
      local file_name = M.config.files.file_name(cwd)
      local note_file_path = check_note_file(file_name)
      open_float(note_file_path, file_name)
    end
  end, {
    nargs = "?",
    complete = function()
      -- Only support global note or current directory note
      return { "global" }
    end,
  })
end

-- Return the module table
return M
