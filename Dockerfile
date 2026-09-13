FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04 as installer

SHELL [ "/bin/bash", "-c" ]
WORKDIR /root/dotfiles

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ="Asia/Tokyo"

RUN chmod 1777 /tmp
RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive TZ=Asia/Tokyo apt-get install -y tzdata && \
  ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
  dpkg-reconfigure --frontend noninteractive tzdata && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN apt update && apt -y upgrade && \
  apt install -y build-essential gcc g++ make cmake libffi-dev libssl-dev zlib1g-dev liblzma-dev libbz2-dev \
  libreadline-dev libsqlite3-dev libopencv-dev tk-dev libz-dev git curl zsh unzip \
  ffmpeg 7zip jq poppler-utils fd-find ripgrep fzf zoxide imagemagick

FROM installer as brew_installer
# Set up brew


COPY Brewfile /root/dotfiles/Brewfile

RUN curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh > install.sh && \
  chmod 755 install.sh && \
  touch /.dockerenv && \
  ./install.sh && \
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >>~/.zshrc && \
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"' >>~/.bashrc && \
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)" && \
  brew update -f && brew upgrade -y && brew bundle install --force --jobs 4

FROM brew_installer as package_builder

ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"
COPY configs/ /root/dotfiles/configs/
COPY templates/ /root/dotfiles/templates/
RUN mkdir -p ~/.config && \
  ln -s /root/dotfiles/configs/mise ~/.config/mise

ENV PATH=$PATH:/home/linuxbrew/.linuxbrew/bin
RUN cd ~ && \
  git clone https://github.com/dim-an/cod.git && \
  cd cod && \
  go build

RUN pipx install sqlit-tui

# starship
RUN mkdir -p ~/.config && \
  cp ~/dotfiles/configs/starship.toml ~/.config/starship.toml

RUN mkdir -p ~/.config/yazi && \
  git clone https://github.com/sxyazi/yazi.git ~/.config/yazi/yazi && \
  git clone https://github.com/yazi-rs/flavors.git ~/.config/yazi/flavors && \
  ln -s ~/dotfiles/configs/yazi/flavors/ ~/.config/yazi/flavors/ && \
  ln -s /root/dotfiles/configs/yazi/init.lua ~/.config/yazi/init.lua && \
  ln -s /root/dotfiles/configs/yazi/keymap.toml ~/.config/yazi/keymap.toml && \
  ln -s /root/dotfiles/configs/yazi/package.toml ~/.config/yazi/package.toml && \
  ln -s /root/dotfiles/configs/yazi/theme.toml ~/.config/yazi/theme.toml && \
  ln -s /root/dotfiles/configs/yazi/yazi.toml ~/.config/yazi/yazi.toml && \
  ya pkg install

FROM package_builder as tmux_builder

COPY .tmux.conf /root/dotfiles/.tmux.conf
# Install tmux plugin manager
RUN ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
RUN  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && \
  ~/.tmux/plugins/tpm/bin/install_plugins

FROM tmux_builder as nvim_builder

COPY nvim/ /root/dotfiles/nvim/
RUN ln -s ~/dotfiles/nvim ~/.config/nvim
RUN nvim --headless "+Lazy! sync" +qa && \
  nvim --headless "+TSUpdate" +qa & \
  nvim --headless "+MasonInstall lua-language-server pyright clangd cmakelang cmakelint docker-compose-language-service dockerfile-language-server json-lsp markdownlint-cli2 marksman ruff shfmt tree-sitter-cli yaml-language-server" +qa && \
  nvim --headless "+MasonUpdate" +qa

FROM nvim_builder

COPY .zshrc /root/dotfiles/.zshrc
RUN echo 'source ~/dotfiles/.zshrc' >>~/.zshrc
RUN git config --global merge.tool ec && \
  git config --global pull.rebase true && \
  git config --global rerere.enabled true && \
  git config --global fetch.prune true && \
  git config --global rebase.autoStash true && \
  git config --global core.editor "nvim"

RUN zsh -ic "exit"
WORKDIR /app
