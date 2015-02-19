class iaas::profile::neutron::server (

  $data_network_address = undef,
  $core_plugin = undef,
  $service_plugins = undef,
  $public_ipaddress = hiera('iaas::public_ipaddress'),
  $admin_ipaddress = hiera('iaas::admin_ipaddress', undef),

  $neutron_password = hiera('iaas::profile::neutron::password', undef),
  $nova_password = hiera('iaas::profile::nova::controller::password', undef),

  $region = hiera('iaas::region', undef),
  $endpoint = hiera('iaas::role::endpoint::main_address', undef),
  $rabbitmq_user = hiera('iaas::profile::rabbitmq::user', undef),
  $rabbitmq_password = hiera('iaas::profile::rabbitmq::password', undef),
) {
  include iaas::resources::connectors
  iaas::resources::database { 'neutron': }

  class { '::neutron':
    core_plugin => $core_plugin,
    allow_overlapping_ips => true,
    rabbit_host => $endpoint,
    rabbit_user => $rabbitmq_user,
    rabbit_password => $rabbitmq_password,
    service_plugins => $service_plugins,
  }

  class { '::neutron::keystone::auth':
    password => $neutron_password,
    public_address => $public_ipaddress,
    admin_address => $admin_ipaddress,
    internal_address => $admin_ipaddress,
    region => $region,
  }

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

  class { '::neutron::server::notifications':
    nova_url => "http://${endpoint}:8774/v2/",
    nova_admin_auth_url => "http://${endpoint}:35357/v2.0/",
    nova_admin_password => $nova_password,
    nova_region_name    => $region,
  }

  class  { '::neutron::plugins::ml2':
    type_drivers         => ['gre'],
    tenant_network_types => ['gre'],
    mechanism_drivers    => ['openvswitch'],
    tunnel_id_ranges     => ['10:1000']
  }

  /* On Compute node:
  class { '::neutron::agents::ml2::ovs':
    enable_tunneling => true,
    local_ip         => $data_network_address,
    enabled          => true,
    tunnel_types     => ['gre'],
  }*/

  @@haproxy::balancermember { "neutron_api_${::fqdn}":
      listening_service => 'neutron_api_cluster',
      server_names => $::hostname,
      ipaddresses => $public_ipaddress,
      ports => '9696',
      options => 'check inter 2000 rise 2 fall 5',
    }
}
