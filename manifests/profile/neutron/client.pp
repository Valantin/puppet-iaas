class iaas::profile::neutron::client (
  $public_interface = hiera('iaas::public_interface', undef),
) {
  include iaas::profile::neutron::common

  class { '::neutron::agents::ml2::ovs':
    enable_tunneling => true,
    local_ip         => $::facts["ipaddress_${public_interface}"],
    enabled          => true,
    tunnel_types     => ['gre'],
    require => File['etc_default_neutron-server'],
  }
}
