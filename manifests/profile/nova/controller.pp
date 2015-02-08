class iaas::profile::nova::controller (
  $password = undef,
  $public_ipaddress = undef,
  $admin_ipaddress = undef,

  $neutron_secret = hiera('iaas::profile::neutron::secret', undef),
  $neutron_password = hiera('iaas::profile::neutron::password', undef),

  $region = hiera('iaas::region', undef),
  $endpoint = hiera('iaas::role::endpoint::main_address', undef),
  $rabbitmq_user = hiera('iaas::profile::rabbitmq::user', undef),
  $rabbitmq_password = hiera('iaas::profile::rabbitmq::password', undef),
) {
  include iaas::resources::connectors
  iaas::resources::database { 'nova': }

  class { '::nova::keystone::auth':
    password => $password,
    public_address => $public_ipaddress,
    admin_address => $admin_ipaddress,
    internal_address => $admin_ipaddress,
    region => $region,
  }

  class { '::nova':
    database_connection => $iaas::resources::connectors::nova,
    glance_api_servers => $endpoint,
    memcached_servers => ["localhost:11211"],
    rabbit_host => $endpoint,
    rabbit_userid => $rabbitmq_user,
    rabbit_password => $rabbitmq_password,
    mysql_module => '2.3',
    database_idle_timeout => 50, # Important to avoid facing "MySQL server has gone away" while using HAProxy+Galera. Should be < HAProxy server timeout (default: 60s)
  }

  nova_config { 'DEFAULT/default_floating_pool': value => 'public' }

  class { '::nova::api':
    enabled => true,
    admin_password => $password,
    auth_host => $endpoint,
    neutron_metadata_proxy_shared_secret => $neutron_secret,
  }

  class { '::nova::vncproxy':
    enabled => true,
    host => $::openstack::config::controller_address_api,
  }

  class { [ 'nova::scheduler', 'nova::consoleauth', 'nova::conductor']:
    enabled => true,
  }

  @@haproxy::balancermember { "nova_api_${::fqdn}":
    listening_service => 'nova_api_cluster',
    server_names => $::hostname,
    ipaddresses => $public_ipaddress,
    ports => '8774',
    options => 'check inter 2000 rise 2 fall 5',
  }

  /*class { '::nova::compute::neutron': }

  class { '::nova::network::neutron':
    neutron_admin_password => $neutron_password,
    neutron_region_name => $region,
    neutron_admin_auth_url => "http://${endpoint}:35357/v2.0",
    neutron_url => "http://${endpoint}:9696",
    vif_plugging_is_fatal => false,
    vif_plugging_timeout => '0',
  }*/
}
