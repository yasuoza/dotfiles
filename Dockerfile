FROM ubuntu:bionic

ENV USER developer

# For Linuxbrew
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl file g++ git locales make uuid-runtime \
    && apt-get install -y --no-install-recommends sudo zsh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -f UTF-8 en_US.UTF-8 \
    && echo "${USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/${USER}

RUN useradd -m ${USER}
RUN chmod u+s /usr/sbin/useradd \
    && chmod u+s /usr/sbin/groupadd \
    && chmod u+s /usr/sbin/usermod

# Run as $USER
ENV HOME /home/${USER}
ENV SHELL /bin/zsh
USER ${USER}
WORKDIR ${HOME}

# Install linuxbrew
RUN env CI=1 sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
RUN chmod -R 777 /home/linuxbrew

# # Prepare dotfiles
ADD https://api.github.com/repos/yasuoza/dotfiles/git/refs/heads/master /tmp/dotfiles-version.json
RUN git clone --recursive --depth 1 https://github.com/yasuoza/dotfiles
RUN cd dotfiles \
    && /home/linuxbrew/.linuxbrew/bin/brew bundle --file=Brewfile.linux --verbose \
    && make zsh vim

COPY docker/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/zsh"]
