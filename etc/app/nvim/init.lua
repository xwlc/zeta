-- https://neovim.io/doc/user/options.html
-- https://github.com/neovim/neovim/issues/4867
-- restore default cursor shape after nvim exit => IBeam Blinking
vim.cmd([[autocmd VimLeave * set guicursor=a:blinkoff600-blinkon600-ver25]])

print('Hi!')
