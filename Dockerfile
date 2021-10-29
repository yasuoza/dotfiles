# syntax=docker/dockerfile:1.3-labs

FROM linuxbrew/brew

ENV USER developer

RUN <<EOM
  apt update
  apt install -y sudo zsh gosu

  useradd -m ${USER} -s /bin/zsh
  usermod -aG linuxbrew ${USER}
  echo "${USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/${USER}
EOM

# Run as $USER
ENV HOME /home/${USER}
ENV SHELL /bin/zsh
USER ${USER}
WORKDIR ${HOME}

# Prepare dotfiles
ADD . ${HOME}/dotfiles
RUN <<EOM
  cd ${HOME}/dotfiles
  brew bundle --file=Brewfile.linux --verbose
  brew cleanup
  make zsh vim misc
  $(brew --prefix)/bin/nodebrew setup_dirs
  touch ${HOME}/.z
EOM

USER root
COPY docker/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]
