# ~/.zshrc
HISTFILE=~/.config/zsh/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt inc_append_history
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_no_store

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

fzf_options=(
    --layout reverse
    --border rounded
    --height 45%
    --margin 0.5%
    --bind 'tab:down'
    --bind 'shift-tab:up'
)
fzf() {
    command fzf "${fzf_options[@]}" "$@"
}

# =========================================================
# EXPORT
# =========================================================
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.nodenv/bin:$PATH"
export PATH="/opt/nvim-linux-x86_64/bin:$PATH"
export PATH="$HOME/dev/flutter/bin:$PATH"
export PATH="$HOME/develop/yzrh-utils/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/lua-language-server/bin:$PATH"
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
export PATH="$ANDROID_HOME/platform-tools:$PATH"
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
export PATH="$JAVA_HOME/bin:$PATH"
export PATH="$HOME/.pub-cache/bin:$PATH"
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export SHELDON_CONFIG_DIR="$HOME/.config/zsh/sheldon"

# =========================================================
# FUNCTION
# =========================================================
function zvm_config() {
  ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
}

cd() {
  if [ $# -eq 0 ]; then
    builtin cd ~
    return
  fi

  case "$1" in
    -|/*|./*|../*|~* )
      builtin cd "$@"
      return
      ;;
  esac

  if [ -d "$1" ]; then
    builtin cd "$1"
    return
  fi

  local dest
  dest="$(zoxide query -- "$1" 2>/dev/null)"

  if [ -n "$dest" ] && [ -d "$dest" ]; then
    builtin cd "$dest"
    return
  fi

  print -u2 "cd: no such file or directory: $1"
  return 1
}

__git_current_branch() {
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  [[ -n $branch ]] && compadd "$branch"
}

_git_push_current_branch_only() {
  _arguments \
    '1:command:(push)' \
    '2:remote:__git_remotes' \
    '3:branch:__git_current_branch'
}

compdef _git_push_current_branch_only git

function zvm_after_init() {
  autopair-init
}

function fzf-select-history() {
    BUFFER=$(history -n -r 1 | fzf --query "$LBUFFER" --reverse)
    CURSOR=$#BUFFER
    zle reset-prompt
}
zle -N fzf-select-history

autoload -Uz add-zsh-hook
add-zsh-hook precmd () { bindkey '^r' fzf-select-history }

zshaddhistory() {
    local line=${1%%$'\n'}
    local cmd=${line%% *}
    if [[ -n "$cmd" ]] && ! type "$cmd" >/dev/null 2>&1; then
        return 1
    fi
}

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
alias v='nvim'
alias v-nvim='nvim $HOME/.config/nvim/init.lua'
alias v-bashrc='nvim ~/.bashrc'
alias source-bashrc='source ~/.bashrc'
alias v-wezterm='nvim $HOME/.config/wezterm/wezterm.lua'
alias note='nvim ~/NOTE.md'

# =========================================================
# SOURCE
# =========================================================
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

function ensure_zcompiled {
  local compiled="$1.zwc"
  if [[ ! -r "$compiled" || "$1" -nt "$compiled" ]]; then
    echo "\033[1;36mCompiling\033[m $1"
    zcompile $1
  fi
}
function source {
  ensure_zcompiled $1
  builtin source $1
}
ensure_zcompiled ~/.config/zsh/.zshrc

cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}
sheldon_cache="$cache_dir/sheldon.zsh"
sheldon_toml="$HOME/.config/zsh/sheldon/plugins.toml"
if [[ ! -r "$sheldon_cache" || "$sheldon_toml" -nt "$sheldon_cache" ]]; then
  mkdir -p $cache_dir
  sheldon source > $sheldon_cache
fi
source "$sheldon_cache"
unset cache_dir sheldon_cache sheldon_toml
