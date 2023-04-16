local vim = vim
local api = vim.api

local M = {}

local function file_exists(path)
  local stat = vim.loop.fs_stat(path)
  return stat and stat.type == 'file'
end

local function create_win(width, height)
    -- get the size of the current window
    local cur_win_width = vim.api.nvim_win_get_width(0)
    local cur_win_height = vim.api.nvim_win_get_height(0)

    -- calculate the row and column to place the window in the center
    local row = math.floor((cur_win_height - height) / 2)
    local col = math.floor((cur_win_width - width) / 2)

    local buf = vim.api.nvim_create_buf(false, true)
    local opts = {
        style = 'minimal',
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
    }
    local win = vim.api.nvim_open_win(buf, true, opts)

    return win, buf
end

-- Open a popup floating windows to select from a table of history files.
local function pselect(lines)
    local maxlen = 0
    for _, line in ipairs(lines) do
        if #line > maxlen then
            maxlen = #line
        end
    end

    local win, buf = create_win(maxlen, #lines)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    local nu_idx = 0
    local map = {}
    local ns_id = vim.api.nvim_create_namespace("history-jumper")
    for n, line in ipairs(lines) do
        local filename = vim.fn.fnamemodify(line, ':t')
        local c2 = string.sub(filename, 1, 1)
        if map[c2] then
            nu_idx = nu_idx + 1
            c2 = tostring(nu_idx)
        end
        map[c2] = line
        local col = string.find(line, filename, 1, true)
        vim.api.nvim_buf_set_extmark(buf, ns_id, n-1, col-2, {
            virt_text = { { c2, "ErrorMsg" } },
            virt_text_pos = 'overlay',
            hl_mode = 'blend',
        })
    end
    vim.api.nvim_command('redraw')
    local code = 0
    local c2
    for _ = 1, 5 do
        code = vim.fn.getchar()
        c2 = vim.fn.nr2char(code)
        if map[c2] or (code == 27) then
            break
        end
    end
    vim.api.nvim_win_close(win, true)
    return map[c2]
end

local function get_history_files()
    local history_files = {}
    local files = vim.v.oldfiles
    for _, file in ipairs(files) do
        local parts = vim.split(file, "/")
        local c1 = string.sub(parts[#parts-1], 1, 1)
        if not history_files[c1] then
            history_files[c1] = {}
        end

        local c2 = string.sub(parts[#parts], 1, 1)
        if not history_files[c1][c2] then
            history_files[c1][c2] = {}
        end
        table.insert(history_files[c1][c2], file)
    end
    return history_files
end

local function open_history_file(file)
    api.nvim_command("edit " .. file)
end

local function history_jump()
    local ok, code1 = pcall(vim.fn.getchar)
    if not ok then
        return
    end
    local c1 = vim.fn.nr2char(code1)
    local history_files = get_history_files()
    if not history_files[c1] then
        print("No path starts with " .. c1)
        return
    end

    local result = {}
    for _, v1 in pairs(history_files[c1]) do
        for _, file in ipairs(v1) do
            local fn = vim.fn.fnamemodify(file, ":t")
            if file_exists(file) then
                table.insert(result, file)
            end
        end
    end
    local file = pselect(result)

    if file then
        open_history_file(file)
    end
end

function M.setup(opts)
    local key = (opts and opts.prefix) or 'S'
    vim.keymap.set('n', key, history_jump, {})
end

return M
