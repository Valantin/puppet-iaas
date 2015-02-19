class iaas::profile::horizon (
  $secret = undef,
  $public_ipaddress = hiera('iaas::public_ipaddress', undef),
  $admin_ipaddress = hiera('iaas::admin_ipaddress', undef),

  $endpoint_address = hiera('iaas::role::endpoint::main_address', undef),
  $endpoint_servers = hiera('iaas::role::endpoint::servers', undef),
  $fqdn = hiera('iaas::role::endpoint::main_hostname', undef),
) {
  class { '::horizon':
    allowed_hosts => union([$fqdn, '127.0.0.1', $public_ipaddress], $endpoint_servers),
    server_aliases => [ $fqdn, '127.0.0.1', $public_ipaddress ],
    secret_key => $secret,
    cache_server_ip => $admin_ipaddress,
    keystone_url => "http://${endpoint_address}:5000/v2.0",
  }

  @@haproxy::balancermember { "horizon_${::fqdn}":
    listening_service => 'horizon_cluster',
    server_names => $::hostname,
    ipaddresses => $public_ipaddress,
    options => 'check inter 2000 rise 2 fall 5',
  }
}
