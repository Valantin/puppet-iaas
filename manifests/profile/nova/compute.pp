class iaas::profile::nova::compute (
  $admin_interface = hiera('iaas::admin_interface', undef),

  $neutron_password = hiera('iaas::profile::neutron::password', undef),
  $cinder_secret = hiera('iaas::profile::cinder::secret', undef),

  $region = hiera('iaas::region', undef),
  $endpoint = hiera('iaas::role::endpoint::main_address', undef),
) {
  include iaas::profile::nova::common

  package { 'sysfsutils': }

  sysctl { 'net.ipv4.ip_forward': value => '1' }
  sysctl { 'net.ipv4.conf.all.rp_filter': value => '0' }
  sysctl { 'net.ipv4.conf.default.rp_filter': value => '0' }

  class { 'ceph::profile::client': } ->
  class { 'ceph::keys': }

  class { '::nova::compute':
    enabled => true,
    vnc_enabled => true,
    vncserver_proxyclient_address => $::facts["ipaddress_${admin_interface}"],
    vncproxy_host => $endpoint,
    vnc_keymap => 'fr',
  }

  class { '::nova::compute::neutron': }

  class { '::nova::compute::libvirt':
    libvirt_virt_type => 'kvm',
    vncserver_listen => '0.0.0.0',
    migration_support => true,
  }

  class {'nova::compute::rbd':
    libvirt_rbd_user => 'cinder',
    libvirt_images_rbd_pool => 'vms',
    libvirt_rbd_secret_uuid => $cinder_secret,
    rbd_keyring => 'client.cinder'
  }

  nova_config {
    'libvirt/libvirt_live_migration_flag': value => 'VIR_MIGRATE_UNDEFINE_SOURCE,VIR_MIGRATE_PEER2PEER,VIR_MIGRATE_LIVE,VIR_MIGRATE_PERSIST_DEST';
  }
}
