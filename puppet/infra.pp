Exec { path => "/usr/bin:/usr/sbin:/bin:/sbin" }


stage { 'preinstall':
  before => Stage['main']
}
 
class apt_get_update {
  exec { 'apt-get -y update': }
}
 
class { 'apt_get_update':
  stage => preinstall
}

node default {

	class { 'consul':
		config_hash => {
			'datacenter'       => 'dc1',
			'data_dir'         => '/opt/consul',
			'ui_dir'           => '/opt/consul/ui',
			'client_addr'      => '0.0.0.0',
			'log_level'        => 'INFO',
			'node_name'        => $::hostname,
			'bind_addr'        => $::ipaddress_eth1,
			'bootstrap_expect' => 1,
			'server'           => true,
		}
	}

  class { '::mysql::server':
    root_password           => 'root',
    remove_default_accounts => true,
    #  override_options        => $override_options
  }



	::consul::service { 'mysql':
		port           => 3306,
	}

}
