class { 'r10k':
  sources => {
    'main' => {
      'remote'  => 'https://github.com/zoojar/pe-controlrepo.git',
      'basedir' => "${::settings::confdir}/environments",
      'prefix'  => false,
    }
  }
}