local wezterm = require("wezterm")
local session_manager = {}
local os = wezterm.target_triple

local CFG_DIR = (wezterm.config_file:gsub('[^/\\]+$', ''):gsub('\\', '/'))
local STATE_DIR = CFG_DIR .. 'lua/wezterm-session-manager/'

local function parse_unc_wsl(p)
  local d, rest = p:match("^//wsl%.localhost/([^/]+)/(.+)$")
  if d and rest then return d, "/" .. rest end
  return nil, nil
end

local function ensure_dir(dir)
  local distro, wsl_path = parse_unc_wsl(dir)
  if distro and wsl_path then
    wezterm.run_child_process({"wsl","-d", distro, "bash","-lc", "mkdir -p '"..wsl_path.."'"})
    return
  end
  if os_triple == "x86_64-pc-windows-msvc" then
    wezterm.run_child_process({"cmd","/c","mkdir", dir:gsub('/','\\')})
  else
    wezterm.run_child_process({"bash","-lc","mkdir -p '"..dir.."'"})
  end
end

local function write_via_wsl(file_path, content)
  local distro, wsl_path = parse_unc_wsl(file_path)
  if not (distro and wsl_path) then return false, "not_unc" end
  local dir = wsl_path:gsub("/[^/]+$", "")
  local cmd = "mkdir -p '"..dir.."' && cat > '"..wsl_path.."' << 'EOF'\n" .. content .. "\nEOF"
  local ok, _, status = wezterm.run_child_process({"wsl","-d", distro, "bash","-lc", cmd})
  return status == 0, status
end

local function read_via_wsl(file_path)
  local distro, wsl_path = parse_unc_wsl(file_path)
  if not (distro and wsl_path) then return nil, "not_unc" end
  local ok, out, status = wezterm.run_child_process({"wsl","-d", distro, "bash","-lc", "cat '"..wsl_path.."'"})
  if status == 0 then return out end
  return nil, status
end

--- Displays a notification in WezTerm.
-- @param message string: The notification message to be displayed.
local function display_notification(message)
  wezterm.log_info(message)
  -- Additional code to display a GUI notification can be added here if needed
end

--- Retrieves the current workspace data from the active window.
-- @return table or nil: The workspace data table or nil if no active window is found.
local function retrieve_workspace_data(window)
  local workspace_name = window:active_workspace()
  local workspace_data = {
    name = workspace_name,
    tabs = {}
  }

  -- Iterate over tabs in the current window
  for _, tab in ipairs(window:mux_window():tabs()) do
    local tab_data = {
      tab_id = tostring(tab:tab_id()),
      panes = {}
    }

    -- Iterate over panes in the current tab
    for _, pane_info in ipairs(tab:panes_with_info()) do
      -- Collect pane details, including layout and process information
      table.insert(tab_data.panes, {
        pane_id = tostring(pane_info.pane:pane_id()),
        index = pane_info.index,
        is_active = pane_info.is_active,
        is_zoomed = pane_info.is_zoomed,
        left = pane_info.left,
        top = pane_info.top,
        width = pane_info.width,
        height = pane_info.height,
        pixel_width = pane_info.pixel_width,
        pixel_height = pane_info.pixel_height,
        cwd = tostring(pane_info.pane:get_current_working_dir()),
        tty = tostring(pane_info.pane:get_foreground_process_name())
      })
    end

    table.insert(workspace_data.tabs, tab_data)
  end

  return workspace_data
end

--- Saves data to a JSON file.
-- @param data table: The workspace data to be saved.
-- @param file_path string: The file path where the JSON file will be saved.
-- @return boolean: true if saving was successful, false otherwise.
local function normalize_for_windows_io(path)
  if wezterm.target_triple ~= "x86_64-pc-windows-msvc" then
    return path
  end
  -- //wsl.localhost/... -> \\wsl.localhost\...
  if path:match("^//wsl%.localhost/") then
    path = path:gsub("^//", "\\\\") :gsub("/", "\\")
  end
  return path
end

local function save_to_json_file(data, file_path)
  if not data then
    wezterm.log_error("save_to_json_file: no data"); return false
  end
  local json = wezterm.json_encode(data)

  -- UNC -> WSL直書き
  local ok, why = write_via_wsl(file_path, json)
  if ok then return true end
  if why ~= "not_unc" then
    wezterm.log_error("WSL write failed: " .. tostring(why) .. " @ " .. file_path)
  end

  -- 通常パス（Windows/Mac/Linux）
  local p = file_path
  if os_triple == "x86_64-pc-windows-msvc" and p:match("^//wsl%.localhost/") then
    p = p:gsub("^//","\\\\"):gsub("/","\\") -- 念のため
  end
  local f, err = io.open(p, "w")
  if not f then
    wezterm.log_error("io.open failed: " .. tostring(err) .. " @ " .. file_path)
    return false
  end
  f:write(json); f:close()
  return true
end

--- Recreates the workspace based on the provided data.
-- @param workspace_data table: The data structure containing the saved workspace state.
local function recreate_workspace(window, workspace_data)
  local function extract_path_from_dir(working_directory)
    if os == "x86_64-pc-windows-msvc" then
      -- On Windows, transform 'file:///C:/path/to/dir' to 'C:/path/to/dir'
      return working_directory:gsub("file:///", "")
    elseif os == "x86_64-unknown-linux-gnu" then
      -- On Linux, transform 'file://{computer-name}/home/{user}/path/to/dir' to '/home/{user}/path/to/dir'
      return working_directory:gsub("^.*(/home/)", "/home/")
    else
      return working_directory:gsub("^.*(/Users/)", "/Users/")
    end
  end

  if not workspace_data or not workspace_data.tabs then
    wezterm.log_info("Invalid or empty workspace data provided.")
    return
  end

  local tabs = window:mux_window():tabs()

  if #tabs ~= 1 or #tabs[1]:panes() ~= 1 then
    wezterm.log_info(
      "Restoration can only be performed in a window with a single tab and a single pane, to prevent accidental data loss.")
    return
  end

  local initial_pane = window:active_pane()
  local foreground_process = initial_pane:get_foreground_process_name()

  -- Check if the foreground process is a shell
  if foreground_process:find("sh") or foreground_process:find("cmd.exe") or foreground_process:find("powershell.exe") or foreground_process:find("pwsh.exe") or foreground_process:find("nu") then
    -- Safe to close
    initial_pane:send_text("exit\r")
  else
    wezterm.log_info("Active program detected. Skipping exit command for initial pane.")
  end

  -- Recreate tabs and panes from the saved state
  for _, tab_data in ipairs(workspace_data.tabs) do
    local cwd_uri = tab_data.panes[1].cwd
    local cwd_path = extract_path_from_dir(cwd_uri)

    local new_tab = window:mux_window():spawn_tab({ cwd = cwd_path })
    if not new_tab then
      wezterm.log_info("Failed to create a new tab.")
      break
    end

    -- Activate the new tab before creating panes
    new_tab:activate()

    -- Recreate panes within this tab
    for j, pane_data in ipairs(tab_data.panes) do
      local new_pane
      if j == 1 then
        new_pane = new_tab:active_pane()
      else
        local direction = 'Right'
        if pane_data.left == tab_data.panes[j - 1].left then
          direction = 'Bottom'
        end

        new_pane = new_tab:active_pane():split({
          direction = direction,
          cwd = extract_path_from_dir(pane_data.cwd)
        })
      end

      if not new_pane then
        wezterm.log_info("Failed to create a new pane.")
        break
      end

      -- Restore TTY for Neovim on Linux
      -- NOTE: cwd is handled differently on windows. maybe extend functionality for windows later
      -- This could probably be handled better in general
      if not (os == "x86_64-pc-windows-msvc") then
        if not (os == "x86_64-pc-windows-msvc") and pane_data.tty:sub(- #"/bin/nvim") == "/bin/nvim" then
          new_pane:send_text(pane_data.tty .. " ." .. "\n")
        else
          -- TODO - With running npm commands (e.g a running web client) this seems to execute Node, without the arguments
          new_pane:send_text(pane_data.tty .. "\n")
        end
      end
    end
  end

  wezterm.log_info("Workspace recreated with new tabs and panes based on saved state.")
  return true
end

--- Loads data from a JSON file.
-- @param file_path string: The file path from which the JSON data will be loaded.
-- @return table or nil: The loaded data as a Lua table, or nil if loading failed.
local function load_from_json_file(file_path)
  local via, why = read_via_wsl(file_path)
  if via then
    local data = wezterm.json_parse(via)
    if not data then
      wezterm.log_info("Failed to parse JSON (WSL): " .. file_path)
    end
    return data
  end
  if why ~= "not_unc" then
    wezterm.log_info("WSL read failed: " .. tostring(why) .. " @ " .. file_path)
  end

  local p = file_path
  if os_triple == "x86_64-pc-windows-msvc" and p:match("^//wsl%.localhost/") then
    p = p:gsub("^//","\\\\"):gsub("/","\\")
  end
  local file, err = io.open(p, "r")
  if not file then
    wezterm.log_info("Failed to open file: " .. file_path .. " (" .. tostring(err) .. ")")
    return nil
  end
  local text = file:read("*a"); file:close()
  local data = wezterm.json_parse(text)
  if not data then
    wezterm.log_info("Failed to parse JSON: " .. file_path)
  end
  return data
end

--- Loads the saved json file matching the current workspace.
function session_manager.restore_state(window)
  local workspace_name = window:active_workspace()
  ensure_dir(STATE_DIR)
  local file_path = STATE_DIR .. "wezterm_state_" .. workspace_name .. ".json"

  local workspace_data = load_from_json_file(file_path)
  if not workspace_data then
    window:toast_notification('WezTerm',
      'Workspace state file not found for workspace: ' .. workspace_name, nil, 4000)
    return
  end

  if recreate_workspace(window, workspace_data) then
    window:toast_notification('WezTerm', 'Workspace state loaded for workspace: ' .. workspace_name, nil, 4000)
  else
    window:toast_notification('WezTerm', 'Workspace state loading failed for workspace: ' .. workspace_name, nil, 4000)
  end
end

--- Allows to select which workspace to load
function session_manager.load_state(window)
  -- TODO: Implement
  -- Placeholder for user selection logic
  -- ...
  -- TODO: Call the function recreate_workspace(workspace_data) to recreate the workspace
  -- Placeholder for recreation logic...
end

--- Orchestrator function to save the current workspace state.
-- Collects workspace data, saves it to a JSON file, and displays a notification.
function session_manager.save_state(window)
  local data = retrieve_workspace_data(window)
  ensure_dir(STATE_DIR)
  local file_path = STATE_DIR .. "wezterm_state_" .. data.name .. ".json"
  wezterm.log_info("save -> " .. file_path)
  if save_to_json_file(data, file_path) then
    window:toast_notification('WezTerm Session Manager','Workspace state saved successfully',nil,4000)
  else
    window:toast_notification('WezTerm Session Manager','Failed to save workspace state',nil,4000)
  end
end

return session_manager
