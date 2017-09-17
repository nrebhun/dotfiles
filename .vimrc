" Colors
syntax enable           " Enable syntax processing

" Spaces & Tabs
set softtabstop=4       " Number of spaces in tab
set expandtab           " Tabs are spaces
set autoindent          " Automatically indent
set smartindent         " Sometimes works? 

" Keyboard Configuration
set backspace=2	         " Make backspace key functions as expected

" Trackpad Configuration
set mouse=a             " enable trackpad scrolling for iTerm

" UI Configuration
set number              " show line numbers
set showcmd             " show commands
set cursorline          " highlight current line
set wildmenu            " show auto-completion in command bar
set lazyredraw          " redraw only when necessary, for performance
set showmatch           " highlight matching braces, parens, and brackets
set colorcolumn=101     " show vertical column at 80th character

" Line Wrapping
set wrap                " enable line wrapping
set linebreak           " enable word wrapping
set textwidth=100       " set per-line character limit

" Search Features
set incsearch           " search as characters are entered
set hlsearch            " highlight matches

" Folding Features
set foldenable          " enable folding
set foldlevelstart=10   " set unfolded level when doc is opened
set foldnestmax=10      " set maximum number of folded lines
