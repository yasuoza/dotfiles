FROM ubuntu:bionic

ENV USER developer

# For Linuxbrew
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl file g++ git locales make uuid-runtime \
    && apt-get install -y --no-install-recommends sudo zsh \
    && apt-get install -y --no-install-recommends gosu \
    && apt-get install -y --no-install-recommends libssl-dev zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -f UTF-8 en_US.UTF-8 \
    && useradd -m ${USER} \
    && echo "${USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/${USER}

# Run as $USER
ENV HOME /home/${USER}
ENV SHELL /bin/zsh
USER ${USER}
WORKDIR ${HOME}

# Install linuxbrew
RUN env CI=1 sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"

# Prepare dotfiles
ADD https://api.github.com/repos/yasuoza/dotfiles/git/refs/heads/master /tmp/dotfiles-version.json
RUN git clone --depth 1 https://github.com/yasuoza/dotfiles ${HOME}/dotfiles \
    && cd ${HOME}/dotfiles \
    && /home/linuxbrew/.linuxbrew/bin/brew bundle --file=Brewfile.linux --verbose \
    && /home/linuxbrew/.linuxbrew/bin/brew cleanup \
    && test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv) \
    && eval $($(brew --prefix)/bin/brew shellenv) \
    && sudo rm -rf ${HOME}/.cache ${HOME}/.cpan \
    && make zsh vim misc \
    && $(brew --prefix)/bin/nodebrew setup_dirs \
    && touch ${HOME}/.z

USER root
COPY docker/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/zsh"]
