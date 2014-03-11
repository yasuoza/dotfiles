# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
MEMORY                  = ENV['RAILS_VAGRANT_MEMORY'] || '1024'
CORES                   = ENV['RAILS_VAGRANT_CORES']  || '2'
RUBY_VER                = '2.1.0'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.hostname = 'base.box'

  config.vm.box = "chef/ubuntu-13.10"

  config.vm.provision :shell, inline: <<-SHELL
    sudo apt-get update
    sudo apt-get install -y python-software-properties python g++ make
    sudo add-apt-repository -y ppa:git-core/ppa
    sudo add-apt-repository -y ppa:chris-lea/node.js
    sudo apt-get update
    sudo apt-get install -y git language-pack-en zsh nodejs

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

    su vagrant -c "git clone --recursive https://github.com/yasuoza/dotfiles.git ~/dotfiles && \
    cd ~/dotfiles && make install"                                                          && \
    sudo chsh -s $(which zsh) vagrant

    sudo apt-get install -y --force-yes zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt-dev
    su vagrant -c "git clone https://github.com/sstephenson/rbenv.git ~/.rbenv                                     && \
                   git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build             && \
                   git clone https://github.com/sstephenson/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash && \
                   ~/.rbenv/bin/rbenv install #{RUBY_VER}                                                          && \
                   ~/.rbenv/bin/rbenv global #{RUBY_VER}"
  SHELL

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm",  :id,  "--memory",  MEMORY.to_i]
    v.customize ["modifyvm",  :id,  "--cpus",  CORES.to_i]
  end
end
