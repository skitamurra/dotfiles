# ~/.zshrc
stty -ixon
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

setopt inc_append_history
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_no_store

# =========================================================
# export
# =========================================================
export EDITOR=nvim
export MANPAGER='nvim +Man!'
export BROWSER=wslview
export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!.git/*'"
export FZF_DEFAULT_OPTS=' --layout=reverse --border=rounded --height=45% --margin=0.5% --bind=tab:down --bind=shift-tab:up '
export SHELDON_CONFIG_DIR="$HOME/.config/sheldon"
export ZENO_HOME="$HOME/.config/zeno"
export ZENO_COMPLETION_FALLBACK=fzf-tab-complete
export CLAUDE_CONFIG_DIR="$HOME/.config/claude"
export JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX/Homebrew"

typeset -gU path PATH
path=(
  $HOME/bin
  $HOME/.local/bin
  /usr/local/bin
  $HOMEBREW_PREFIX/bin
  $HOMEBREW_PREFIX/sbin
  $HOME/go/bin
  $HOME/.cargo/bin
  $HOME/.local/share/fnm
  $HOME/.pyenv/bin
  $JAVA_HOME/bin
  $HOME/dev/flutter/bin
  $ANDROID_HOME/cmdline-tools/latest/bin
  $ANDROID_HOME/platform-tools
  $HOME/.pub-cache/bin
  $path
)

# =========================================================
# functions / completion
# =========================================================
ZSH_HOME="$HOME/.config/zsh"
local func_dir="$ZSH_HOME/functions"
typeset -gU fpath=("$ZSH_HOME/completions" $func_dir/*(N/) $fpath)
autoload -Uz compinit smart-insert-last-word edit-command-line $func_dir/*/*(N.:t)
load_plugins
compinit -C -d "$HOME/.zcompdump"
ensure_zcompiled "$HOME/.zcompdump"

# =========================================================
# keybind
# =========================================================
zle -N nvim-fzf
zle -N cd-fzf
zle -N smart-insert-last-word
zle -N edit-command-line
zle -N fyler

key_conf () {
  bindkey '^q' push-line
  bindkey '^]' smart-insert-last-word
  bindkey '^e' edit-command-line
  bindkey '^n' nvim-fzf
  bindkey '^g' cd-fzf
  bindkey '^f' fyler
  if [[ -n $ZENO_LOADED ]]; then
    ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(zeno-auto-snippet-and-accept-line)
    bindkey ' '  zeno-auto-snippet
    bindkey '^m' zeno-auto-snippet-and-accept-line
    bindkey '^i' zeno-completion
    bindkey '^r' zeno-smart-history-selection
  fi
}
zsh-defer key_conf

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

run_startup
