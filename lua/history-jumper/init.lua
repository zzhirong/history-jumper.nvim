local vim = vim
local api = vim.api

local M = {
    opts = {
        prefix = "|",
        change_dir = true,
    }
}

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

local function filter_oldfiles_by_parent_dir_first_letter(first)
    local history_files = {}
    local files = vim.v.oldfiles
    for _, file in ipairs(files) do
        if not file_exists(file) then
            goto continue
        end

        local parts = vim.split(file, "/")
        if parts == nil or #parts == 0 then
            -- get absoulte path
            file = vim.fn.fnamemodify(file, ':p')
            parts = vim.split(file, "/")
        end
        if parts == nil or #parts == 0 then
            goto continue
        end
        local c1 = string.sub(parts[#parts - 1], 1, 1)
        if c1 == first then
            table.insert(history_files, file)
        end
        ::continue::
    end
    return history_files
end

local function open_history_file(file)
    if vim.g.vscode then
        vim.fn.VSCodeExtensionNotify('open-file', file)
    else
        api.nvim_command("edit " .. file)
    end
end

local function history_jump()
    local ok, code1 = pcall(vim.fn.getchar)
    if not ok then
        return
    end
    local c1 = vim.fn.nr2char(code1)
    local oldfiles = filter_oldfiles_by_parent_dir_first_letter(c1)
    if #oldfiles == 0 then
        print("No path starts with " .. c1)
        return
    end

    local file = pselect(oldfiles)

    if file then
        open_history_file(file)
        if M.opts.change_dir then
            local dir = vim.fn.fnamemodify(file, ':h')
            api.nvim_command("cd " .. dir)
            -- check if the directory is in a git repo and cd to it if so
            local git_dir = vim.fn.finddir('.git', dir .. ';')
            if git_dir ~= '' then
                -- cd to the parent directory of the .git directory
                api.nvim_command("cd " .. vim.fn.fnamemodify(git_dir, ':h'))
            end
        end
    end
end

function M.setup(opts)
    if opts then
        M.opts = vim.tbl_extend("force", M.opts, opts)
    end
    vim.keymap.set('n', M.opts.prefix, history_jump, {})
end

return M
