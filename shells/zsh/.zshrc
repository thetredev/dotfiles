export ZSH="${HOME}/.oh-my-zsh"

ZSH_THEME="bureau"
plugins=(git docker docker-compose)

source ${ZSH}/oh-my-zsh.sh

# Refresh PATH on change
zstyle ':completion:*' rehash true

if [ -f ${HOME}/.user_profile.sh ]; then
    source ${HOME}/.user_profile.sh
fi

clear
