# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
MEMORY                  = ENV['RAILS_VAGRANT_MEMORY'] || '1024'
CORES                   = ENV['RAILS_VAGRANT_CORES']  || '2'
RUBY_VER                = '2.1.0'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.hostname = 'base.box'

  config.vm.box      = 'raring64'
  config.vm.box_url  = 'http://cloud-images.ubuntu.com/vagrant/raring/current/raring-server-cloudimg-amd64-vagrant-disk1.box'

  config.vm.network 'private_network', ip: '192.168.50.4'

  config.vm.provision :shell, inline: <<-SHELL
  sudo aptitude update
  sudo aptitude install -y git language-pack-en zsh

  cd /tmp && git clone https://github.com/vim-jp/vim.git && cd vim
  sudo apt-get install -y build-essential gettext libncurses5-dev luajit lua5.2 liblua5.2-dev python-dev python3-dev ruby-dev libperl-dev tcl-dev
  ./configure            \
  --with-features=huge   \
  --enable-multibyte     \
  --enable-rubyinterp    \
  --enable-pythoninterp  \
  --enable-python3interp \
  --enable-luainterp     \
  --with-lua-prefix=/usr \
  --enable-perlinterp    \
  --enable-tclinterp     \
  --enable-cscope        \
  --enable-fontset
  make
  sudo make install

  su vagrant -c "git clone https://github.com/yasuoza/dotfiles.git ~/dotfiles && \
  cd ~/dotfiles && ./setup.sh                                                 && \
  cp -r .vim ~/ && cd ~/.vim && mkdir bundle && cd bundle                     && \
  git clone https://github.com/Shougo/neobundle.vim.git                       && \
  git clone https://github.com/Shougo/vimproc.git                             && \
  cd vimproc && make -f make_unix.mak                                         && \
  ~/.vim/bundle/neobundle.vim/bin/neoinstall"
  sudo chsh -s $(which zsh) vagrant

  sudo apt-get install -y --force-yes zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt-dev
  su vagrant -c "git clone https://github.com/sstephenson/rbenv.git ~/.rbenv                         && \
                 git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build && \
                 ~/.rbenv/bin/rbenv install #{RUBY_VER}                                              && \
                 ~/.rbenv/bin/rbenv global #{RUBY_VER}"
  SHELL

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm",  :id,  "--memory",  MEMORY.to_i]
    v.customize ["modifyvm",  :id,  "--cpus",  CORES.to_i]
  end
end
