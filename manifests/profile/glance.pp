class iaas::profile::glance (
  $password = undef,
  $public_interface = hiera('iaas::public_interface', undef),
  $admin_interface = hiera('iaas::admin_interface', undef),

  $region = hiera('iaas::region', undef),
  $endpoint = hiera('iaas::role::endpoint::main_address', undef),
  $rabbitmq_user = hiera('iaas::profile::rabbitmq::user', undef),
  $rabbitmq_password = hiera('iaas::profile::rabbitmq::password', undef),
) {
  include iaas::resources::connectors

  class { 'ceph::profile::client': } ->
  class { 'ceph::keys': } ->

  class { '::glance::api':
    keystone_password => $password,
    auth_uri => "http://${endpoint}:5000/v2.0",
    identity_uri => "http://${endpoint}:35357",
    keystone_tenant => 'services',
    keystone_user => 'glance',
    database_connection => $iaas::resources::connectors::glance,
    registry_host => 'localhost',
    mysql_module => '2.3',
    database_idle_timeout => 3,
    os_region_name => $region,
    known_stores => ['glance.store.filesystem.Store', 'glance.store.http.Store', 'glance.store.rbd.Store', 'glance.store.cinder.Store'], #  'glance.store.sheepdog.Store', 'glance.store.vmware_datastore.Store', 'glance.store.s3.Store', 'glance.store.swift.Store'
    show_image_direct_url => true,
    pipeline => 'keystone',
  }

  class { '::glance::backend::rbd':
    rbd_store_user => 'glance',
    rbd_store_ceph_conf => '/etc/ceph/ceph.conf',
    rbd_store_pool => 'images',
  }

  class { '::glance::registry':
    keystone_password => $password,
    database_connection => $iaas::resources::connectors::glance,
    auth_uri => "http://${endpoint}:5000/v2.0",
    identity_uri => "http://${endpoint}:35357",
    keystone_tenant => 'services',
    keystone_user => 'glance',
    mysql_module => '2.3',
    database_idle_timeout => 3,
  }

  class { '::glance::notify::rabbitmq':
    rabbit_userid => $rabbitmq_user,
    rabbit_password => $rabbitmq_password,
    rabbit_host => $endpoint,
  }

  iaas::resources::database { 'glance': }

  class  { '::glance::keystone::auth':
    password => $password,
    public_address => $endpoint,
    admin_address => $endpoint,
    internal_address => $endpoint,
    region => $region,
  }

  @@haproxy::balancermember { "glance_registry_${::fqdn}":
    listening_service => 'glance_registry_cluster',
    server_names => $::hostname,
    ipaddresses => $::facts["ipaddress_${admin_interface}"],
    ports => '9191',
    options => 'check inter 2000 rise 2 fall 5',
  }
  @@haproxy::balancermember { "glance_api_${::fqdn}":
    listening_service => 'glance_api_cluster',
    server_names => $::hostname,
    ipaddresses => $::facts["ipaddress_${public_interface}"],
    ports => '9292',
    options => 'check inter 2000 rise 2 fall 5',
  }
}
