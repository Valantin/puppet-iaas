class iaas::profile::neutron::client (
  $data_ipaddress = undef,
) {
  include iaas::profile::neutron::common

  class { '::neutron::agents::ml2::ovs':
    enable_tunneling => true,
    local_ip         => $data_ipaddress,
    enabled          => true,
    tunnel_types     => ['gre'],
  }
}
