# -*- mode: ruby -*-
# vi: set ft=ruby :
#

$domain                   = "lab.local"
$master_hostname          = "puppet"
$master_ip                = "192.168.100.100"
$web_proxy_ip_port        = "" # "http://192.168.1.181:3128"
$peinstaller_url         = "https://pm.puppetlabs.com/puppet-enterprise/2015.2.0/puppet-enterprise-2015.2.0-el-7-x86_64.tar.gz"
$peanswers_url            = "https://raw.githubusercontent.com/zoojar/vagrantlab-puppet/master/puppet.lab.local.answers"
$peinstaller_url_windows = "http://pm.puppetlabs.com/puppet-agent/2015.2.0/1.2.2/repos/windows/puppet-agent-1.2.2-x64.msi"
$r10kyaml_url             = "https://raw.githubusercontent.com/zoojar/vagrantlab-puppet/master/r10k.yaml"
$eyaml_keys_url           = "https://raw.githubusercontent.com/zoojar/vagrantlab-puppet/master/eyaml"
$autosign_these_nodes     = "*"
$dns_alt_names            = "puppet.lab.local,lei-compiler-01.lab.local,lei-compiler-02.lab.local"

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
    :shell_args      => [$peinstaller_url, $peanswers_url, $r10kyaml_url, $master_hostname, $domain, $master_ip, "#{$web_proxy_ip_port}", $autosign_these_nodes, $eyaml_keys_url]  
  },
  { 
    :hostname        => 'gitserver-01',
    :domain          => $domain,
    :ip              => '192.168.100.21', 
    :box             => 'puppetlabs/centos-7.0-64-nocm', 
    :shell_script    => $install_puppet_agent_linux, 
    :shell_args      => [$master_ip, $master_hostname, $domain,] 
  },
  { 
    :hostname        => 'test-web-01',
    :domain          => $domain,
    :ip              => '192.168.100.10', 
    :box             => 'puppetlabs/centos-7.0-64-nocm', 
    :shell_script    => $install_puppet_agent_linux, 
    :shell_args      => [$master_ip, $master_hostname, $domain,] 
  },
  { 
    :hostname        => 'windowsnode-01',
    :ip              => '192.168.100.11',
    :box             => 'opentable/win-2012r2-standard-amd64-nocm',
    :shell_script    => $install_puppet_agent_windows, 
    :shell_args      => [$master_ip, $master_hostname, $domain, $peinstaller_url_windows,$web_proxy_ip_port] 
  },
  { 
    :hostname        => 'lei-balancer-01', 
    :domain          => $domain,
    :ip              => '192.168.100.110', 
    :box             => 'puppetlabs/centos-7.0-64-nocm', 
    :shell_script    => $install_puppet_agent_linux, 
    :shell_args      => [$master_ip, $master_hostname, $domain,] 
  },
  { 
    :hostname        => 'lei-compiler-01', 
    :domain          => $domain,
    :ip              => '192.168.100.111', 
    :box             => 'puppetlabs/centos-7.0-64-nocm', 
    :shell_script    => $install_puppet_compiler, 
    :shell_args      => [$master_ip, $master_hostname, $domain, $dns_alt_names] 
  },
  { 
    :hostname        => 'lei-compiler-02', 
    :domain          => $domain,
    :ip              => '192.168.100.112', 
    :box             => 'puppetlabs/centos-7.0-64-nocm', 
    :shell_script    => $install_puppet_compiler, 
    :shell_args      => [$master_ip, $master_hostname, $domain, $dns_alt_names] 
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
