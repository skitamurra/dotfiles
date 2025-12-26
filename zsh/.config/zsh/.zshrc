# ~/.zshrc
autoload -Uz promptinit
promptinit

HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000

setopt histignorealldups
setopt sharehistory
setopt autocd
setopt extendedglob
setopt notify
setopt hist_ignore_dups
setopt hist_reduce_blanks
setopt share_history

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

# =========================================================
# PATH
# =========================================================

export PATH="$DPRINT_INSTALL/bin:$PATH"

export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init -)"

export PATH="/opt/nvim-linux-x86_64/bin:$PATH"
export PATH="$HOME/dev/flutter/bin:$PATH"
export PATH="$HOME/develop/yzrh-utils/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin/yazi:$PATH"
export PATH="$HOME/lua-language-server/bin:$PATH"

export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
export PATH="$ANDROID_HOME/platform-tools:$PATH"

export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
export PATH="$JAVA_HOME/bin:$PATH"
export PATH="$HOME/.pub-cache/bin:$PATH"
export PATH="$(go env GOPATH)/bin:$PATH"
export PATH="/usr/local/bin:$PATH"

export SHELDON_CONFIG_DIR="$HOME/.config/zsh/sheldon"

# =========================================================
# Vi mode
# =========================================================
bindkey -v
export KEYTIMEOUT=13

bindkey -M viins 'jk' vi-cmd-mode
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward
bindkey '^L' clear-screen
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# function zle-keymap-select {
#   if [[ $KEYMAP == vicmd ]]; then
#     MODE=" %F{cyan}N%f "
#   else
#     MODE=" %F{green}I%f "
#   fi
#   zle reset-prompt
# }
# zle -N zle-keymap-select
#
# MODE=""
# PROMPT='${MODE}%n@%m:%~%# '

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


eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(sheldon source)"
