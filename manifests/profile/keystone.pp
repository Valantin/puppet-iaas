class iaas::profile::keystone (
  $admin_token = undef,
  $admin_email = undef,
  $admin_password = undef,
  $tenants = undef,
  $users = undef,

  $public_ipaddress = hiera('iaas::public_ipaddress', undef),
  $admin_ipaddress = hiera('iaas::admin_ipaddress', undef),

  $region = hiera('iaas::region', undef),
) {
  iaas::resources::database { 'keystone': }

  include iaas::resources::connectors
  class { '::keystone':
    admin_token => $admin_token,
    database_connection => $iaas::resources::connectors::keystone,
    admin_bind_host => '0.0.0.0',
    mysql_module => '2.3',
    database_idle_timeout => 50, # Important to avoid facing "MySQL server has gone away" while using HAProxy+Galera. Should be < HAProxy server timeout (default: 60s)
  }

  class { '::keystone::roles::admin':
    email => $admin_email,
    password => $admin_password,
    admin_tenant => 'admin',
  }

  class { 'keystone::endpoint':
    public_url => "http://${public_ipaddress}:5000",
    admin_url => "http://${admin_ipaddress}:35357",
    internal_url => "http://${admin_ipaddress}:5000",
    region => $region,
  }

  create_resources('iaas::resources::tenant', $tenants)
  create_resources('iaas::resources::user', $users)

  @@haproxy::balancermember { "keystone_admin_cluster_${::fqdn}":
    listening_service => 'keystone_admin_cluster',
    server_names => $::hostname,
    ipaddresses => $admin_ipaddress,
    ports => '35357',
    options => 'check inter 2000 rise 2 fall 5',
  }
  @@haproxy::balancermember { "keystone_public_internal_cluster_${::fqdn}":
    listening_service => 'keystone_public_internal_cluster',
    server_names => $::hostname,
    ipaddresses => $public_ipaddress,
    ports => '5000',
    options => 'check inter 2000 rise 2 fall 5',
  }
}
