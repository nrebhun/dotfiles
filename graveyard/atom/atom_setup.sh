
atom_downloads_url="https://github.com/atom/atom/releases/download"

function install_atom() {
  if [ ! -d $APP_DIR/Atom.app ]; then
    echo "Installing Atom..."
    echo "Discovering latest non-beta Atom tag..."
    LATEST_ATOM_TAG=$(git ls-remote --tags --sort -version:refname git@github.com:atom/atom | grep -Ev ".*-beta.*" | head -1 | sed -E "s/.*tags\///g")
    LATEST_ATOM_DOWNLOAD="${atom_downloads_url}/${LATEST_ATOM_TAG}/atom-mac.zip"

    echo "Downloading Atom ${LATEST_ATOM_TAG} from '${LATEST_ATOM_DOWNLOAD}'..."
    curl -OL $LATEST_ATOM_DOWNLOAD

    echo "Unzipping Atom..."
    unzip -q atom-mac.zip

    echo "Moving Atom..."
    mv Atom.app/ $APP_DIR/

    echo "Cleaning up..."
    rm atom-mac.zip
  else
    echo "It looks like Atom is already installed."
  fi
  echo "Done."
}

function install_atom_cli_tools() {
  echo "Linking Atom CLI Tools..."
  ATOM_RES_DIR=$APP_DIR/Atom.app/Contents/Resources/app

  if [[ ! -z $(which apm) ]]; then
    echo "apm cli already symlinked."
  else
    sudo ln -s $ATOM_RES_DIR/apm/node_modules/.bin/apm $MISC_BIN_LOC/apm
  fi

  if [[ ! -z $(which atom) ]]; then
    echo "atom cli already symlinked."
  else
    sudo ln -s $ATOM_RES_DIR/atom.sh $MISC_BIN_LOC/atom
  fi

  echo "Done"
}

function install_atom_packages() {
  echo "Installing Atom packages..."
  apm install --packages-file $1
  echo "Done"
}

function install_packages() {
  install_atom_packages "$DOTFILES_DIR/atom-package-list"
}

# Note: Most likely *nix compatible. This may move
function configure_atom() {
    echo "Configuring Atom preferences..."
    cp $DOTFILES_DIR/config.cson ~/.atom/config.cson
    echo "Finished configuring Atom preferences!"
}

function check_and_conditionally_install() {

  # Check for Atom.app
  if [ -d $APP_DIR/Atom.app ]; then
    already_installed "Atom";
  else
    echo "Installing Atom...";
    install_atom;
  fi

  # Check for Atom's CLI utils
  command -v atom >/dev/null 2>&1 && \
    command -v apm >/dev/null 2>&1 && \
    already_installed "Atom CLI Tools" || \
    { echo >&2 "Installing Atom CLI Tools..."; install_atom_cli_tools; }
}