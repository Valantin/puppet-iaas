class iaas::profile::neutron::common (
  $core_plugin = undef,
  $service_plugins = undef,

  $region = hiera('iaas::region', undef),

  $rabbitmq_user = hiera('iaas::profile::rabbitmq::user', 'guest'),
  $rabbitmq_password = hiera('iaas::profile::rabbitmq::password', 'guest'),
  $rabbitmq_hosts = hiera('iaas::profile::rabbitmq::hosts', '127.0.0.1'),
  $rabbitmq_port = hiera('iaas::profile::rabbitmq::port', '5672'),
) {
  file { 'etc_default_neutron-server':
    path => '/etc/default/neutron-server',
    ensure => 'present'
  }

  class { '::neutron':
    core_plugin => $core_plugin,
    allow_overlapping_ips => true,
    rabbit_hosts => $rabbitmq_hosts,
    rabbit_user => $rabbitmq_user,
    rabbit_password => $rabbitmq_password,
    rabbit_port => $rabbitmq_port,
    service_plugins => $service_plugins,
  }

  class  { '::neutron::plugins::ml2':
    type_drivers => ['vlan'],
    tenant_network_types => ['vlan'],
    mechanism_drivers => ['linuxbridge'],
    flat_networks => ["vlan_1101_untagged"],
    tunnel_id_ranges => ['10:1000'],
    network_vlan_ranges  => ['vlan_100_untagged:1:2000'],
  }
}
