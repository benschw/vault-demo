Exec { path => '/usr/bin:/usr/sbin:/bin:/sbin' }


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
  }

  ::consul::service { 'mysql':
    port   => 3306,
    checks => [{
      script   => 'pgrep mysql > /dev/null || exit 2',
      interval => '5s'
    }],
  }

  class { '::mysql::server':
    restart                 => true,
    root_password           => 'root',
    remove_default_accounts => true,
    override_options        => {
      'mysqld' => {
        'bind_address' => '0.0.0.0',
      },
    },
  }
  mysql_user { 'vaultadmin@%':
    ensure        => 'present',
    password_hash => mysql_password('vault');
  }
  mysql_grant { 'vaultadmin@%/*.*':
    ensure     => 'present',
    options    => ['GRANT'],
    privileges => ['ALL'],
    table      => '*.*',
    user       => 'vaultadmin@%',
  }

  mysql::db { 'Todo':
    user     => 'vaultadmin',
    password => 'vault',
    host     => 'localhost',
  }



}
