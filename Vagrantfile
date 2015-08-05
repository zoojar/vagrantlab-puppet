# -*- mode: ruby -*-
# vi: set ft=ruby :

$reposerver      = "192.168.0.25"
$domain          = "lab.local"
$master_hostname = "puppet"
$master_ip       = "192.168.100.100"
$peinstaller     = "puppet-enterprise-3.8.1-ubuntu-14.04-amd64"
$peanswers       = "master.puppetlabs.vm.answers"

$install_puppet_master = <<SCRIPT
reposerver="$1"
peinstaller="$2"
peanswers="$3"
apt-get install axel -y
axel -q http://$reposerver/$peinstaller.tar -o /tmp/$peinstaller.tar
axel -q http://$reposerver/$peanswers -o /tmp/$peanswers 
tar -xf /tmp/$peinstaller.tar -C /tmp
sudo /tmp/$peinstaller/puppet-enterprise-installer -a /tmp/$peanswers 
SCRIPT

$install_puppet_node = <<SCRIPT
master_fqdn="$1"
master_ip="$2"
sudo echo "$master_ip $master_fqdn" >> /etc/hosts
curl -k https://$master_fqdn:8140/packages/current/install.bash | sudo bash
puppet agent -t
SCRIPT


nodes = [
  { 
    :hostname        => $master_hostname, 
    :ip              => $master_ip, 
    :box             => 'ubuntu/trusty64', 
    :ram             => 6000,
    :cpus            => 4,
    :cpuexecutioncap => 90,
    :shell_script    => $install_puppet_master, 
    :shell_args      => [$reposerver, $peinstaller, $peanswers]  
  },
  { 
    :hostname        => "linuxnode-01", 
    :ip              => '192.168.100.10', :box => 'ubuntu/trusty64',
    :shell_script    => $install_puppet_node, 
    :shell_args      => ["#{$master_hostname}.#{$domain}", $master_ip] 
  },
]

Vagrant.configure("2") do |config|
  nodes.each do |node|
    config.vm.define node[:hostname] do |nodeconfig|
      nodeconfig.vm.box      = 'ubuntu/trusty64'
      nodeconfig.vm.hostname = "#{node[:hostname]}.#{$domain}"
      memory                 = node[:ram] ? node[:ram] : 2000 ; 
      cpus                   = node[:cpus] ? node[:cpus] : 2 ;
      cpuexecutioncap        = node[:cpuexecutioncap] ? node[:cpuexecutioncap] : 50 ;
      nodeconfig.vm.network :private_network, ip: node[:ip]
      nodeconfig.vm.provider :virtualbox do |vb|
        vb.customize [
          "modifyvm", :id,
          "--memory", memory.to_s,
          "--cpus", cpus.to_s,
          "--cpuexecutioncap", cpuexecutioncap.to_s,
        ]
      end
      nodeconfig.vm.provision :reload
      nodeconfig.vm.provision "shell" do | s |
        s.inline = node[:shell_script]
        s.args   = node[:shell_args]
      end
    end
  end
end
