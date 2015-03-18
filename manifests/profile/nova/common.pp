class iaas::profile::nova::common (
  $public_interface = hiera('iaas::public_interface', undef),

  $neutron_password = hiera('iaas::profile::neutron::password', undef),
  $nova_password = hiera('iaas::profile::nova::controller::password', undef),

  $region = hiera('iaas::region', undef),
  $endpoint = hiera('iaas::role::endpoint::main_address', undef),
  $rabbitmq_user = hiera('iaas::profile::rabbitmq::user', undef),
  $rabbitmq_password = hiera('iaas::profile::rabbitmq::password', undef),
) {
  include iaas::resources::connectors

  class { '::nova':
    database_connection => $iaas::resources::connectors::nova,
    glance_api_servers => [ "${endpoint}:9292" ],
    memcached_servers => ['localhost:11211'],
    rabbit_host => $endpoint,
    rabbit_userid => $rabbitmq_user,
    rabbit_password => $rabbitmq_password,
    mysql_module => '2.3',
  }

  class { '::nova::network::neutron':
    neutron_admin_password => $neutron_password,
    neutron_region_name => $region,
    neutron_admin_auth_url => "http://${endpoint}:35357/v2.0",
    neutron_url => "http://${endpoint}:9696",
    vif_plugging_is_fatal => false,
    vif_plugging_timeout => '0',
  }

  nova_config { 'DEFAULT/default_floating_pool': value => 'public' }
}
