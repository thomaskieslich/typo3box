## install, backup, restore
$mode = "install"

Vagrant.configure("2") do |config|

  config.vm.box = "debian/jessie64"

  config.vm.network :private_network,
    ip: "10.0.0.11"
    #,hostsupdater: "skip"

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
  
  config.vm.hostname = "t3b.example.org"
  config.hostsupdater.aliases = [
      "7x.t3b.example.org",
      "8x.t3b.example.org",
      "dev-master.t3b.example.org",
      "phpmyadmin.t3b.example.org",
      "webgrind.t3b.example.org"
  ]

#     config.vm.synced_folder "~/Projects/src...", "/var/www/target...",
#       create: true,
#       owner: "www-data", group: "www-data"

  if $mode=="install"
    config.vm.provision "shell", path: "scripts/lamp.sh"

    config.vm.provision "shell", path: "scripts/7x-host.sh"
    config.vm.provision "shell", path: "scripts/8x-host.sh"
    config.vm.provision "shell", path: "scripts/devmaster-host.sh"

    config.vm.provision "shell", path: "scripts/phpmyadmin.sh"
    config.vm.provision "shell", path: "scripts/xdebug.sh"

  end
end