# History Jumper for Neovim

History Jumper is a plugin for Neovim that allows you to quickly jump to previously opened files using just three keystrokes. It is a great productivity tool for developers who work with multiple files simultaneously.

## Installation

You can install History Jumper using your favorite plugin manager. Here's an example using [lazy.nvim](https://github.com/tjdevries/lazy.nvim):

```lua
return {
    'zzhirong/history-jumper.nvim',
    config = function()
        require'history-jumper'.setup({
            prefix = 'S',
        })
    end
}
```

~~Make sure to also have [fzf.vim](https://github.com/junegunn/fzf.vim) installed.~~
2023-4-17 Update: remove dependencie of `fzf.vim`.

## Custom Key Mapping

You can customize the key mapping for History Jumper by setting the `prefix` option in the configuration.

## Usage

To jump to a previously opened file, input three keystrokes: `prefix` + `the first letter of the last path portion` + `the first letter of the file name`.

For example, to jump to `history-jumper/lua/init.lua`:

1. The first key is `prefix`, which was assigned in the configuration (default is `S`).
2. The last path portion is `lua`, so the second letter is `l`.
3. The file name is `init.lua`, the first letter of the file name, which is `i`:
    1. If there is only one left with filename starts with `i`, then the third letter is `i`.
    2. If there are multiple files with names starting with `i`, this plugin will assign a number index next to the first one, so the third key may be a number.

So the final key to switch to `history-jumper/lua/init.lua` is `Sli` or `sl[0-9]`.
