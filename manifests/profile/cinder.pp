class iaas::profile::cinder (
  $password = undef,
  $public_interface = hiera('iaas::public_interface', undef),
  $secret = undef,
  $volume_size = undef,

  $region = hiera('iaas::region', undef),

  $rabbitmq_user = hiera('iaas::profile::rabbitmq::user', 'guest'),
  $rabbitmq_password = hiera('iaas::profile::rabbitmq::password', 'guest'),
  $rabbitmq_hosts = hiera('iaas::profile::rabbitmq::hosts', '127.0.0.1'),
  $rabbitmq_port = hiera('iaas::profile::rabbitmq::port', '5672'),

  $db_user = hiera('iaas::mysql::cinder::user', 'cinder'),
  $db_password = hiera('iaas::mysql::cinder::password', undef),
  $db_address = hiera('iaas::mysql::cinder::host', undef),

  $public_address = hiera('iaas::profile::keystone::public_address', undef),
  $internal_address = hiera('iaas::profile::keystone::internal_address', undef),
  $admin_address = hiera('iaas::profile::keystone::admin_address', undef),
  $public_port = hiera('iaas::profile::keystone::public_port', '5000'),
  $internal_port = hiera('iaas::profile::keystone::internal_port', '5000'),
  $admin_port = hiera('iaas::profile::keystone::admin_port', '35357'),

  $glance_api_port = hiera('iaas::profile::glance::api_port', '9292'),
  $api_port = '8776',
) {
  include iaas::resources::connectors
  iaas::resources::database { 'cinder': }

  class { '::cinder':
    database_connection => "mysql://${db_user}:${db_password}@${db_address}/cinder",
    rabbit_userid => $rabbitmq_user,
    rabbit_password => $rabbitmq_password,
    rabbit_hosts => $rabbitmq_hosts,
    rabbit_port => $rabbitmq_port,
  }

  class { '::cinder::glance':
    glance_api_servers => [ "${public_address}:${glance_api_port}" ],
  }

  class { '::cinder::keystone::auth':
    password => $password,
    public_address => $public_address,
    admin_address => $admin_address,
    internal_address => $internal_address,
    region => $region,
  }

  class { '::cinder::api':
    keystone_password => $password,
    auth_uri => "http://${public_address}:${public_port}/v2.0",
    identity_uri => "http://${admin_address}:${admin_port}",
  }

  class { '::cinder::scheduler':
    scheduler_driver => 'cinder.scheduler.simple.SimpleScheduler',
  }

  class { '::cinder::setup_test_volume':
    volume_name => 'cinder-volumes',
    size => $volume_size
  } ->

  class { '::cinder::volume': }

  class { '::cinder::volume::rbd':
    rbd_pool => 'volumes',
    rbd_user => 'cinder',
    rbd_secret_uuid => $secret,
  }

  class { '::cinder::backup': }
  class { '::cinder::backup::ceph':
    backup_ceph_user => 'cinder-backup',
  }

  @@haproxy::balancermember { "cinder_api_${::fqdn}":
    listening_service => 'cinder_api_cluster',
    server_names => $::hostname,
    ipaddresses => $::facts["ipaddress_${public_interface}"],
    ports => "${api_port}",
    options => 'check inter 2000 rise 2 fall 5',
  }
}
