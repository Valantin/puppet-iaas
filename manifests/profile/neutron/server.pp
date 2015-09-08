class iaas::profile::neutron::server (
  $public_interface = hiera('iaas::public_interface', undef),
  $admin_interface = hiera('iaas::admin_interface', undef),

  $neutron_password = hiera('iaas::profile::neutron::password', undef),
  $nova_password = hiera('iaas::profile::nova::controller::password', undef),

  $region = hiera('iaas::region', undef),

  $rabbitmq_user = hiera('iaas::profile::rabbitmq::user', 'guest'),
  $rabbitmq_password = hiera('iaas::profile::rabbitmq::password', 'guest'),
  $rabbitmq_hosts = hiera('iaas::profile::rabbitmq::hosts', '127.0.0.1'),
  $rabbitmq_port = hiera('iaas::profile::rabbitmq::port', '5672'),

  $db_user = hiera('iaas::mysql::neutron::user', 'neutron'),
  $db_password = hiera('iaas::mysql::neutron::password', undef),
  $db_address = hiera('iaas::mysql::neutron::host', undef),

  $public_address = hiera('iaas::profile::keystone::public_address', undef),
  $internal_address = hiera('iaas::profile::keystone::internal_address', undef),
  $admin_address = hiera('iaas::profile::keystone::admin_address', undef),
  $public_port = hiera('iaas::profile::keystone::public_port', '5000'),
  $internal_port = hiera('iaas::profile::keystone::internal_port', '5000'),
  $admin_port = hiera('iaas::profile::keystone::admin_port', '35357'),

  $nova_api_port = hiera('iaas::profile::nova::api_port', '8774'),

  $api_port = '9696',
) {
  include iaas::resources::connectors
  iaas::resources::database { 'neutron': }

  include iaas::profile::neutron::common

  class { '::neutron::server':
    auth_uri => "http://${public_address}:${public_port}/v2.0",
    identity_uri => "http://${admin_address}:${admin_port}",
    auth_password => $neutron_password,
    database_connection => "mysql://${db_user}:${db_password}@${db_address}/neutron",
    enabled => true,
    sync_db => true,
#    l3_ha => true,
#    allow_automatic_l3agent_failover => true,
  }

  class { '::neutron::keystone::auth':
    password => $neutron_password,
    public_address => $public_address,
    admin_address => $admin_address,
    internal_address => $internal_address,
    region => $region,
  }

  class { '::neutron::server::notifications':
    nova_url => "http://${public_address}:${nova_api_port}/v2",
    nova_admin_auth_url => "http://${admin_address}:${admin_port}/v2.0",
    nova_admin_password => $nova_password,
    nova_region_name => $region,
  }

  @@haproxy::balancermember { "neutron_api_${::fqdn}":
      listening_service => 'neutron_api_cluster',
      server_names => $::hostname,
      ipaddresses => $::facts["ipaddress_${public_interface}"],
      ports => "${api_port}",
      options => 'check inter 2000 rise 2 fall 5',
    }
}
