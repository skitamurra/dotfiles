# ~/.zshrc
stty -ixon -ixoff
autoload -Uz compinit
compinit -C -d "$HOME/.zcompdump"

autoload -Uz smart-insert-last-word
zle -N insert-last-word smart-insert-last-word

autoload -Uz edit-command-line
zle -N edit-command-line

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
export ZENO_GIT_CAT="batcat --color=always"
export ZENO_GIT_TREE="eza --tree"
export BROWSER=wslview
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/share/fnm:$PATH"
export PATH="$HOME/.pyenv/bin:$PATH"

# =========================================================
# FUNCTION
# =========================================================
cd() {
  case "$1" in
    ""|-|/*|./*|../*|~* )
      builtin cd "$@"
      return
      ;;
  esac

  if [ -d "$1" ]; then
    builtin cd "$1"
    return
  fi

  local dest="$(zoxide query -- "$1" 2>/dev/null)"
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

nvim-fzf() {
  (
    exec 1>/dev/null
    local target
    while true; do
      local out
      out=$(find . -maxdepth 1 ! -path . | fzf \
        --preview "if [ -d {} ]; then ls -AF --color=always {}; else batcat --color=always {}; fi" \
        --header "PWD: $PWD | ^: Up" \
        --expect="^")

      local key=$(head -1 <<< "$out")
      target=$(tail -1 <<< "$out")
      if [[ "$key" == "^" ]]; then
        cd ..
        continue
      fi
      [ -z "$target" ] && break
      if [ -d "$target" ]; then
        cd "$target"
        continue
      else
        nvim "$target" </dev/tty >/dev/tty 2>&1
        break
      fi
    done
  )
  zle reset-prompt
}
zle -N nvim-fzf

function ghq-fzf() {
  local src=$(ghq list | fzf --preview "batcat --color=always --style=header,grid --line-range :80 $(ghq root)/{}/README.*")
  if [ -n "$src" ]; then
    BUFFER="cd $(ghq root)/$src"
    zle accept-line
  fi
  zle reset-prompt
}
zle -N ghq-fzf

create_gitignore() {
    local input_file="$1"
    if [[ -z "$input_file" ]]; then
        input_file=".gitignore"
    fi

    local selected=$(gibo list | fzf \
        --multi \
        --preview "gibo dump {} | batcat --style=numbers --color=always --paging=never")
    if [[ -z "$selected" ]]; then
        echo "No templates selected. Exiting."
        return
    fi

    echo "$selected" | xargs gibo dump >> "$input_file"
    batcat "$input_file"
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
alias gia='create_gitignore'
alias bat='batcat --color=always'

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

ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(zeno-auto-snippet-and-accept-line)

zcomp_source "$sheldon_cache"
unset cache_dir sheldon_cache sheldon_toml

bindkey ' '  zeno-auto-snippet
bindkey '^m' zeno-auto-snippet-and-accept-line
bindkey '^i' zeno-completion
bindkey '^r' zeno-smart-history-selection
bindkey '^q' push-line
bindkey '^]' insert-last-word
bindkey '^e' edit-command-line
bindkey '^n' nvim-fzf
bindkey '^g' ghq-fzf
