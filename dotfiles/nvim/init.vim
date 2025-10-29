" Поднять те же пути, что у Vim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

" Хранилище плагинов vim-plug такое же, как у Vim
let g:plug_home = expand('~/.vim/plugged')

" Использовать ваш .vimrc без изменений
source ~/.vimrc

" Визуальные мелочи, чтобы совпадало
if has('termguicolors')
  set termguicolors     " truecolor в kitty/wezterm/alacritty
endif
set guicursor=          " курсор как в Vim (без «модных» форм Neovim)
if has("termguicolors")
  set termguicolors
endif
hi Normal ctermbg=none guibg=none
hi NonText ctermbg=none guibg=none
hi EndOfBuffer ctermbg=none guibg=none

