local M = {}

M.config = {
  q_to_quit = true,
  -- Can be one of the pre-defined styles: "double", "none", "rounded", "shadow", "single" or "solid".
  window_border = "rounded",
  window_title = true,
  notes_dir = vim.fn.stdpath("cache") .. "/my-note",
  files = {
    global = "my-note-global.md",
    cwd = function()
      return vim.fn.getcwd()
    end,
    file_name = function(cwd)
      local base_name = vim.fs.basename(cwd)
      local parent_base_name = vim.fs.basename(vim.fs.dirname(cwd))
      return parent_base_name .. "_" .. base_name .. ".md"
    end,
  },
}

local check_cache_dir = function(dir)
  local my_note_cache_dir = vim.fs.normalize(dir)

  if vim.fn.isdirectory(my_note_cache_dir) == 0 then
    os.execute("mkdir " .. my_note_cache_dir)
  end

  return my_note_cache_dir
end

local check_note_file = function(file)
  local note_file_path = vim.fs.normalize(M.my_note_cache_dir .. "/" .. file)
  if vim.tbl_isempty(vim.fs.find(file, { type = "file", path = M.my_note_cache_dir })) then
    os.execute("touch " .. note_file_path)
  end

  return note_file_path
end

local open_float = function(file_path, file_name)
  local Popup = require("nui.popup")
  local event = require("nui.utils.autocmd").event

  local ui = vim.api.nvim_list_uis()[1]
  local width = math.floor((ui.width * 0.5) + 0.5)
  local height = math.floor((ui.height * 0.5) + 0.5)

  local note_buf = vim.api.nvim_create_buf(false, true)

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

  if M.config.window_title then
    win_opts.border.text.top = file_name
    if M.config.q_to_quit then
      win_opts.border.text.bottom = " - press 'q' to quit"
    end
  end

  local popup = Popup(win_opts)

  -- mount/open the component
  popup:mount()

  -- unmount component when cursor leaves buffer
  popup:on(event.BufLeave, function()
    popup:unmount()
  end)

  vim.cmd("edit " .. file_path)
  vim.api.nvim_buf_set_option(note_buf, "bufhidden", "wipe")
  if M.config.q_to_quit then
    vim.api.nvim_buf_set_keymap(note_buf, "n", "q", "<cmd>wq<CR>", { noremap = true, silent = false })
  end
end

M.setup = function(config)
  M.config = vim.tbl_deep_extend("force", M.config, config or {})

  M.my_note_cache_dir = check_cache_dir(M.config.notes_dir)

  vim.api.nvim_create_user_command("MyNote", function(opts)
    if opts.fargs[1] == "global" then
      local note_file_path = check_note_file(M.config.files.global)
      open_float(note_file_path, M.config.files.global)
    elseif opts.fargs[1] == "manage" then
      open_float(M.my_note_cache_dir)
    else
      local cwd = vim.fs.normalize(M.config.files.cwd())
      local file_name = M.config.files.file_name(cwd)
      local note_file_path = check_note_file(file_name)
      open_float(note_file_path, file_name)
    end
  end, {
    nargs = "?",
    complete = function()
      return { "global", "manage" }
    end,
  })
end

return M
