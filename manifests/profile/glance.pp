class iaas::profile::glance (
  $password = undef,
  $public_interface = hiera('iaas::public_interface', undef),
  $admin_interface = hiera('iaas::admin_interface', undef),

  $region = hiera('iaas::region', undef),

  $rabbitmq_user = hiera('iaas::profile::rabbitmq::user', 'guest'),
  $rabbitmq_password = hiera('iaas::profile::rabbitmq::password', 'guest'),
  $rabbitmq_hosts = hiera('iaas::profile::rabbitmq::hosts', '127.0.0.1'),
  $rabbitmq_port = hiera('iaas::profile::rabbitmq::port', '5672'),
  
  $db_user = hiera('iaas::mysql::glance::user', 'keystone'),
  $db_password = hiera('iaas::mysql::glance::password', undef),
  $db_address = hiera('iaas::mysql::glance::host', undef),


  $public_address = hiera('iaas::profile::keystone::public_address', undef),
  $internal_address = hiera('iaas::profile::keystone::internal_address', undef),
  $admin_address = hiera('iaas::profile::keystone::admin_address', undef),
  $public_port = hiera('iaas::profile::keystone::public_port', '5000'),
  $internal_port = hiera('iaas::profile::keystone::internal_port', '5000'),
  $admin_port = hiera('iaas::profile::keystone::admin_port', '35357'),

  $api_port = '9292',
  $registry_port = '9191',
) {

  class { 'ceph::profile::client': } ->
  class { 'ceph::keys': } ->

  class { '::glance::api':
    keystone_password => $password,
    auth_uri => "http://${public_address}:${public_port}/v2.0",
    identity_uri => "http://${admin_address}:${admin_port}",
    database_connection => "mysql://${db_user}:${db_password}@${db_address}/glance",
    registry_host => 'localhost',
    os_region_name => $region,
    known_stores => ['glance.store.filesystem.Store', 'glance.store.http.Store', 'glance.store.rbd.Store', 'glance.store.cinder.Store'],
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
    database_connection => "mysql://${db_user}:${db_password}@${db_address}/glance",
    auth_uri => "http://${public_address}:${public_port}/v2.0",
    identity_uri => "http://${admin_address}:${admin_port}",
  }

  class { '::glance::notify::rabbitmq':
    rabbit_userid => $rabbitmq_user,
    rabbit_password => $rabbitmq_password,
    rabbit_hosts => $rabbitmq_hosts,
    rabbit_port => $rabbitmq_port,
  }

  class  { '::glance::keystone::auth':
    password => $password,
    public_address => $public_address,
    admin_address => $admin_address,
    internal_address => $internal_address,
    region => $region,
  }

  @@haproxy::balancermember { "glance_registry_${::fqdn}":
    listening_service => 'glance_registry_cluster',
    server_names => $::hostname,
    ipaddresses => $::facts["ipaddress_${admin_interface}"],
    ports => "${registry_port}",
    options => 'check inter 2000 rise 2 fall 5',
  }
  @@haproxy::balancermember { "glance_api_${::fqdn}":
    listening_service => 'glance_api_cluster',
    server_names => $::hostname,
    ipaddresses => $::facts["ipaddress_${public_interface}"],
    ports => "${api_port}",
    options => 'check inter 2000 rise 2 fall 5',
  }
}
