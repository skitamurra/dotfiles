# ~/.zshrc
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

setopt inc_append_history
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_no_store

ZSH_HOME="$HOME/.config/zsh"
local func_dir="$ZSH_HOME/functions"
typeset -gU fpath=("$ZSH_HOME/completions" $func_dir(N/) $func_dir/**/*(N/) $fpath)
autoload -Uz compinit smart-insert-last-word edit-command-line $func_dir/**/*(N.:t)
compinit -C -d "$HOME/.zcompdump"
zle -N nvim-fzf
zle -N ghq-fzf
zle -N smart-insert-last-word
zle -N edit-command-line

key_conf () {
  bindkey '^q' push-line
  bindkey '^]' smart-insert-last-word
  bindkey '^e' edit-command-line
  bindkey '^n' nvim-fzf
  bindkey '^g' ghq-fzf
  if [[ -n $ZENO_LOADED ]]; then
    ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(zeno-auto-snippet-and-accept-line)
    bindkey ' '  zeno-auto-snippet
    bindkey '^m' zeno-auto-snippet-and-accept-line
    bindkey '^i' zeno-completion
    bindkey '^r' zeno-smart-history-selection
  fi
}
# =========================================================
# export
# =========================================================
export EDITOR=nvim
export FZF_DEFAULT_OPTS=' --layout=reverse --border=rounded --height=45% --margin=0.5% --bind=tab:down --bind=shift-tab:up '
export PATH="$HOME/bin:$PATH"
export PATH="/opt/nvim-linux-x86_64/bin:$PATH"
export PATH="$HOME/dev/flutter/bin:$PATH"
export PATH="$HOME/develop/yzrh-utils/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/lua-language-server/bin:$PATH"
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
export PATH="$ANDROID_HOME/platform-tools:$PATH"
export JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"
export PATH="$JAVA_HOME/bin:$PATH"
export PATH="$HOME/.pub-cache/bin:$PATH"
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export SHELDON_CONFIG_DIR="$HOME/.config/sheldon"
export ZENO_HOME=~/.config/zeno
export ZENO_GIT_CAT="batcat --color=always"
export ZENO_GIT_TREE="eza --tree"
export ZENO_COMPLETION_FALLBACK=fzf-tab-complete
export BROWSER=wslview
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/share/fnm:$PATH"
export PATH="$HOME/.pyenv/bin:$PATH"

# =========================================================
# alias
# =========================================================
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias note='nvim ~/NOTE.md'
alias gia='create_gitignore'
alias bat='batcat --color=always'

run_startup
zsh-defer key_conf
ensure_zcompiled "$HOME/.config/zsh/.zshrc"
