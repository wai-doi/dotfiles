export HISTSIZE=100000
export SAVEHIST=1000000

# zplug

# 事前に `brew install zplug` の実行が必要
# zplug の README には `source ~/.zplug/init.zsh` と書いてるが Homebrew の場合は以下でよい。
export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

zplug 'zplug/zplug', hook-build:'zplug --self-manage'
zplug "mafredri/zsh-async"
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
zplug "b4b4r07/enhancd", use:init.sh
zplug "Aloxaf/fzf-tab"
zplug "plugins/git", from:oh-my-zsh

if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

zplug load


# setopt
setopt no_beep

setopt share_history           # 履歴を他のシェルとリアルタイム共有する
setopt hist_ignore_all_dups    # 同じコマンドをhistoryに残さない
setopt hist_reduce_blanks      # historyに保存するときに余分なスペースを削除する
setopt hist_save_no_dups       # 重複するコマンドが保存されるとき、古い方を削除する
setopt inc_append_history      # 実行時に履歴をファイルに追加していく

setopt list_packed
setopt list_types
setopt globdots


# load
eval "$(starship init zsh)"
eval "$(direnv hook zsh)"

# iTerm2 Shell Integration
# https://iterm2.com/documentation-shell-integration.html
# 過去のマークはCmd-Shift-Up/Downで行き来できる。
source ~/.iterm2_shell_integration.zsh

## rbenv
eval "$(rbenv init -)"

## nodenv
export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init -)"

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
alias cb='git checkout `git branch --verbose --sort=-committerdate | peco | sed -e "s/\* //g" | awk "{print \\$1}"`'
alias cob="git --no-pager reflog | awk '\$3 == \"checkout:\" && /moving from/ {print \$8}' | awk '!a[\$0]++' | head -n 100 | peco | pbcopy"
alias repo='gh repo view --web'
alias ali='alias | peco | sed -e "s/=.*$//"'


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

# g++でコンパイルエラーになったため、それ回避するための設定。
# 参考: https://qiita.com/ikoanymg/items/b108e97093b50662673d
export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"
