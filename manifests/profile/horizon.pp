class iaas::profile::horizon (
  $secret = undef,
  $public_interface = hiera('iaas::public_interface', undef),

  $endpoint_address = hiera('iaas::role::endpoint::main_address', undef),
  $endpoint_servers = hiera('iaas::role::endpoint::servers', undef),
  $fqdn = hiera('iaas::role::endpoint::main_hostname', undef),
) {
  class { '::horizon':
    allowed_hosts => union([$fqdn, '127.0.0.1', $::facts["ipaddress_${public_interface}"]], $endpoint_servers),
    server_aliases => union([$fqdn, '127.0.0.1', $::facts["ipaddress_${public_interface}"]], $endpoint_servers),
    secret_key => $secret,
    cache_server_ip => $::facts["ipaddress_${admin_interface}"],
    keystone_url => "http://${endpoint_address}:5000/v2.0",
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
