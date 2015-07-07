# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
  config.vm.box = "trusty64"

  # consul =====================================================================
  config.vm.define "consul" do |consul|

    consul.vm.hostname = "consul.local"
    consul.vm.network "private_network", ip: "172.20.20.10"

    consul.vm.provision :puppet do |puppet|
      puppet.hiera_config_path = "hiera/hiera.yaml"
      puppet.manifests_path    = "puppet"
      puppet.module_path       = "puppet/modules"
      puppet.manifest_file     = "consul.pp"
    end
  end

  # vault0 =====================================================================
  config.vm.define "vault0" do |vault0|

    vault0.vm.hostname = "vault0.local"
    vault0.vm.network "private_network", ip: "172.20.20.11"

    vault0.vm.provision :puppet do |puppet|
      puppet.hiera_config_path = "hiera/hiera.yaml"
      puppet.manifests_path    = "puppet"
      puppet.module_path       = "puppet/modules"
      puppet.manifest_file     = "vault.pp"
    end
  end

  # vault1 =====================================================================
  config.vm.define "vault1" do |vault1|

    vault1.vm.hostname = "vault1.local"
    vault1.vm.network "private_network", ip: "172.20.20.12"

    vault1.vm.provision :puppet do |puppet|
      puppet.hiera_config_path = "hiera/hiera.yaml"
      puppet.manifests_path    = "puppet"
      puppet.module_path       = "puppet/modules"
      puppet.manifest_file     = "vault.pp"
    end
  end

  # mysql ======================================================================
  config.vm.define "mysql" do |mysql|

    mysql.vm.hostname = "mysql.local"
    mysql.vm.network "private_network", ip: "172.20.20.13"

    mysql.vm.provision :puppet do |puppet|
      puppet.hiera_config_path = "hiera/hiera.yaml"
      puppet.manifests_path    = "puppet"
      puppet.module_path       = "puppet/modules"
      puppet.manifest_file     = "mysql.pp"
    end
  end

  # todo0 ======================================================================
  config.vm.define "todo0" do |todo0|

    todo0.vm.hostname = "todo0.local"
    todo0.vm.network "private_network", ip: "172.20.20.14"

    todo0.vm.provision "shell", path: "set_user_id.sh", args: ENV['VAULT_USER_ID']
	todo0.vm.provision :puppet do |puppet|
      puppet.hiera_config_path = "hiera/hiera.yaml"
      puppet.manifests_path    = "puppet"
      puppet.module_path       = "puppet/modules"
      puppet.manifest_file     = "todo.pp"
    end
  end

  # todo1 ======================================================================
  config.vm.define "todo1" do |todo1|

    todo1.vm.hostname = "todo1.local"
    todo1.vm.network "private_network", ip: "172.20.20.15"

    todo1.vm.provision "shell", path: "set_user_id.sh", args: ENV['VAULT_USER_ID']
	todo1.vm.provision :puppet do |puppet|
      puppet.hiera_config_path = "hiera/hiera.yaml"
      puppet.manifests_path    = "puppet"
      puppet.module_path       = "puppet/modules"
      puppet.manifest_file     = "todo.pp"
    end
  end

  # end ========================================================================

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "512"]
  end

end


