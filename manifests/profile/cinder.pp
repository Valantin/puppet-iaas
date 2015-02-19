class iaas::profile::cinder (
  $password = undef,
  $public_ipaddress = hiera('iaas::public_ipaddress', undef),
  $admin_ipaddress = hiera('iaas::admin_ipaddress', undef),
  $secret = undef,
  $volume_size = undef,

  $region = hiera('iaas::region', undef),
  $endpoint = hiera('iaas::role::endpoint::main_address', undef),
  $rabbitmq_user = hiera('iaas::profile::rabbitmq::user', undef),
  $rabbitmq_password = hiera('iaas::profile::rabbitmq::password', undef),
) {
  include iaas::resources::connectors
  iaas::resources::database { 'cinder': }

  class { '::cinder':
    database_connection => $iaas::resources::connectors::cinder,
    rabbit_host => $endpoint,
    rabbit_userid => $rabbitmq_user,
    rabbit_password => $rabbitmq_password,
    mysql_module => '2.3',
    database_idle_timeout => 50, # Important to avoid facing "MySQL server has gone away" while using HAProxy+Galera. Should be < HAProxy server timeout (default: 60s)
  }

  class { '::cinder::glance':
    glance_api_servers => [ "${endpoint}:9292" ],
  }

  class { '::cinder::keystone::auth':
    password => $password,
    public_address => $public_ipaddress,
    admin_address => $admin_ipaddress,
    internal_address => $admin_ipaddress,
    region => $region,
  }

  class { '::cinder::api':
    keystone_password => $password,
    keystone_auth_host => $endpoint,
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
    ipaddresses => $public_ipaddress,
    ports => '8776',
    options => 'check inter 2000 rise 2 fall 5',
  }
}
