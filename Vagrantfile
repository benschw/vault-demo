# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
  config.vm.box = "trusty64"

  # consul0 ====================================================================
  config.vm.define "infra" do |infra|

    infra.vm.hostname = "infra.local"
    infra.vm.network "private_network", ip: "172.20.20.10"

    infra.vm.provision :puppet do |puppet|
      puppet.hiera_config_path = "hiera/hiera.yaml"
      puppet.manifests_path    = "puppet"
      puppet.module_path       = "puppet/modules"
      puppet.manifest_file     = "infra.pp"
    end
  end
  # end ========================================================================

  # demo =======================================================================
  config.vm.define "demo" do |demo|

    demo.vm.hostname = "demo.local"
    demo.vm.network "private_network", ip: "172.20.20.20"

    demo.vm.provision :puppet do |puppet|
      puppet.hiera_config_path = "hiera/hiera.yaml"
      puppet.manifests_path    = "puppet"
      puppet.module_path       = "puppet/modules"
      puppet.manifest_file     = "demo.pp"
    end
  end
  # end ========================================================================

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "512"]
  end

end


