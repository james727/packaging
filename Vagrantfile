# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.synced_folder "salt", "/srv/salt/"

  config.vm.define "bosun" do |bosun|
    bosun.vm.hostname = "bosun"
    bosun.vm.provision :salt do |salt|
      salt.masterless = true
      salt.run_highstate = true
      salt.colorize = true
      salt.verbose = true
      salt.log_level = "error"
    end
  end

  config.vm.define "tester" do |tester|
  end
end
