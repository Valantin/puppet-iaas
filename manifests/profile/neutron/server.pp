class iaas::profile::neutron::server (
  $public_ipaddress = hiera('iaas::public_ipaddress'),
  $admin_ipaddress = hiera('iaas::admin_ipaddress', undef),

  $neutron_password = hiera('iaas::profile::neutron::password', undef),
  $nova_password = hiera('iaas::profile::nova::controller::password', undef),

  $region = hiera('iaas::region', undef),
  $endpoint = hiera('iaas::role::endpoint::main_address', undef),
) {
  include iaas::resources::connectors
  iaas::resources::database { 'neutron': }

  include iaas::profile::neutron::common

  class { '::neutron::server':
    auth_host => $endpoint,
    auth_password => $neutron_password,
    database_connection => $iaas::resources::connectors::neutron,
    enabled => true,
    sync_db => true,
    mysql_module => '2.3',
    database_idle_timeout => 50, # Important to avoid facing "MySQL server has gone away" while using HAProxy+Galera. Should be < HAProxy server timeout (default: 60s)
    l3_ha => true,
  }

  class { '::neutron::keystone::auth':
    password => $neutron_password,
    public_address => $public_ipaddress,
    admin_address => $admin_ipaddress,
    internal_address => $admin_ipaddress,
    region => $region,
  }

  class { '::neutron::server::notifications':
    nova_url => "http://${endpoint}:8774/v2/",
    nova_admin_auth_url => "http://${endpoint}:35357/v2.0/",
    nova_admin_password => $nova_password,
    nova_region_name    => $region,
  }

  @@haproxy::balancermember { "neutron_api_${::fqdn}":
      listening_service => 'neutron_api_cluster',
      server_names => $::hostname,
      ipaddresses => $public_ipaddress,
      ports => '9696',
      options => 'check inter 2000 rise 2 fall 5',
    }
}
