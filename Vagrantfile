# -*- mode: ruby -*-
# vi: set ft=ruby :

$domain                  = "lab.local"
$master_hostname         = "puppet"
$master_ip               = "192.168.100.100"
$localwebserver          = "192.168.0.25"
$peinstaller_url         = "http://#{$localwebserver}/puppet-enterprise-2015.2.0-el-7-x86_64.tar.gz"
#$peinstaller_url        = "https://pm.puppetlabs.com/puppet-enterprise/3.8.1/puppet-enterprise-3.8.1-ubuntu-14.04-amd64.tar.gz"
$peanswers_url           = "http://#{$localwebserver}/puppet.lab.local.answers"
#$peanswers_url          = "https://raw.githubusercontent.com/zoojar/vagrantlab-puppet/master/puppet.master.answers"
$peinstaller_url_windows = "http://#{$localwebserver}/puppet-agent-1.2.2-x64.msi"
#$peinstaller_url_windows = "http://pm.puppetlabs.com/puppet-enterprise/3.8.0/puppet-enterprise-3.8.0-x64.msi"
$r10kyaml_url            = "https://raw.githubusercontent.com/zoojar/vagrantlab-puppet/master/r10k.yaml"

# Load the pe installer scripts...
load 'the-roosters' 

nodes = [
  { 
    :hostname        => $master_hostname, 
    :domain          => $domain,
    :ip              => $master_ip, 
    :box             => 'puppetlabs/centos-7.0-64-nocm', 
    :ram             => 8000,
    :cpus            => 4,
    :cpuexecutioncap => 90,
    :shell_script    => $install_puppet_master_centos7, 
    :shell_args      => [$peinstaller_url, $peanswers_url, $r10kyaml_url, "#{$master_hostname}.#{$domain}", $master_ip]  
  },
  { 
    :hostname        => "linuxnode-01",
    :domain          => $domain,
    :ip              => '192.168.100.10', 
    :box             => 'puppetlabs/ubuntu-14.04-64-nocm',
    :shell_script    => $install_puppet_agent_linux, 
    :shell_args      => ["#{$master_hostname}.#{$domain}", $master_ip] 
  },
  { 
    :hostname        => "windowsnode-01",
    :ip              => '192.168.100.11',
    :box             => 'opentable/win-2012r2-standard-amd64-nocm',
    :shell_script    => $install_puppet_agent_windows, 
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
