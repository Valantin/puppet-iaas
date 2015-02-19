class iaas::profile::heat (
  $password = undef,
  $encryption_key = undef,
  $public_ipaddress = hiera('iaas::public_ipaddress', undef),
  $admin_ipaddress = hiera('iaas::admin_ipaddress', undef),

  $region = hiera('iaas::region', undef),
  $endpoint = hiera('iaas::role::endpoint::main_address', undef),
  $rabbitmq_user = hiera('iaas::profile::rabbitmq::user', undef),
  $rabbitmq_password = hiera('iaas::profile::rabbitmq::password', undef),
) {
  include iaas::resources::connectors
  iaas::resources::database { 'heat': }

  class { '::heat::keystone::auth':
    password         => $password,
    public_address   => $public_ipaddress,
    admin_address    => $admin_ipaddress,
    internal_address => $admin_ipaddress,
    region           => $region,
  }

  class { '::heat':
    database_connection => $iaas::resources::connectors::heat,
    rabbit_host         => $endpoint,
    rabbit_userid       => $rabbitmq_user,
    rabbit_password     => $rabbitmq_password,
    keystone_host       => $endpoint,
    keystone_password   => $password,
    mysql_module        => '2.3',
    database_idle_timeout => 50, # Important to avoid facing "MySQL server has gone away" while using HAProxy+Galera. Should be < HAProxy server timeout (default: 60s)
  }

  class { '::heat::api':
    bind_host => $public_ipaddress,
  }

  class { '::heat::engine':
    auth_encryption_key => $encryption_key,
  }

  @@haproxy::balancermember { "heat_api_${::fqdn}":
    listening_service => 'heat_api_cluster',
    server_names => $::hostname,
    ipaddresses => $public_ipaddress,
    ports => '8000',
    options => 'check inter 2000 rise 2 fall 5',
  }
}
