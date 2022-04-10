# todotree.vim

A Neovim function to view all the `TODO`s in your current buffer.

## Setup

Copy the contents of `todotree.vim` into your `~/.config/nvim` directory and
then `source` it from your `init.vim` configuration file. Make sure to also copy
`todos.lua` into `~/.config/nvim/lua/` (make this directory if it does not
already exist).

All that is left is to call the function `TodoTree()` either from normal mode or
map it to your desired keys.
