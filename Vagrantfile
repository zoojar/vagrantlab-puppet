# -*- mode: ruby -*-
# vi: set ft=ruby :

$domain                  = "lab.local"
$master_hostname         = "puppet"
$master_ip               = "192.168.100.100"
$peinstaller_url         = "http://192.168.43.181/puppet-enterprise-3.8.1-ubuntu-14.04-amd64.tar.gz"
#$peinstaller_url        = "https://pm.puppetlabs.com/puppet-enterprise/3.8.1/puppet-enterprise-3.8.1-ubuntu-14.04-amd64.tar.gz"
$peanswers_url           = "http://192.168.43.181/puppet.master.answers"
#$peanswers_url          = "https://raw.githubusercontent.com/zoojar/vagrantlab-puppet/master/puppet.master.answers"
$peinstaller_url_windows = "http://192.168.43.181/puppet-enterprise-3.8.0-x64.msi"
#$peinstaller_url_windows = "http://pm.puppetlabs.com/puppet-enterprise/3.8.0/puppet-enterprise-3.8.0-x64.msi"
$initr10k_url            = "https://raw.githubusercontent.com/zoojar/vagrantlab-puppet/master/initr10k.pp"

$install_puppet_master = <<SCRIPT
peinstaller_url="$1"
peanswers_url="$2"
initr10k_url="$3"
apt-get install axel -y
axel -q $peinstaller_url -o /tmp/peinstaller.tar.gz
mkdir /tmp/peinstaller
tar -xf /tmp/peinstaller.tar.gz --strip-components=1 -C /tmp/peinstaller
curl -L $peanswers_url > /tmp/master.answers
sudo /tmp/peinstaller/puppet-enterprise-installer -a /tmp/master.answers
sudo puppet module install zack/r10k
curl -L $initr10k_url > /tmp/initr10k.pp
sudo puppet apply /tmp/initr10k.pp
SCRIPT

$install_puppet_node = <<SCRIPT
master_fqdn="$1"
master_ip="$2"
sudo echo "$master_ip $master_fqdn" >> /etc/hosts
curl -k https://$master_fqdn:8140/packages/current/install.bash | sudo bash
sudo puppet config set server $master_fqdn
sudo sh -c "puppet agent -t ; true" # supress non-zero exit code
SCRIPT

$install_puppet_node_windows = <<SCRIPT
$master_fqdn=$Args[0]
$master_ip=$Args[1]
$peinstaller_url_windows=$Args[2]
add-content "C:\\Windows\\System32\\drivers\\etc\\hosts" "$master_ip $master_fqdn"
wget $peinstaller_url_windows -outfile "c:\\windows\\temp\\puppet-enterprise-installer.msi"
Start-Process -FilePath msiexec -ArgumentList /i, "C:\\Windows\\Temp\\puppet-enterprise-installer.msi", /quiet -wait 
$env:Path += ";C:\\Program Files\\Puppet Labs\\Puppet Enterprise\\bin"
puppet config set server $master_fqdn
start-process puppet.bat "agent -t" 
SCRIPT

nodes = [
  { 
    :hostname        => $master_hostname, 
    :domain          => $domain,
    :ip              => $master_ip, 
    :box             => 'ubuntu/trusty64', 
    :ram             => 6000,
    :cpus            => 4,
    :cpuexecutioncap => 90,
    :shell_script    => $install_puppet_master, 
    :shell_args      => [$peinstaller_url, $peanswers_url, $initr10k_url]  
  },
  { 
    :hostname        => "linuxnode-01",
    :domain          => $domain,
    :ip              => '192.168.100.10', 
    :box             => 'ubuntu/trusty64',
    :shell_script    => $install_puppet_node, 
    :shell_args      => ["#{$master_hostname}.#{$domain}", $master_ip] 
  },
  { 
    :hostname        => "windowsnode-01",
    :ip              => '192.168.100.11',
    :box             => 'opentable/win-2012r2-standard-amd64-nocm',
    :shell_script    => $install_puppet_node_windows, 
    :shell_args      => ["#{$master_hostname}.#{$domain}", $master_ip, $peinstaller_url_windows] 
  },
]

Vagrant.configure("2") do |config|
  nodes.each do |node|
    config.vm.define node[:hostname] do |nodeconfig|
      nodeconfig.vm.box      = node[:box]
      nodeconfig.vm.hostname = node[:domain] ? "#{node[:hostname]}.#{node[:domain]}" : "#{node[:hostname]}" ;
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
