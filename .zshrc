source $HOME/.path
source $HOME/.env_vars
source $HOME/.aliases
source $HOME/.functions

# Plugins
plugins=(git zsh-syntax-highlighting)

# Oh my ZSH
source $ZSH/oh-my-zsh.sh

autoload -U promptinit; promptinit
prompt pure
