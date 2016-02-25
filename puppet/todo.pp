Exec { path => '/usr/bin:/usr/sbin:/bin:/sbin' }

# fix dnsmasq, which looks for /bin/test
file { '/bin/test':
  ensure => 'link',
  target => '/usr/bin/test',
}

stage { 'preinstall':
  before => Stage['main']
}

class apt_get_update {
  exec { 'apt-get -y update': }
}

class { 'apt_get_update':
  stage => preinstall
}

import 'classes/*'

node default {
  include apt

  package { 'unzip': }
  ->
  class { 'consul':
    config_hash => {
      'datacenter'  => 'dc1',
      'data_dir'    => '/opt/consul',
      'client_addr' => '0.0.0.0',
      'log_level'   => 'INFO',
      'node_name'   => $::hostname,
      'bind_addr'   => $::ipaddress_eth1,
      'server'      => false,
      'retry_join'  => [hiera('join_addr')],
    }
  } ->
  class { 'dnsmasq':
  } ->
  class { 'todo':
  }

  ::consul::service { 'todo':
    port   => 8080,
    checks => [{
      http     => 'http://localhost:8080/health',
      interval => '5s'
    }],
  }

  dnsmasq::dnsserver { 'forward-zone-consul':
    domain => 'consul',
    ip     => '127.0.0.1',
    port   => '8600',
  }
}
