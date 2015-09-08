class iaas::profile::keystone (
  $admin_token = undef,
  $admin_email = undef,
  $admin_password = undef,
  $tenants = undef,
  $users = undef,

  $public_interface = hiera('iaas::public_interface', undef),
  $admin_interface = hiera('iaas::admin_interface', undef),

  $region = hiera('iaas::region', undef),

  $rabbitmq_user = hiera('iaas::profile::rabbitmq::user', 'guest'),
  $rabbitmq_password = hiera('iaas::profile::rabbitmq::password', 'guest'),
  $rabbitmq_hosts = hiera('iaas::profile::rabbitmq::hosts', '127.0.0.1'),
  $rabbitmq_port = hiera('iaas::profile::rabbitmq::port', '5672'),
  
  $db_user = hiera('iaas::mysql::keystone::user', 'keystone'),
  $db_password = hiera('iaas::mysql::keystone::password', undef),
  $db_address = hiera('iaas::mysql::keystone::host', undef),

  $public_address = undef,
  $internal_address = undef,
  $admin_address = undef,
  $public_port = '5000',
  $internal_port = '5000',
  $admin_port = '35357',
) {

  class { '::keystone':
    admin_token => $admin_token,
    database_connection => "mysql://${db_user}:${db_password}@${db_address}/keystone",
    admin_bind_host => '0.0.0.0',
    rabbit_userid => $rabbitmq_user,
    rabbit_password => $rabbitmq_password,
    rabbit_hosts => $rabbitmq_hosts,
    rabbit_port => $rabbitmq_port,
  }

  class { 'keystone::endpoint':
    public_url => "http://${public_address}:${public_port}",
    admin_url => "http://${admin_address}:${admin_port}",
    internal_url => "http://${internal_address}:${internal_port}",
    region => $region,
  }

  create_resources('iaas::resources::tenant', $tenants)
  create_resources('iaas::resources::user', $users)

  @@haproxy::balancermember { "keystone_admin_cluster_${::fqdn}":
    listening_service => 'keystone_admin_cluster',
    server_names => $::hostname,
    ipaddresses => $::facts["ipaddress_${admin_interface}"],
    ports => "${admin_port}",
    options => 'check inter 2000 rise 2 fall 5',
  }

  @@haproxy::balancermember { "keystone_public_internal_cluster_${::fqdn}":
    listening_service => 'keystone_public_internal_cluster',
    server_names => $::hostname,
    ipaddresses => $::facts["ipaddress_${public_interface}"],
    ports => "${public_port}",
    options => 'check inter 2000 rise 2 fall 5',
  }
}
