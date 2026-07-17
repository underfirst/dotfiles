########################################
# Install OS Specific common packages
########################################
if [ "$(uname)" = 'Darwin' ]; then
  echo "Setup MacOS specific packages."

  echo "Finish MacOS specific setup."
elif [ "$(uname)" = 'Linux' ]; then
  echo "Setup Linux specific packages."
  if [ "$(command -v apt)" ]; then
    echo "Start apt based setup."
    apt -y update
    export DEBIAN_FRONTEND=noninteractive
    export TZ="Asia/Tokyo"
    apt install -y tzdata
    ln -fs /usr/share/zoneinfo/$TZ/ /etc/localtime
    dpkg-reconfigure --frontend noninteractive tzdata

    apt -y upgrade

    apt install -y build-essential libffi-dev libssl-dev zlib1g-dev liblzma-dev libbz2-dev \
      libreadline-dev libsqlite3-dev libopencv-dev tk-dev libz-dev git curl zsh
  fi
fi

########################################
# Install brew package manager
########################################
echo "Install brew."
if [ ! "$(command -v brew)" ]; then
  export NONINTERACTIVE=1
  echo "Homebrew is not installed, Installing homebrew."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ "$(uname)" = "Darwin" ]; then
    echo 'export PATH=$PATH:/opt/homebrew/bin' >>~/.zshrc
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>~/.zshrc
    source ~/.zshrc
  elif [ "$(uname)" = "Linux" ]; then
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >>~/.zshrc
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >>~/.bashrc
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    source ~/.bashrc
  fi
fi

########################################
# Install common packages
########################################
echo "Install common packages with brew."
brew update
brew upgrade
brew bundle install

source ~/.zshrc

pipx install sqlit-tui

# Install cod
cd ~
git clone https://github.com/dim-an/cod.git
cd cod
go build
cd ~

# Install starship
if [ ! -e ~/.config/starship.toml ]; then
  mkdir -p ~/.config
  cp ~/dotfiles/configs/starship.toml ~/.config/starship.toml
fi
# Install tmux plugin manager
if [ ! -e ~/.tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  ~/.tmux/plugins/tpm/bin/install_plugins
fi

# nvim headless setup
nvim --headless "+Lazy! sync" + qa
nvim --headless "+TSUpdateSync" +qa
nvim --headless "+MasonInstall lua-language-server rust-analyser pyright" +qa
nvim --headless "+MasonUpdate" +qa

########################################
# common dotfile settings
########################################
echo "Link dotfiles."
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/.vimrc ~/.vimrc
ln -s ~/dotfiles/vim ~/.vim
mkdir -p ~/.config/yazi
ln -s ~/dotfiles/configs/yazi/yazi.toml ~/.config/yazi/yazi.toml
ln -s ~/dotfiles/configs/yazi/theme.toml ~/.config/yazi/theme.toml
mkdir -p ~/.config
ln -s ~/dotfiles/nvim ~/.config/nvim
echo 'source ~/dotfiles/.zshrc' >>~/.zshrc
