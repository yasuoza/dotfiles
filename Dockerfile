# syntax=docker/dockerfile:1.3-labs

FROM ubuntu:focal

ENV USER developer

# For Linuxbrew
RUN <<EOM
  apt update
  apt install -y --no-install-recommends ca-certificates curl file build-essential g++ git locales make uuid-runtime
  apt install -y --no-install-recommends sudo zsh
  apt install -y --no-install-recommends gosu
  apt install -y --no-install-recommends libssl-dev zlib1g-dev
  apt clean
  rm -rf /var/lib/apt/lists/*

  ln -s /usr/include/locale.h /usr/include/xlocale.h
  localedef -i en_US -f UTF-8 en_US.UTF-8
  useradd -m ${USER}
  echo "${USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/${USER}
EOM

# Run as $USER
ENV HOME /home/${USER}
ENV SHELL /bin/zsh
USER ${USER}
WORKDIR ${HOME}

# Install linuxbrew
ADD https://api.github.com/repos/Homebrew/brew/git/refs/heads/master /tmp/homebrew-version.json
RUN <<EOM
  git clone --depth 1 https://github.com/Homebrew/brew ${HOME}/.linuxbrew/Homebrew
  mkdir ${HOME}/.linuxbrew/bin
  ln -s ${HOME}/.linuxbrew/Homebrew/bin/brew ${HOME}/.linuxbrew/bin
EOM

# Prepare dotfiles
ADD https://api.github.com/repos/yasuoza/dotfiles/git/refs/heads/main /tmp/dotfiles-version.json
RUN <<EOM
  git clone --depth 1 https://github.com/yasuoza/dotfiles ${HOME}/dotfiles
  cd ${HOME}/dotfiles
  eval $(${HOME}/.linuxbrew/bin/brew shellenv)
  brew bundle --file=Brewfile.linux --verbose
  brew cleanup
  sudo rm -rf ${HOME}/.cache ${HOME}/.cpan
  make zsh vim misc
  $(brew --prefix)/bin/nodebrew setup_dirs
  touch ${HOME}/.z
EOM

USER root
COPY docker/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]
