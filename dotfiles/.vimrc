" RU → EN в Normal/Visual/Operator (чтобы jkl; работали при русской раскладке)
set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz,ё;`,Ё;~
set clipboard=unnamedplus
let g:polyglot_disabled = ['cs']
cd ~/Unity/Platformer/Assets/_Scripts
" макрос
let @a = 'd2d4kV10kdl'
" Принудительно английская раскладка при входе в Normal mode
autocmd WinEnter,FocusGained * if mode() ==# 'n' | call system('setxkbmap us') | endif
" Кастом jkl; → hjkl для английской и русской раскладки
" " Включаем русскую раскладку для трансляции клавиш
let g:ibus_mode = 'english'        " Normal mode
let g:ibus_insert_mode = 'english'  " Insert mode
"Normal mode английская
nnoremap j h
nnoremap k j
nnoremap l k
nnoremap ; l

" Visual mode английская
vnoremap j h
vnoremap k j
vnoremap l k
vnoremap ; l

" Visual mode русская
" Ctrl+C, независимо от раскладки
" Берём код символа Ctrl+С независимо от текущей клавиатуры
" В Vim терминала Ctrl+C всегда работает, но если русский "с" ломает:
nnoremap <C-с> <C-c>
inoremap <C-с> <C-c>
vnoremap <C-с> <C-c>
" ----------------------------
" Восстановление последнего файла и позиции курсора
" ----------------------------

" При выходе из Vim: сохраняем путь к последнему редактируемому файлу
autocmd VimLeavePre * if expand('%') != '' | call writefile([expand('%:p')], expand('~/.vim/lastfile')) | endif

" Функция для открытия последнего файла
function! OpenLastFile()
  if argc() == 0 && filereadable(expand('~/.vim/lastfile'))
    let lastfile = trim(readfile(expand('~/.vim/lastfile'))[0])
    if filereadable(lastfile)
      execute 'edit ' . fnameescape(lastfile)
    endif
  endif
endfunction

" При входе в Vim без аргументов: открываем файл с небольшой задержкой,
" чтобы плагины успели инициализироваться
autocmd VimEnter * call timer_start(0, {-> OpenLastFile()})

" Восстановление позиции курсора
if has("autocmd")
  au BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \   exe "normal! g'\"" |
        \ endif
endif
" ===========================
" Плагины
" ===========================
call plug#begin('~/.vim/plugged')

" --- C# / Unity ядро ---
Plug 'OmniSharp/omnisharp-vim'          " C# LSP-like
Plug 'dense-analysis/ale'                " Диагностика/форматирование
Plug 'sheerun/vim-polyglot'              " Подсветка (C# в т.ч.)
Plug 'farmergreg/vim-lastplace'
Plug 'lilydjwg/ibus-vim'

" --- Навигация и утилиты ---
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'

" --- Сниппеты (опционально) ---
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'               " Наборы сниппетов

Plug 'preservim/nerdtree'
call plug#end()

" ===========================
" OmniSharp
" ===========================
" укажите путь, если ставили из пакета ОС:
let g:OmniSharp_server_path = '/usr/bin/omnisharp'   " проверьте: :!which omnisharp

let g:OmniSharp_highlighting = 1
let g:OmniSharp_diagnostic_enable = 0    " диагностику отдаём ALE

" Completion из OmniSharp
autocmd FileType cs setlocal omnifunc=OmniSharp#Complete
set completeopt=menuone,noinsert,noselect

" Клавиши и команды только для C#
augroup OmniSharpMaps
  autocmd!
  autocmd FileType cs nnoremap <silent> <buffer> gd  :OmniSharpGotoDefinition<CR>
  autocmd FileType cs nnoremap <silent> <buffer> <leader>fi :OmniSharpFindImplementations<CR>
  autocmd FileType cs nnoremap <silent> <buffer> <leader>fu :OmniSharpFindUsages<CR>
  autocmd FileType cs nnoremap <silent> <buffer> <leader>rn :OmniSharpRename<CR>
  autocmd FileType cs nnoremap <silent> <buffer> <leader>ti :OmniSharpTypeLookup<CR>
  autocmd FileType cs nnoremap <silent> <buffer> <leader>ca :OmniSharpCodeActions<CR>
augroup END

" ===========================
" ALE: диагностика и форматирование
" ===========================
let g:ale_linters = { 'cs': ['omnisharp'] }
let g:ale_fixers = {}
let g:ale_fix_on_save = 0
let g:ale_virtualtext_cursor = 1
" Если путь к csharpier не в $PATH:
" let g:ale_csharpier_executable = expand('~/.dotnet/tools/dotnet-csharpier')

" ===========================
" Поиск (fzf)
" ===========================
nnoremap <leader>p  :Files<CR>
nnoremap <leader>/  :Rg<Space>
" ===========================
" Клавиши
" ===========================
" Сочетание клавиш для переключения NERDTree
nnoremap <C-b> :NERDTreeToggle<CR>

" Сочетание клавиш для копирования в системный буфер обмена
nnoremap <C-y> "+y
vnoremap <C-y> "+y

" Сочетание клавиш для отключения подсветки поиска
nnoremap <Esc> :nohlsearch<CR>

" Отключение стрелок для навигации
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

noremap! <Up> <NOP>
noremap! <Down> <NOP>
noremap! <Left> <NOP>
noremap! <Right> <NOP>

" Прокрутка + центрирование
nnoremap <C-D> <C-D>zz
nnoremap <C-U> <C-U>zz
" А вот тут маё

" Основные настройки
" ===========================
" Кодировка
set encoding=utf-8             " Устанавливаем кодировку UTF-8
set fileencodings=utf-8        " Поддержка кодировки UTF-8 для файлов

set nocompatible               " Отключаем совместимость с vi
filetype plugin indent on      " Включаем поддержку плагинов 

" ===========================
" Настройки отображения
" ===========================
set relativenumber             " Включаем относительную нумерацию строк
set number                     " Включаем абсолютную нумерацию для текущей строки
set numberwidth=1              " Ширина номера строки

highlight LineNr ctermfg=NONE guifg=NONE  " Отключаем цвет для номеров строк
highlight CursorLineNr ctermfg=NONE guifg=NONE  " Отключаем цвет для текущего номера строки

syntax on                      " Включаем подсветку синтаксиса

set scrolloff=5                " Отступ от края экрана при прокрутке
set background=dark            " Тёмная тема

" ===========================
" Настройки табуляции
" ===========================
set expandtab                  " Заменяем табуляции на пробелы
set tabstop=4                  " Количество пробелов для табуляции
set shiftwidth=4               " Количество пробелов при автодобавлении отступов
set softtabstop=4              " Количество пробелов при автотабуляции

set smarttab                   " Умное поведение табуляции
set smartindent                " Умное выравнивание для кода

" ===========================
" Языковые настройки
" ===========================
set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz
" Поддержка русской раскладки для команд

" ===========================
" Безопасность
" ===========================
set modelines=0     " Отключаем CVE-2007-2438 уязвимость

" ===========================
" Производительность
" ===========================
set backspace=indent,eol,start " Больше возможностей для удаления текста
set nowrap                     " Отключаем перенос строк
set ruler                      " Показывать текущие координаты курсора
" ===========================
" Автокоманды
" ===========================
" Не создавать резервные копии для crontab и chpass
au BufWrite /private/tmp/crontab.* set nowritebackup nobackup
au BufWrite /private/etc/pw.* set nowritebackup nobackup

" ===========================
" Поиск
" ===========================
set hlsearch                   " Включаем подсветку поиска
set incsearch                  " Поиск по мере ввода
set ic                         " Игнорировать регистр при поиске
set smartcase                  " Игнорировать регистр, если нет заглавных букв


