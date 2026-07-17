FROM ubuntu:22.04 as installer

SHELL [ "/bin/bash", "-c" ]
WORKDIR /root/dotfiles

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ="Asia/Tokyo"

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive TZ=Asia/Tokyo apt-get install -y tzdata && \
  ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
  dpkg-reconfigure --frontend noninteractive tzdata && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN apt update && apt -y upgrade && \
  apt install -y build-essential libffi-dev libssl-dev zlib1g-dev liblzma-dev libbz2-dev \
  libreadline-dev libsqlite3-dev libopencv-dev tk-dev libz-dev git curl zsh


FROM installer as brew_installer
# Set up brew
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
RUN echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >>~/.zshrc && \
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >>~/.bashrc && \
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && \
  source ~/.bashrc

COPY Brewfile /root/dotfiles/Brewfile
RUN brew update -f && brew upgrade -y && brew bundle install

FROM brew_installer as package_builder

COPY configs/ /root/dotfiles/configs/

RUN ~/.config/

RUN cd ~ && \
  git clone https://github.com/dim-an/cod.git && \
  cd cod && \
  go build

RUN pipx install sqlit-tui

# starship
RUN mkdir -p ~/.config && \
  cp ~/dotfiles/configs/starship.toml ~/.config/starship.toml

RUN mkdir -p ~/.config/yazi && \
  ln -s ~/dotfiles/configs/yazi/yazi.toml ~/.config/yazi/yazi.toml && \
  ln -s ~/dotfiles/configs/yazi/theme.toml ~/.config/yazi/theme.toml

FROM package_builder as tmux_builder

COPY .tmux.conf ~/dotfiles/.tmux.conf
# Install tmux plugin manager
RUN ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
RUN  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && \
  ~/.tmux/plugins/tpm/bin/install_plugins

FROM tmux_builder as nvim_builder

COPY nvim/ ~/dotfiles/nvim/
RUN ln -s ~/dotfiles/nvim ~/.config/nvim
RUN nvim --headless "+Lazy! sync" + qa && \
  nvim --headless "+TSUpdateSync" +qa & \
  nvim --headless "+MasonInstall lua-language-server rust-analyser pyright" +qa && \
  nvim --headless "+MasonUpdate" +qa

FROM nvim_builder

COPY .zshrc ~/dotfiles/.zshrc
RUN echo 'source ~/dotfiles/.zshrc' >>~/.zshrc

