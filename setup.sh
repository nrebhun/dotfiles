#!/usr/bin/env bash

DEV_FOLDER="$HOME/Development"
DOTFILES="$DEV_FOLDER/dotfiles"

brew_packages=(git node shellcheck vim wget zsh)
cask_packages=(mactex qlcolorcode qlimagesize qlmarkdown qlstephen quicklook-csv quicklook-json)
atom_url="https://github.com/atom/atom/releases/download/v1.20.0/atom-mac.zip"
homebrew_url="https://raw.githubusercontent.com/Homebrew/install/master/install"
omz_url="https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh"
iterm_url="https://iterm2.com/downloads/stable/latest"

function install_pip() {
  sudo easy_install pip
}

function install_atom() {
  if ! [ -d /Applications/Atom.app ]; then
    curl -OL $atom_url
    echo "Unzipping Atom..."
    unzip -q atom-mac.zip
    echo "Moving Atom..."
    mv Atom.app/ /Applications/
    rm atom-mac.zip
  fi

  echo "Linking Atom CLI..."
  ln -s /Applications/Atom.app/Contents/Resources/app/atom.sh /usr/local/bin/atom
}

function install_atom_packages() {
  apm install --packages-file $1
}

function install_homebrew() {
  /usr/bin/ruby -e "$(curl -fsSL $homebrew_url)"
  brew update && brew upgrade
}

function install_brew_packages() {
  echo "Installing Homebrew packages..."
  for item in "${brew_packages[@]}"; do
    echo "Brew-installing $item"
    brew install $item
  done
  echo "Finished installing Homebrew packages!"
}

function install_cask_packages() {
  echo "Installing Cask packages..."
  brew tap caskroom/cask
  for item in "${cask_packages[@]}"; do
    echo "Cask-installing $item"
    brew cask install $item
  done
  echo "Finished installing Cask packages!"
}

function install_oh_my_zsh() {
  curl -L http://install.ohmyz.sh | sh

  if [[ $(system_profiler SPFontsDataType | grep Powerline) ]]; then
    already_installed "It appears 'Powerline fonts'"
  else
    install_powerline_fonts
  fi
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

function install_iterm() {
  curl -Lq $iterm_url > iterm.zip
  unzip iterm.zip
  mv iTerm.app/ /Applications/
  rm iterm.zip
}

function setup_configs() {
  echo "Copying dotfiles to $HOME..."
  yes | cp -rf $DOTFILES/.[^.]* $HOME

  echo "Configuring iTerm..."
  defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string $DOTFILES
  defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
}

function install_packages() {
  echo "Installing Atom packages..."
  install_atom_packages "$DOTFILES/atom-package-list"

  echo "Installing Homebrew packages..."
  install_brew_packages

  echo "Installing Cask packages..."
  install_cask_packages
}

function already_installed() {
  echo "$1 is already installed."
}

function check_and_conditionally_install() {
  command -v pip >/dev/null 2>&1 && already_installed "Pip" || { echo >&2 "Installing pip..."; install_pip; }
  command -v atom >/dev/null 2>&1 && already_installed "Atom" || { echo >&2 "Installing & linking Atom..."; install_atom; }
  command -v brew >/dev/null 2>&1 && already_installed "Homebrew" || { echo >&2 "Installing Homebrew..."; install_homebrew; }

  install_packages
  setup_configs

  if [ -d $HOME/.oh-my-zsh ]; then
    already_installed "Oh My Zsh"
  else
    echo  "Installing Oh My Zsh"
    install_oh_my_zsh
  fi

  if [ -d /Applications/iTerm.app ]; then
    already_installed "iTerm"
  else
    install_iterm
  fi

  if ! $(grep -q $(which zsh) /etc/shells); then
    echo "Adding zsh to /etc/shells..."
    sudo bash -c 'echo $(which zsh) >> /etc/shells'
  fi

  if $(echo $0 | grep zsh); then
    chsh -s $(which zsh)
  fi

  setup_configs

  echo "You should be all set! Get hacking!"
}

check_and_conditionally_install
