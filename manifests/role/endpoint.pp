class iaas::role::endpoint (
  $haproxy_ip,
  $haproxy_port
) {
  # Base
  class { 'iaas::profile::base': } ->

  # Proxy
  class { 'haproxy': }
  haproxy::listen { 'puppet00':
    ipaddress => $haproxy_ip,
    ports     => $haproxy_port,
  }
}
