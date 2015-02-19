class iaas::profile::neutron::router (
  $admin_ipaddress = hiera('iaas::admin_ipaddress', undef),

  $data_ipaddress = undef,
  $external_device = undef,
  $external_network = hiera('iaas::profile::neutron::external_network', undef),

  $ipaddress = hiera('iaas::profile::base::ipaddress'),
  $netmask = hiera('iaas::profile::base::netmask'),
  $gateway = hiera('iaas::profile::base::gateway'),

  $neutron_password = hiera('iaas::profile::neutron::password', undef),
  $neutron_secret = hiera('iaas::profile::neutron::secret', undef),

  $region = hiera('iaas::region', undef),
  $endpoint = hiera('iaas::role::endpoint::main_address', undef),
) {
  sysctl { 'net.ipv4.ip_forward': value => '1' }

  include iaas::profile::neutron::common

  class { '::neutron::agents::ml2::ovs':
    enable_tunneling => true,
    local_ip => $data_ipaddress,
    enabled => true,
    tunnel_types => ['gre'],
    bridge_mappings => ['external:br-ex'],
  }

  class { '::neutron::agents::l3':
    external_network_bridge => 'br-ex',
    use_namespaces => true,
    router_delete_namespaces => true,
    enabled => true,
  }

  class { '::neutron::agents::dhcp':
    enabled => true,
    dhcp_delete_namespaces => true,
  }

  class { '::neutron::agents::lbaas':
    enabled => true,
  }

  class { '::neutron::agents::vpnaas':
    enabled => true,
  }

  class { '::neutron::agents::metering':
    enabled => true,
  }

  class { '::neutron::services::fwaas':
    enabled => true,
  }

  class { '::neutron::agents::metadata':
    auth_password => $neutron_password,
    shared_secret => $neutron_secret,
    auth_url => "http://${endpoint}:35357/v2.0",
    auth_region => $region,
    metadata_ip => $admin_ipaddress,
    enabled => true,
  }

  $_external_device = device_for_network($external_network)
  if $_external_device != 'br-ex' {
    network_config { $external_device:
      ensure  => 'present',
      family  => 'inet',
      method  => 'manual',
      options => {
        'up' => "ifconfig ${external_device} promisc up",
        'down' => "ifconfig ${external_device} promisc down",
      },
    } ->
    network_config { 'br-ex':
      ensure  => 'present',
      family  => 'inet',
      method  => 'static',
      ipaddress => $ipaddress,
      netmask => $netmask,
    } ->
    network_route { 'route_default':
      ensure => 'present',
      gateway => $gateway,
      interface => 'br-ex',
      netmask => '0.0.0.0',
      network => 'default'
    } ->
    vs_port { $external_device:
      ensure => present,
      bridge => 'br-ex',
    }
  }
}
