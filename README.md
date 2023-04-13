# History Jumper for Neovim

History Jumper is a plugin for Neovim that allows you to quickly jump to previously opened files using just three keystrokes. It is a great productivity tool for developers who work with multiple files simultaneously.

## Installation

You can install History Jumper using your favorite plugin manager. Here's an example using [lazy.nvim](https://github.com/tjdevries/lazy.nvim):

```lua
return {
    'zzhirong/history-jumper.nvim',
    dependencies = {
        'junegunn/fzf.vim'
    },
    config = function()
        require'history-jumper.nvim'.setup({
            default_mappings = true,
        })
    end
}
```

Make sure to also have [fzf.vim](https://github.com/junegunn/fzf.vim) installed.

## Custom Key Mapping

You can customize the key mapping for History Jumper by setting the `prefix` option in the configuration. Here's an example:

```lua
return {
    'zzhirong/history-jumper.nvim',
    config = function()
        require'history-jumper.nvim'.setup({
            prefix = 'S',
        })
    end
}
```

## Usage

To jump to a previously opened file, input three keystrokes: `prefix` + `the first letter of the last path portion` + `the first letter of the file name`.

For example, to jump to `history-jumper/lua/init.lua`:

1. The first key is `prefix`, which was assigned in the configuration (default is `S`).
2. The last path portion is `lua`, so the second letter is `l`.
3. The file name is `init.lua`, so the third letter is `i`.

So the final key to switch to `history-jumper/lua/init.lua` is `Sli`.
