class vault (
    $download_url = 'https://dl.bintray.com/mitchellh/vault/vault_0.1.2_linux_amd64.zip',
    $bin_dir = '/usr/bin',
    $config_dir = '/etc/vault',
    $consul_addr = $::ipaddress_eth1,
    $consul_port = 8500,
    $vault_addr  = $::ipaddress_eth1,
    $vault_port  = 8200
) {
  ensure_packages(['unzip'])
  staging::file { 'vault.zip':
    source => $download_url
  } ->
  staging::extract { 'vault.zip':
    target  => $bin_dir,
    creates => "${bin_dir}/vault",
  } ->
  file { "${bin_dir}/vault":
    owner => 'root',
    group => 0,
    mode  => '0555',
  } ->
  file { '/etc/init.d/vault':
    mode    => '0555',
    owner   => 'root',
    group   => 'root',
    content => template('/vagrant/puppet/templates/vault.init.erb'),
  } ->
  file { $config_dir:
    ensure => 'directory',
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  } ->
  file { "${config_dir}/config.hcl":
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('/vagrant/puppet/templates/vault-config.hcl.erb'),
  } ->
  service { 'vault':
    ensure => 'running',
  }

}
