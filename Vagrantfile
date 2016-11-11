## install, backup, restore
$mode = "install"

Vagrant.configure("2") do |config|

  config.vm.box = "debian/jessie64"

  config.vm.network :private_network,
    ip: "10.0.0.11",
    hostsupdater: "skip"

  config.vm.network :public_network,
    ip: "192.168.67.211",
    bridge: "en0: WLAN (AirPort)"

#   config.vm.network "forwarded_port", guest: 3306, host: 3306

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--name", "typo3box"]
    vb.customize ["modifyvm", :id, "--cpus", 2]
    vb.customize ["modifyvm", :id, "--memory", 4096]
    vb.customize ["modifyvm", :id, "--vram", 16]
  end
  
  config.vm.hostname = "local.typo3.org"
  config.hostsupdater.aliases = [
      "7x.local.typo3.org",
      "8x.local.typo3.org",
      "dev-master.local.typo3.org"
  ]

  if $mode=="install"
    config.vm.provision "shell", path: "scripts/lamp.sh"

    config.vm.provision "shell", path: "scripts/7x-host.sh"
    config.vm.provision "shell", path: "scripts/8x-host.sh"
    config.vm.provision "shell", path: "scripts/devmaster-host.sh"

  end
end