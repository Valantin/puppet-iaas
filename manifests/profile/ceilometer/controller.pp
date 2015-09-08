class iaas::profile::ceilometer::controller (
  $password = hiera('iaas::profile::ceilometer::password', undef),
  $servers = hiera('iaas::profile::ceilometer::servers', undef),

  $public_interface = hiera('iaas::public_interface', undef),
  $admin_interface = hiera('iaas::admin_interface', undef),

  $region = hiera('iaas::region', undef),

  $zookeeper_id = undef,
  $zookeeper_max_connections = 128,

  $rabbitmq_user = hiera('iaas::profile::rabbitmq::user', 'guest'),
  $rabbitmq_password = hiera('iaas::profile::rabbitmq::password', 'guest'),
  $rabbitmq_hosts = hiera('iaas::profile::rabbitmq::hosts', '127.0.0.1'),
  $rabbitmq_port = hiera('iaas::profile::rabbitmq::port', '5672'),

  $db_user = hiera('iaas::mysql::ceilometer::user', 'ceilometer'),
  $db_password = hiera('iaas::mysql::ceilometer::password', undef),
  $db_address = hiera('iaas::mysql::ceilometer::host', undef),

  $public_address = hiera('iaas::profile::keystone::public_address', undef),
  $internal_address = hiera('iaas::profile::keystone::internal_address', undef),
  $admin_address = hiera('iaas::profile::keystone::admin_address', undef),
  $public_port = hiera('iaas::profile::keystone::public_port', '5000'),
  $internal_port = hiera('iaas::profile::keystone::internal_port', '5000'),
  $admin_port = hiera('iaas::profile::keystone::admin_port', '35357'),

  $api_port = '8777',
) {
  include iaas::resources::connectors
  iaas::resources::database { 'ceilometer': }

  include iaas::profile::ceilometer::common

  $admin_ip = $::facts["ipaddress_${admin_interface}"]

  class { '::ceilometer::keystone::auth':
    password => $password,
    public_address => $public_address,
    admin_address => $admin_address,
    internal_address => $internal_address,
    region => $region,
  }

  class { '::ceilometer::api':
    enabled => true,
    keystone_password => $password,
    keystone_auth_uri => "http://${public_address}:${public_port}/v2.0",
    keystone_identity_uri => "http://${admin_address}:${admin_port}",
  }

  class { '::ceilometer::db':
    database_connection => "mysql://${db_user}:${db_password}@${db_address}/ceilometer",
  }

  package { 'python-zake': }
  class { 'zookeeper':
    id => $zookeeper_id,
    client_ip => $::facts["ipaddress_${admin_interface}"],
    servers => $servers,
    max_allowed_connections => $zookeeper_max_connections,
  }

  class { '::ceilometer::agent::central':
    coordination_url => "kazoo://${admin_address}:2181",
  }

  class { '::ceilometer::alarm::evaluator':
    coordination_url => "kazoo://${admin_address}:2181",
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
    ports => "${api_port}",
    options => 'check inter 2000 rise 2 fall 5',
  }
}
