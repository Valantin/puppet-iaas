class iaas::profile::horizon (
  $secret = undef,
  $public_interface = hiera('iaas::public_interface', undef),

  $endpoint_address = hiera('iaas::role::endpoint::main_address', undef),
  $endpoint_servers = hiera('iaas::role::endpoint::servers', undef),
  $fqdn = hiera('iaas::role::endpoint::main_hostname', undef),

  
  $public_address = hiera('iaas::profile::keystone::public_address', undef),
  $internal_address = hiera('iaas::profile::keystone::internal_address', undef),
  $admin_address = hiera('iaas::profile::keystone::admin_address', undef),
  $public_port = hiera('iaas::profile::keystone::public_port', '5000'),
  $internal_port = hiera('iaas::profile::keystone::internal_port', '5000'),
  $admin_port = hiera('iaas::profile::keystone::admin_port', '35357'),
) {
  class { '::horizon':
    allowed_hosts => union([$fqdn, '127.0.0.1', $::facts["ipaddress_${public_interface}"]], $endpoint_servers),
    server_aliases => union([$fqdn, '127.0.0.1', $::facts["ipaddress_${public_interface}"]], $endpoint_servers),
    secret_key => $secret,
    cache_server_ip => $::facts["ipaddress_${admin_interface}"],
    keystone_url => "http://${public_address}:${public_port}/v2.0",
    cinder_options => {
      'enable_backup' => true,
    },
    neutron_options => {
      'enable_lb' => true,
      'enable_firewall' => true,
      'enable_vpn' => true,
    },
  }

  @@haproxy::balancermember { "horizon_${::fqdn}":
    listening_service => 'horizon_cluster',
    server_names => $::hostname,
    ipaddresses => $::facts["ipaddress_${public_interface}"],
    options => 'check inter 2000 rise 2 fall 5',
  }
}
