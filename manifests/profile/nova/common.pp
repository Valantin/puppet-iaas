class iaas::profile::nova::common (
  $public_interface = hiera('iaas::public_interface', undef),

  $default_flotting_pool = undef,
  $neutron_password = hiera('iaas::profile::neutron::password', undef),
  $nova_password = hiera('iaas::profile::nova::controller::password', undef),

  $region = hiera('iaas::region', undef),

  $rabbitmq_user = hiera('iaas::profile::rabbitmq::user', 'guest'),
  $rabbitmq_password = hiera('iaas::profile::rabbitmq::password', 'guest'),
  $rabbitmq_hosts = hiera('iaas::profile::rabbitmq::hosts', '127.0.0.1'),
  $rabbitmq_port = hiera('iaas::profile::rabbitmq::port', '5672'),
  
  $db_user = hiera('iaas::mysql::heat::user', 'heat'),
  $db_password = hiera('iaas::mysql::heat::password', undef),
  $db_address = hiera('iaas::mysql::heat::host', undef),


  $public_address = hiera('iaas::profile::keystone::public_address', undef),
  $internal_address = hiera('iaas::profile::keystone::internal_address', undef),
  $admin_address = hiera('iaas::profile::keystone::admin_address', undef),
  $public_port = hiera('iaas::profile::keystone::public_port', '5000'),
  $internal_port = hiera('iaas::profile::keystone::internal_port', '5000'),
  $admin_port = hiera('iaas::profile::keystone::admin_port', '35357'),

  $glance_api_port = hiera('iaas::profile::glance::api_port', '9292'),
  $neutron_api_port = hiera('iaas::profile::neutron::api_port', '9696'),
) {
  include iaas::resources::connectors

  class { '::nova':
    database_connection => "mysql://${db_user}:${db_password}@${db_address}/nova",
    glance_api_servers => [ "${public_address}:${glance_api_port}" ],
    rabbit_hosts => $rabbitmq_hosts,
    rabbit_userid => $rabbitmq_user,
    rabbit_password => $rabbitmq_password,
    rabbit_port => $rabbitmq_port,
  }

  class { '::nova::network::neutron':
    neutron_admin_password => $neutron_password,
    neutron_region_name => $region,
    neutron_admin_auth_url => "http://${admin_address}:${admin_port}/v2.0",
    neutron_url => "http://${public_address}:${neutron_api_port}",
  }

  nova_config { 'DEFAULT/default_floating_pool': value => $default_flotting_pool }
}
