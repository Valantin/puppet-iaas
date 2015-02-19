class iaas::profile::neutron::common (
  $core_plugin = undef,
  $service_plugins = undef,

  $neutron_password = hiera('iaas::profile::neutron::password', undef),

  $region = hiera('iaas::region', undef),
  $endpoint = hiera('iaas::role::endpoint::main_address', undef),
  $rabbitmq_user = hiera('iaas::profile::rabbitmq::user', undef),
  $rabbitmq_password = hiera('iaas::profile::rabbitmq::password', undef),
) {
  class { '::neutron':
    core_plugin => $core_plugin,
    allow_overlapping_ips => true,
    rabbit_host => $endpoint,
    rabbit_user => $rabbitmq_user,
    rabbit_password => $rabbitmq_password,
    service_plugins => $service_plugins,
  }

  class  { '::neutron::plugins::ml2':
    type_drivers => ['gre', 'flat'],
    tenant_network_types => ['gre'],
    mechanism_drivers => ['openvswitch'],
    flat_networks => ["external"],
    tunnel_id_ranges => ['10:1000'],
  }
}
