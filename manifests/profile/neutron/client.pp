class iaas::profile::neutron::client (
  $public_interface = hiera('iaas::public_interface', undef),
) {
  include iaas::profile::neutron::common

  class { '::neutron::agents::ml2::linuxbridge':
    firewall_driver => 'neutron.agent.linux.iptables_firewall.IptablesFirewallDriver',
    physical_interface_mappings => ['vlan_1101_untagged:eth1'],
    require => File['etc_default_neutron-server'],
  }
}
