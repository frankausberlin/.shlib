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

# Connections
alias opi="ssh orangepi@opi"
alias ubi="ssh frank@ubi"
alias doogee="ssh -o IdentitiesOnly=yes -i ~/.ssh/id_doogee -p 8022 u0_a209@doogee"
alias redmi="ssh -o IdentitiesOnly=yes -i ~/.ssh/id_rsa -p 8022 u0_a470@redmi"
alias teci="ssh -p 8022 u0_a218@teci"

# Utilities
alias lsc="ls -d .[^.]*"
alias rlb="source ~/.zshrc"


# AI/ML Tools

# Kilocode CLI
alias kc="kilocode"

# ShellGPT shortcut
alias ex='sgpt -s'


