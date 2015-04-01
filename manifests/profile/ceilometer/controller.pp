class iaas::profile::ceilometer::controller (
  $password = hiera('iaas::profile::ceilometer::password', undef),
  $servers = hiera('iaas::profile::ceilometer::servers', undef),

  $public_interface = hiera('iaas::public_interface', undef),
  $admin_interface = hiera('iaas::admin_interface', undef),

  $region = hiera('iaas::region', undef),
  $endpoint = hiera('iaas::role::endpoint::main_address', undef),

  $zookeeper_id = undef,
  $zookeeper_max_connections = 128,
) {
  include iaas::resources::connectors
  iaas::resources::database { 'ceilometer': }

  include iaas::profile::ceilometer::common

  $admin_ip = $::facts["ipaddress_${admin_interface}"]

  class { '::ceilometer::keystone::auth':
    password => $password,
    public_address => $endpoint,
    admin_address => $endpoint,
    internal_address => $endpoint,
    region => $region,
  }

  class { '::ceilometer::api':
    enabled => true,
    keystone_password => $password,
    keystone_auth_uri => "http://${endpoint}:5000/v2.0",
    keystone_identity_uri => "http://${endpoint}:35357",
  }

  class { '::ceilometer::db':
    database_connection => $iaas::resources::connectors::ceilometer,
    mysql_module => '2.3',
  }

  package { 'python-zake': }
  class { 'zookeeper':
    id => $zookeeper_id,
    client_ip => $::facts["ipaddress_${admin_interface}"],
    servers => $servers,
    max_allowed_connections => $zookeeper_max_connections,
  }

  class { '::ceilometer::agent::central':
    coordination_url => "kazoo://${$admin_ip}:2181",
  }

  class { '::ceilometer::alarm::evaluator':
    coordination_url => "kazoo://${$admin_ip}:2181",
  }

  class { '::ceilometer::expirer':
    time_to_live => '2592000',
  }

  class { '::ceilometer::alarm::notifier': }
  class { '::ceilometer::collector': }
  class { '::ceilometer::agent::notification': }

  @@haproxy::balancermember { "ceilometer_api_${::fqdn}":
    listening_service => 'ceilometer_api_cluster',
    server_names => $::hostname,
    ipaddresses => $::facts["ipaddress_${public_interface}"],
    ports => '8777',
    options => 'check inter 2000 rise 2 fall 5',
  }
}
