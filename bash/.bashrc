# Add dprint to PATH
export DPRINT_INSTALL="/home/skitamura/.dprint"
export PATH="$DPRINT_INSTALL/bin:$PATH"


export PATH=$HOME/bin:$PATH
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

if [ -f ~/.bash_completion.d/git-completion.bash ]; then
  source ~/.bash_completion.d/git-completion.bash
fi

# export PYENV_ROOT="$HOME/.pyenv"
# command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"

export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init -)"

export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

export PATH="$HOME/dev/flutter/bin:$PATH"
# xrdb -load ~/.Xresources
export PATH="$HOME/develop/yzrh-utils/bin:$PATH"

# Created by `pipx` on 2025-07-30 10:27:39
export PATH="$PATH:/home/skitamura/.local/bin"

eval "$(starship init bash)"

export PATH=$PATH:~/bin/yazi

_git_push_current_branch_only() {
  local cur prev words cword
  _init_completion -n = || return

  # 現在のブランチ名
  local current_branch
  current_branch=$(git symbolic-ref --short HEAD 2>/dev/null) || current_branch=

  # 「git push origin <TAB>」の3番目でだけ現在ブランチ名を補完
  if [[ ${words[1]} == push && ${COMP_CWORD} -eq 3 && -n $current_branch ]]; then
    COMPREPLY=("$current_branch")
    return 0
  fi

  # --- 通常の git 補完へフォールバック（未ロードなら読み込み） ---
  if declare -F _git >/dev/null; then
    _git
  elif declare -F __git_main >/dev/null; then
    __git_main
  else
    local git_comp
    for git_comp in \
      /usr/share/bash-completion/completions/git \
      ~/.git-completion.bash \
      "$(git --exec-path 2>/dev/null)/../etc/bash_completion.d/git-completion.bash"
    do
      [[ -r $git_comp ]] && . "$git_comp" && break
    done
    declare -F _git >/dev/null && _git
  fi

  # --- push以外では「ローカルブランチのみ」に絞り込み ---
  if [[ ${words[1]} != push ]]; then
    # ローカルブランチ一覧（短縮名）
    local -a __local_heads
    mapfile -t __local_heads < <(git for-each-ref --format='%(refname:short)' refs/heads 2>/dev/null)

    # 早期リターン：ブランチが1本もない or 補完候補が無い
    ((${#__local_heads[@]} == 0 || ${#COMPREPLY[@]} == 0)) && return 0

    # セット化して membership 判定を高速化
    declare -A __is_local_head=()
    local h
    for h in "${__local_heads[@]}"; do
      __is_local_head["$h"]=1
    done

    # 補完候補のうち、ローカルブランチに該当するものだけを残す
    local -a filtered=()
    local c
    for c in "${COMPREPLY[@]}"; do
      # 候補から末尾のスラッシュや空白補助を除去（git-completionが付けることがある）
      local cand="${c%/}"
      # もし cand がローカルブランチ名に一致するなら採用
      if [[ -n "${__is_local_head[$cand]}" ]]; then
        filtered+=("$c")
      fi
    done

    # ブランチ候補が一つでも取れた時だけ置き換える
    if ((${#filtered[@]} > 0)); then
      COMPREPLY=("${filtered[@]}")
    fi
  fi
}

complete -o bashdefault -o default -F _git_push_current_branch_only git
export PATH="$HOME/lua-language-server/bin:$PATH"

eval "$(zoxide init bash)"
cd() {
  # 引数なし → ホーム
  if [ $# -eq 0 ]; then
    builtin cd ~
    return
  fi

  # 特殊ケース → そのまま cd
  case "$1" in
    -|/*|./*|../*|~* )
      builtin cd "$@"
      return
      ;;
  esac

  # カレントディレクトリに存在する → 通常 cd
  if [ -d "$1" ]; then
    builtin cd "$1"
    return
  fi

  # zoxide に曖昧ジャンプ
  local dest
  dest="$(zoxide query -- "$1" 2>/dev/null)"

  if [ -n "$dest" ] && [ -d "$dest" ]; then
    builtin cd "$dest"
    return
  fi

  # 見つからない → 通常のエラー
  printf 'cd: no such file or directory: %s\n' "$1" >&2
  return 1
}

export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="/usr/local/bin:$PATH"
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
export PATH="$JAVA_HOME/bin:$PATH"
export PATH="$PATH:$HOME/.pub-cache/bin"
