" 文字コードをUFT-8に設定
set encoding=utf-8
" ビープ音を消す
set belloff=all
" 行末の1文字先までカーソルを移動できるように
set virtualedit=onemore
" 挿入モード中にバックスペースで文字を消せるように
set backspace=indent,eol,start
" 画面端のスクロールに余裕
set scrolloff=5
" マウス操作を有効にする
set mouse=a

"シンタックスハイライトを有効にする
syntax enable
" 行番号を表示する
set number
" 現在の行を強調表示
set cursorline
" カーソルの位置表示を行う
set ruler
" ステータスラインを常に表示
set laststatus=2
" タイトルを表示
set title
" 括弧入力時の対応する括弧を表示
set showmatch

" Tab
" タブをスペースに変換する
set expandtab
" ファイル上のタブ文字を見た目上何文字分にするかを指定する。
set tabstop=2
" 自動で挿入されるインデントのスペース幅
set shiftwidth=2
" tab キーを押した時に挿入されるスペース量
set softtabstop=2


" 検索
" 検索語をハイライト表示
set hlsearch
" 検索文字列が小文字の場合は大文字小文字を区別なく検索する
set ignorecase
" 検索文字列に大文字が含まれている場合は区別して検索する
set smartcase
" 検索文字列入力時に順次対象文字列にヒットさせる
set incsearch
" 検索時に最後まで行ったら最初に戻る
set wrapscan
