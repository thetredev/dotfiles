# related setttings after
#  export OSH=.....

OSH_THEME="brainy"
OMB_CASE_SENSITIVE="false"
OMB_HYPHEN_SENSITIVE="false"
DISABLE_AUTO_UPDATE="false"
DISABLE_LS_COLORS="false"
ENABLE_CORRECTION="false"
COMPLETION_WAITING_DOTS="false"
DISABLE_UNTRACKED_FILES_DIRTY="true"
SCM_GIT_DISABLE_UNTRACKED_DIRTY="true"
SCM_GIT_IGNORE_UNTRACKED="false"
HIST_STAMPS='yyyy-mm-dd'
OMB_USE_SUDO=false

completions=(
  git
  ssh
  docker
  docker-compose
  kubectl
  helm
  pip
  pip3
  tmux
  makefile
)

aliases=(
)

plugins=(
  git
  golang
  kubectl
  sudo
)

source "$OSH"/oh-my-bash.sh

# User config
## show full path in prompt
unset PROMPT_DIRTRIM
## do not echo $PWD after each cd
unset CDPATH
