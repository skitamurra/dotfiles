shopt -s expand_aliases

# --- ls 系 ---
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# alert for long running commands
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# project shortcuts
alias cd-auth='cd ~/develop/rugby_auth'
alias cd-docker='cd ~/develop/rugby-docker'
alias cd-core='cd ~/develop/rugby-core'
alias cd-bo='cd ~/develop/rugby-bo'
alias cd-portal='cd ~/develop/rugby-portal'
alias cd-regression='cd ~/develop/rugby-regression-test'

# docker & compose shortcuts
alias docker-up='(cd-docker && docker compose up -d)'
alias docker-down='(cd-docker && docker compose down)'

# core service shortcuts
alias core-up='(
    cd-core && \
    cat ~/develop/github-personal-access-tokens.txt | docker login ghcr.io -u skitamura --password-stdin && \
    docker compose -f docker-compose.ci.yml up -d && \
    docker compose -f docker-compose.ci.yml exec -T app pipenv sync --dev --system && \
    for i in {1..10};do docker compose -f docker-compose.ci.yml exec -T app python manage.py migration all upgrade head && break; sleep 2; done && \
    docker compose -f docker-compose.ci.yml exec -T app python create_dev_api_keys.py
)'
alias core-down='(cd-core && docker compose down)'

# bo service shortcuts
alias bo-up='(
    cd-bo && \
    docker compose up -d && \
    docker compose -f docker-compose.ci.yml up -d && \
    docker compose -f docker-compose.ci.yml exec -T app pipenv sync --dev --system && \
    for i in {1..10};do docker compose -f docker-compose.ci.yml exec -T app python manage.py migration all upgrade head && break; sleep 2; done
)'
alias bo-down='(cd-bo && docker compose down)'

# regression shortcuts
alias regression-up='(
    cd-regression && \
    docker-up && \
    core-up && \
    bo-up
)'
alias regression-down='(
    cd-regression && \
    bo-down && \
    core-down && \
    docker-down
)'
alias regression-restart='(
    cd-regression && \
    regression-down && \
    regression-up
)'

# nvim/wezterm shortcuts
alias v='nvim'
alias v-nvim='nvim $HOME/.config/nvim/init.lua'
alias v-bashrc='nvim ~/.bashrc'
alias source-bashrc='source ~/.bashrc'
alias v-wezterm='nvim $HOME/.config/wezterm/wezterm.lua'

alias note='nvim ~/NOTE.md'
