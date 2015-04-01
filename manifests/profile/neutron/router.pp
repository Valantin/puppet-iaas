class iaas::profile::neutron::router (
  $public_interface = hiera('iaas::public_interface', undef),

  $external_device = undef,
  $external_network = hiera('iaas::profile::neutron::external_network', undef),
  $external_gateway = hiera('iaas::profile::neutron::external_gateway', undef),

  $neutron_password = hiera('iaas::profile::neutron::password', undef),
  $neutron_secret = hiera('iaas::profile::neutron::secret', undef),

  $region = hiera('iaas::region', undef),
  $endpoint = hiera('iaas::role::endpoint::main_address', undef),
) {
  sysctl { 'net.ipv4.ip_forward': value => '1' }
  sysctl { 'net.ipv4.conf.all.rp_filter': value => '0' }
  sysctl { 'net.ipv4.conf.default.rp_filter': value => '0' }

  sysctl { 'net.ipv4.conf.all.accept_redirects': value => '0' }
  sysctl { 'net.ipv4.conf.default.accept_redirects': value => '0' }
  sysctl { 'net.ipv4.conf.all.send_redirects': value => '0' }
  sysctl { 'net.ipv4.conf.default.send_redirects': value => '0' }

  package { 'ifupdown-extra': }

  include iaas::profile::neutron::common

  class { '::neutron::agents::l3':
    external_network_bridge => 'br-ex',
    use_namespaces => true,
    router_delete_namespaces => true,
    ha_enabled => true,
    enabled => false,
  }

  class { '::neutron::agents::dhcp':
    dhcp_delete_namespaces => true,
    enable_isolated_metadata => true,
    enable_metadata_network => true,
  }

  class { '::neutron::agents::vpnaas':
    external_network_bridge => "br-ex",
  }
  class { '::neutron::agents::lbaas': }
  class { '::neutron::agents::metering': }
  class { '::neutron::services::fwaas':
    vpnaas_agent_package => true
  }

  class { '::neutron::agents::metadata':
    auth_password => $neutron_password,
    shared_secret => $neutron_secret,
    auth_url => "http://${endpoint}:5000/v2.0",
    auth_region => $region,
    metadata_ip => $endpoint,
    enabled => true,
  }

  if $ipaddress_br_ex == '' {
    $local_ip = $::facts["ipaddress_${public_interface}"]
  } else {
    $local_ip = $::ipaddress_br_ex
  }
  class { '::neutron::agents::ml2::ovs':
      enable_tunneling => true,
      local_ip => $local_ip,
      enabled => true,
      tunnel_types => ['gre'],
      bridge_mappings => ['external:br-ex'],
      require => File['etc_default_neutron-server'],
  }

  $_external_device = device_for_network($external_network)
  if $_external_device != 'br_ex' {
    # Store initial configuration from the public interface (assigned by DHCP) to restore on br-ex
    $public_ipaddress = $::facts["ipaddress_${public_interface}"]
    $public_netmask = $::facts["netmask_${public_interface}"]

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
      ipaddress => $public_ipaddress,
      netmask => $public_netmask,
    } ->
    vs_port { $external_device:
      ensure => present,
      bridge => 'br-ex',
      require => Class['::neutron::agents::ml2::ovs'],
    } ->
    network_route { 'route_default':
      ensure => 'present',
      gateway => $external_gateway,
      interface => 'br-ex',
      netmask => '0.0.0.0',
      network => 'default',
      require => Package['ifupdown-extra']
    }
  }
}
