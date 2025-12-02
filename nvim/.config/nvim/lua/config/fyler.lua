-- lua/config/fyler.lua
local ok, fyler = pcall(require, "fyler")
if not ok then
  return
end

fyler.setup({
  views = {
    finder = {
      win = {
        kinds = {
          float = {
            width = "80%",
            height = "78%",
            top = "7%",
            left = "10%",
          },
        },
      },
      mappings = {
        ["<leader>p"] = function(explorer)
          local node = explorer:cursor_node_entry()
          if not node or not node.path then
            return
          end

          local stat = vim.uv.fs_stat(node.path)
          if not stat or stat.type ~= "file" then
            return
          end

          if stat.size == 0 then
            vim.print("empty file.")
            return
          end

          local ok_read, lines = pcall(vim.fn.readfile, node.path)
          if not ok_read or not lines then
            vim.print("failed to read file: " .. node.path)
            return
          end

          local buf = vim.api.nvim_create_buf(false, true)
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

          local width = math.floor(vim.o.columns * 0.6)
          local height = math.floor(vim.o.lines * 0.7)

          local opts = {
            relative = "editor",
            width = width,
            height = height,
            row = math.floor((vim.o.lines - height) / 2),
            col = math.floor((vim.o.columns - width) / 2),
            style = "minimal",
            border = "rounded",
          }

          local preview_win = vim.api.nvim_open_win(buf, true, opts)

          local function close_preview()
            if vim.api.nvim_win_is_valid(preview_win) then
              vim.api.nvim_win_close(preview_win, true)
            end
          end

          vim.keymap.set("n", "q", close_preview, { buffer = buf, silent = true })
          vim.keymap.set("n", "<leader>p", close_preview, { buffer = buf, silent = true })
        end,
      },
    },
  },
})
