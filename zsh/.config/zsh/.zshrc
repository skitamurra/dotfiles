# ~/.zshrc
stty -ixon -ixoff
autoload -Uz compinit
compinit -C -d "$HOME/.zcompdump"

autoload -Uz smart-insert-last-word
zle -N insert-last-word smart-insert-last-word

autoload -Uz edit-command-line
zle -N edit-command-line

HISTFILE=~/.config/zsh/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt inc_append_history
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_no_store

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
export EDITOR=nvim
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
export SHELDON_CONFIG_DIR="$HOME/.config/zsh/sheldon"
export ZENO_HOME=~/.config/zsh/zeno
export ZENO_GIT_CAT="bat --color=always"
export ZENO_GIT_TREE="eza --tree"
export BROWSER=wslview
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/share/fnm:$PATH"
export PATH="$HOME/.pyenv/bin:$PATH"

# =========================================================
# FUNCTION
# =========================================================
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

zshaddhistory() {
    local line=${1%%$'\n'}
    local cmd=${line%% *}
    if [[ -n "$cmd" ]] && ! type "$cmd" >/dev/null 2>&1; then
        return 1
    fi
}

clip() {
  local cmd="$*"
  {
    echo "$ $cmd"
    eval "$cmd" 2>&1 | tee /dev/tty
  } | clip.exe
}

n-find() {
  (
    local target
    while true; do
      local out
      out=$(find . -maxdepth 1 ! -path . | fzf \
        --preview "if [ -d {} ]; then ls -AF --color=always {}; else batcat --color=always {}; fi" \
        --header "PWD: $PWD | ^: Up" \
        --expect="^")
      local state=$?
      
      local key=$(head -1 <<< "$out")
      target=$(tail -1 <<< "$out")

      if [ $state -ne 0 ] && [ -z "$key" ]; then
        break
      fi

      if [[ "$key" == "^" ]]; then
        cd ..
        continue
      fi

      [ -z "$target" ] && break

      if [ -d "$target" ]; then
        cd "$target"
        continue
      else
        nvim "$target"
        break
      fi
    done
  )
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
alias note='nvim ~/NOTE.md'

# =========================================================
# SOURCE
# =========================================================
cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}
cache_init() {
  local name="$1"
  local cmd="$2"
  local cache_file="$cache_dir/${name}.zsh"

  if [[ ! -f "$cache_file" ]]; then
    eval "$cmd" > "$cache_file"
  fi
  source "$cache_file"
}

cache_init starship "starship init zsh"
cache_init zoxide  "zoxide init zsh"
source "$HOME/.deno/env"
eval "$(fnm env --shell zsh --use-on-cd --version-file-strategy=recursive --resolve-engines)"

function ensure_zcompiled {
  local compiled="$1.zwc"
  if [[ ! -r "$compiled" || "$1" -nt "$compiled" ]]; then
    echo "\033[1;36mCompiling\033[m $1"
    zcompile $1
  fi
}
function zcomp_source {
  ensure_zcompiled $1
  source $1
}
ensure_zcompiled ~/.config/zsh/.zshrc

sheldon_cache="$cache_dir/sheldon.zsh"
sheldon_toml="$HOME/.config/zsh/sheldon/plugins.toml"
if [[ ! -r "$sheldon_cache" || "$sheldon_toml" -nt "$sheldon_cache" ]]; then
  mkdir -p $cache_dir
  sheldon source > $sheldon_cache
fi

zcomp_source "$sheldon_cache"
unset cache_dir sheldon_cache sheldon_toml

bindkey ' '  zeno-auto-snippet
bindkey '^m' zeno-auto-snippet-and-accept-line
bindkey '^i' zeno-completion
bindkey '^r' zeno-smart-history-selection
bindkey '^q' push-line
bindkey '^]' insert-last-word
bindkey '^e' edit-command-line
