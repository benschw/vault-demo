class todo (
    $download_url = 'https://drone.io/github.com/benschw/vault-todo/files/build/todo.zip',
    $bin_dir = '/usr/bin',
    $config_dir = '/etc/vault',
    $app_id = '',
) {
  ensure_packages(['unzip'])
  staging::file { 'todo.zip':
    source => $download_url
  } ->
  staging::extract { 'todo.zip':
    target  => $bin_dir,
    creates => "${bin_dir}/todo",
  } ->
  file { "${bin_dir}/todo":
    owner => 'root',
    group => 0,
    mode  => '0555',
  } ->
  file { '/etc/init.d/todo':
    mode    => '0555',
    owner   => 'root',
    group   => 'root',
    content => template('/vagrant/puppet/templates/todo.init.erb'),
  } ->
  file { $config_dir:
    ensure => 'directory',
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  } ->
  file { "${config_dir}/app_id":
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => "export VAULT_APP_ID=${app_id}"
  } ->
  service { 'todo':
    ensure => 'running',
  }

}

