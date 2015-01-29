class iaas::role::storage (
  $cluster_vlan = undef,
  $cluster_ipaddress = undef,
  $cluster_netmask = undef,
  $osd_disk = undef,
  $osd_partition = undef,
  $osd_uuid = undef,
) {
  # Base
  class { 'iaas::profile::base': } ->

  # Ceph cluster network
  network_config { "eth0.${cluster_vlan}":
    ensure  => 'present',
    family  => 'inet',
    method  => 'static',
    ipaddress => $cluster_ipaddress,
    netmask   => $cluster_netmask,
    onboot  => 'true',
  } ->
  exec { "ifup_eth0.${cluster_vlan}":
    command => "ifup eth0.${cluster_vlan}",
  } ->

  # Ceph
  class { 'ceph::profile::base': } ->
  class { 'ceph::profile::mon': } ->
  class { 'ceph::keys': } ->
  exec { "ceph-osd-sgdisk-${osd_partition}":
    command => "sgdisk --change-name='${osd_partition}:ceph data' --partition-guid=${osd_partition}:${osd_uuid} --typecode=${osd_partition}:4fbd7e29-9d25-41b8-afd0-062c0ceff05d -- ${osd_disk} && partprobe",
    unless => "/bin/true  # comment to satisfy puppet syntax requirements
set -ex
ceph-disk list 2> /dev/null | grep ' *${osd_disk}${osd_partition}.*ceph data'
",
    logoutput => true,
  } ->
  class { 'ceph::profile::osd': }
}
