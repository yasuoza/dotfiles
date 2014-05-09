# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
MEMORY                  = ENV['RAILS_VAGRANT_MEMORY'] || '1024'
CORES                   = ENV['RAILS_VAGRANT_CORES']  || '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.hostname = 'base.box'

  config.vm.box = "chef/ubuntu-14.04"

  config.vm.provision :shell, inline: <<-SHELL
    su vagrant -c "/vagrant/scripts/bootstrap"
  SHELL

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm",  :id,  "--memory",  MEMORY.to_i]
    v.customize ["modifyvm",  :id,  "--cpus",    CORES.to_i]
  end
end
