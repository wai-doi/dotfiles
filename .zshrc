# zplug
export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

zplug 'zplug/zplug', hook-build:'zplug --self-manage'
zplug "mafredri/zsh-async"
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
zplug "chrissicool/zsh-256color"
zplug "b4b4r07/enhancd", use:init.sh

zplug "ohmyzsh/ohmyzsh", use:"lib/*.zsh"
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
setopt share_history
setopt hist_reduce_blanks
setopt list_packed
setopt list_types
setopt globdots


# load
eval "$(starship init zsh)"
eval "$(direnv hook zsh)"
source ~/.iterm2_shell_integration.zsh

## rbenv PATH
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"


# alias
alias reload='source ~/.zshrc'
alias vs='code .'
alias t='tig'
alias ta='tig --all'
alias be='bundle exec'
alias bi='bundle install'
alias bu='bundle update'
alias cb='git checkout `git branch | peco | sed -e "s/\* //g" | awk "{print \$1}"`'
alias repo='gh repo view --web'


# function
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

function pro() {
    if [ -n "$1" ]; then
        gh pr view $1 --web
    else
        gh pr view --web  || gh pr create --web
    fi
}

function prl() {
    pr_num=$(gh pr list -s all "$@" | peco | cut -f 1)

    if [ -n "$pr_num" ]; then
        gh pr view $pr_num --web
    fi
}

function cbpr() {
    pr_num=$(gh pr list -s all "$@" | peco | cut -f 1)

    if [ -n "$pr_num" ]; then
        gh pr checkout $pr_num
    fi
}
