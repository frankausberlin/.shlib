# Bash Aliases

# Original aliases from .bashrc
# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Navigation / Shell
alias l='cd ~/labor'
alias g='cd ~/labor/gits'
alias d='cd ~/Downloads'
alias t='cd ~/labor/tmp'


# System Management

# Update system packages with confirmation
alias suu="sudo nala update && sudo nala upgrade -y && sudo nala autoremove -y && sudo nala clean && flatpak update -y && sudo snap refresh"

# firsties (what I typed first when I start the day)
alias los="cw && suu"
alias losj="cw && suu && jl ."
alias losc="cw && suu && code ."

# Stop Docker containers and compose
alias stop='[ -f docker-compose.yaml ] && (echo -e "\n\e[103mDOWN\e[0m" && docker compose down); running_containers=$(docker ps -q); [ -n "$running_containers" ] && (echo -e "\n\e[103mSTOP\e[0m" && docker stop $running_containers); echo ""'
# Launch Chrome with remote debugging on port 9222

# Connections
alias opi="ssh orangepi@opi"
alias ubi="ssh frank@ubi"
alias doogee="ssh -o IdentitiesOnly=yes -i ~/.ssh/id_doogee -p 8022 u0_a209@doogee"
alias redmi="ssh -o IdentitiesOnly=yes -i ~/.ssh/id_rsa -p 8022 u0_a470@redmi"
alias teci="ssh -p 8022 u0_a218@teci"
alias gd="cd ~/labor/GoogleDrive && [ -z '$(ls -A ~/labor/GoogleDrive)' ] && google-drive-ocamlfuse ~/labor/GoogleDrive"

# Utilities
alias lsc="ls -d .[^.]*"
alias fd="fdfind"
alias rlb="source ~/.bashrc"
alias pypurge='pip cache purge; mamba clean --all'


# AI/ML Tools

# Kilocode CLI
alias kc="kilocode"

# ShellGPT shortcut
alias ex='sgpt -s'


