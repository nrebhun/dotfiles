#!/usr/bin/env bash


DEV_FOLDER="$HOME/Development"
DOTFILES="$DEV_FOLDER/dotfiles"

apt_packages=(docker ffmpeg fonts-powerline git htop nmap python3 vim wget zsh zsh-syntax-highlighting)

function install_pip() {
  sudo easy_install pip
}

function install_apt_packages() {
  echo "Installing apt packages..."
  sudo apt-get -q install "${apt_packages[@]}"
  echo "Finished installing apt packages!"
}

function install_oh_my_zsh() {
  curl -L http://install.ohmyz.sh | sh

  echo "Installing Pure theme..."
  mkdir -p "$HOME/.zsh"
  git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
}

function install_powerline_fonts() {
  echo "Cloning Powerline patched fonts:"
  git clone git@github.com:powerline/fonts.git
  echo "Installing..."
  ./fonts/install.sh
  echo "Installation complete. Performing cleanup:"
  rm -rf fonts
  echo "Done."
}

function setup_configs() {
  echo "Copying dotfiles to $HOME..."
  yes | cp -rf $DOTFILES/.[^.][^git]* $HOME
}

function setup_global_gitconfig() {
    read -p "Please enter your GitHub username: " user_name
    read -p "Please enter your GitHub email: " user_email

    git config --global user.name "$user_name"
    git config --global user.email '"$user_email"'
}

function install_packages() {
  install_apt_packages
}

function already_installed() {
  echo "$1 is already installed."
}

function check_and_conditionally_install() {
  command -v pip >/dev/null 2>&1 && already_installed "Pip" || { echo >&2 "Installing pip..."; install_pip; }

  install_packages
  if [ -z "$(cat ~/.gitconfig)" ]; then
    setup_global_gitconfig
  fi

  if [ -d $HOME/.oh-my-zsh ]; then
    already_installed "Oh My Zsh"
  else
    echo  "Installing Oh My Zsh"
    install_oh_my_zsh
  fi

  if ! $(grep -q $(which zsh) /etc/shells); then
    echo "Adding zsh to /etc/shells..."
    sudo bash -c 'echo $(which zsh) >> /etc/shells'
  fi

  if $(echo $0 | grep zsh); then
    chsh -s $(which zsh)
  fi

  # moved to the end, because installing things like 'oh-my-zsh' overwrite the config
  setup_configs

  echo "You should be all set! Get hacking!"
}

check_and_conditionally_install
