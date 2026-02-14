# local env
if [ -f "$HOME/.zshrc.local" ]; then
    source "$HOME/.zshrc.local"
fi

export HISTSIZE=100000
export SAVEHIST=1000000

# iTerm2 CSI u 対応
# Codex CLI で勝手に文字が入ることを防ぐために Iterm の設定で「Report keys using CSI u」を有効にしている
# https://zenn.dev/woo_noo/articles/58002018de3061
# しかし Shift + Space がスペースとして認識されなくなるなどの問題があるため、以下で対応する
# Shift + Space を通常の Space として認識させる
bindkey '\e[32;2u' magic-space
# Shift + Enter を通常の Enter として認識させる
bindkey '\e[13;2u' accept-line


# setopt
setopt no_beep

setopt share_history           # 履歴を他のシェルとリアルタイム共有する
setopt hist_ignore_all_dups    # 同じコマンドをhistoryに残さない
setopt hist_reduce_blanks      # historyに保存するときに余分なスペースを削除する
setopt hist_save_no_dups       # 重複するコマンドが保存されるとき、古い方を削除する
setopt inc_append_history      # 実行時に履歴をファイルに追加していく
setopt hist_ignore_space       # コマンドの先頭がスペースのとき履歴に追加されない

setopt list_packed
setopt list_types
setopt globdots


# load
eval "$(starship init zsh)"
eval "$(direnv hook zsh)"
eval "$(zoxide init zsh --cmd cd)"


## rbenv
eval "$(rbenv init -)"

## nodenv
export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init -)"

# uv
export PATH="$HOME/.local/bin:$PATH"

## less
export LESS='-i -M -R'
export PAGER=less
export LESS_TERMCAP_mb=$'\E[01;31m'      # Begins blinking.
export LESS_TERMCAP_md=$'\E[01;31m'      # Begins bold.
export LESS_TERMCAP_me=$'\E[0m'          # Ends mode.
export LESS_TERMCAP_se=$'\E[0m'          # Ends standout-mode.
export LESS_TERMCAP_so=$'\E[00;47;30m'   # Begins standout-mode.
export LESS_TERMCAP_ue=$'\E[0m'          # Ends underline.
export LESS_TERMCAP_us=$'\E[01;32m'      # Begins underline.

## bat
export BAT_THEME='Monokai Extended'


# alias
alias reload='source ~/.zshrc'
alias home='cd ~'
alias ll='ls -la --color=auto'
alias vs='code .'
alias t='tig'
alias ta='tig --all'
alias be='bundle exec'
alias bi='bundle install'
alias bu='bundle update'
alias bo='EDITOR=code bundle open'
alias bp='bundle pristine'
# https://qiita.com/vzvu3k6k/items/12aff810ea93c7c6f307
alias bel='BUNDLE_GEMFILE=Gemfile.local be'
alias bei='bundle && BUNDLE_GEMFILE=Gemfile.local bundle'
alias cb='git checkout `git branch --format="%(align:width=70)%(refname:short)%(end) %(objectname:short) %(align:width=15,position=right)%(committerdate:relative)%(end) %(align:width=20)%(authorname)%(end) %(subject)" --sort=-committerdate | peco | awk "{print \\$1}"`'
alias ct='git checkout `git tag --format="%(align:width=70)%(refname:short)%(end) %(objectname:short) %(align:width=15,position=right)%(committerdate:relative)%(end) %(align:width=20)%(authorname)%(end) %(subject)" --sort=-committerdate | peco | awk "{print \\$1}"`'
alias cob="git --no-pager reflog | awk '\$3 == \"checkout:\" && /moving from/ {print \$8}' | awk '!a[\$0]++' | head -n 100 | peco | pbcopy"
alias repo='gh repo view --web'
alias ali='alias | peco | sed -e "s/=.*$//"'
# https://note.com/dev_onecareer/n/n673b1e040956
alias ojt='oj t -c "ruby main.rb" -d test'


# function
# pecoで履歴を検索
function peco-select-history() {
    # historyを番号なし、逆順、最初から表示。
    # 順番を保持して重複を削除。
    # カーソルの左側の文字列をクエリにしてpecoを起動
    # \nを改行に変換
    BUFFER="$(history -nr 1 | awk '!a[$0]++' | peco --query "$LBUFFER" | sed 's/\\n/\n/')"
    CURSOR=$#BUFFER             # カーソルを文末に移動
    zle -R -c                   # refresh
}
zle -N peco-select-history
bindkey '^R' peco-select-history

# リポジトリに移動する
function cr() {
    if [ $# -eq 1 ]; then
        repo=$(ghq list -p | peco --query $1)
    else
        repo=$(ghq list -p | peco)
    fi

    if [ -n "$repo" ]; then
        cd $repo
    fi
}

function ghqhub() {
    if [ $# -eq 1 ]; then
        hub browse $(ghq list | peco --query $1 | cut -d "/" -f 2,3)
    else
        hub browse $(ghq list | peco | cut -d "/" -f 2,3)
    fi
}

function ghqgem() {
    if [ $# -eq 1 ]; then
        open "https://rubygems.org/gems/$(ghq list | peco --query $1 | cut -d "/" -f 3)"
    else
        open "https://rubygems.org/gems/$(ghq list | peco | cut -d "/" -f 3)"
    fi
}

function rgl() {
    rg -p "$@" | less -RK
}

# カレントブランチでPRを開く
function pro() {
    if [ -n "$1" ]; then
        gh pr view $1 --web
    else
        gh pr view --web  || gh pr create --web
    fi
}

# PR一覧から指定したPRをブラウザで開く
function prl() {
    pr_num=$(gh pr list -s all "$@" | peco | cut -f 1)

    if [ -n "$pr_num" ]; then
        gh pr view $pr_num --web
    fi
}

# PR一覧からブランチをチェックアウトする
function cbpr() {
    pr_num=$(gh pr list -s all "$@" | peco | cut -f 1)

    if [ -n "$pr_num" ]; then
        gh pr checkout $pr_num
    fi
}

# 自分が reviewer になっているPR一覧からブランチをチェックアウトする
function review() {
    pr_num=$(gh pr list --search "user-review-requested:@me" | peco | awk '{print $1}')

    if [ -n "$pr_num" ]; then
        gh pr checkout $pr_num
    fi
}

# 最新の安定版 Ruby をインストールして global にする
function update_latest_ruby() {
    brew upgrade ruby-build

    latest=$(rbenv install -l | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' | tail -1)

    echo "Latest stable Ruby version: $latest"

    if ! rbenv versions --bare | grep -qx "$latest"; then
        echo "Installing Ruby $latest..."
        rbenv install "$latest"

        echo "Setting Ruby $latest as global version..."
        rbenv global "$latest"

        echo "Current Ruby version: $(ruby -v)"
    else
        echo "Ruby $latest is already installed."
    fi
}

# g++でコンパイルエラーになったため、それ回避するための設定。
# 参考: https://qiita.com/ikoanymg/items/b108e97093b50662673d
export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"


# zinit
### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# fzf-tabでエラーが出るのを防ぐ
autoload -Uz compinit
compinit
zinit light Aloxaf/fzf-tab

zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

zinit light mafredri/zsh-async
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit snippet OMZL::git.zsh # git_current_branch などを提供する
zinit snippet OMZP::git
zinit snippet OMZP::docker
zinit snippet OMZP::docker-compose


export PATH="/opt/homebrew/opt/python@3.12/bin:$PATH"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/yusuke.doi/.lmstudio/bin"
# End of LM Studio CLI section
