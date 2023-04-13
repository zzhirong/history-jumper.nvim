local vim = vim
local api = vim.api

local M = {}

local function get_history_files()
    local history_files = {}
    -- local history_dir = fn.expand("~/.local/share/nvim/history/")
    -- local files = fn.globpath(history_dir, "*", false, true)
    local files = vim.v.oldfiles
    for _, file in ipairs(files) do
        local parts = vim.split(file, "/")
        local first_letter = string.sub(parts[#parts-1], 1, 1)
        local second_letter = string.sub(parts[#parts], 1, 1)
        local k = first_letter .. second_letter
        if not history_files[k] then
            history_files[k] = {}
        end
        history_files[k][file] = true
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

    local ok2, code2 = pcall(vim.fn.getchar)
    if not ok2 then
        return
    end
    local char1 = vim.fn.nr2char(code1)
    local char2 = vim.fn.nr2char(code2)
    local k = char1 .. char2
    local history_files = get_history_files()
    if not history_files[k] then
        print("No history starts with" .. k)
        return
    end
    local files = vim.tbl_keys(history_files[k])
    if files and (#files == 1) then
        open_history_file(files[1])
    else
        vim.fn['fzf#run'](
        {
            source = files,
            sink = 'e',
        }
        )
    end
end

function M.setup(opts)
    local key = (opts and opts.prefix) or 'S'
    vim.keymap.set('n', key, history_jump, {})
end

return M
