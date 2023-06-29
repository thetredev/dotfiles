# History settings
HISTCONTROL=ignoreboth

shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Bash completion
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# ls color
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
fi

# Prompt color
export PS1="\r\n\e[$(tput setaf 1)[$(tput setaf 3)\u$(tput setaf 7)@$(tput setaf 6)\h$(tput setaf 7) \t$(tput setaf 1)]\e[m \w\r\n\$ "

# User profile
if [ -f ${HOME}/.user_profile.sh ]; then
    source ${HOME}/.user_profile.sh
fi
