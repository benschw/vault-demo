Exec { path => '/usr/bin:/usr/sbin:/bin:/sbin' }

import 'classes/*'

node default {

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
  class { 'vault':
  }

  ::consul::service { 'vault':
    port => 8200,
  }

}
