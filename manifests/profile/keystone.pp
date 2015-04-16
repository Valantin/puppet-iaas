class iaas::profile::keystone (
  $admin_token = undef,
  $admin_email = undef,
  $admin_password = undef,
  $tenants = undef,
  $users = undef,

  $public_interface = hiera('iaas::public_interface', undef),
  $admin_interface = hiera('iaas::admin_interface', undef),

  $region = hiera('iaas::region', undef),
  $endpoint = hiera('iaas::role::endpoint::main_address', undef),
) {
  iaas::resources::database { 'keystone': }

  include iaas::resources::connectors
  class { '::keystone':
    admin_token => $admin_token,
    database_connection => $iaas::resources::connectors::keystone,
    admin_bind_host => '0.0.0.0',
    mysql_module => '2.3',
    database_idle_timeout => 3,
  }

  class { 'keystone::endpoint':
    public_url => "http://${endpoint}:5000",
    admin_url => "http://${endpoint}:35357",
    internal_url => "http://${endpoint}:5000",
    region => $region,
  }

  create_resources('iaas::resources::tenant', $tenants)
  create_resources('iaas::resources::user', $users)

  @@haproxy::balancermember { "keystone_admin_cluster_${::fqdn}":
    listening_service => 'keystone_admin_cluster',
    server_names => $::hostname,
    ipaddresses => $::facts["ipaddress_${admin_interface}"],
    ports => '35357',
    options => 'check inter 2000 rise 2 fall 5',
  }

  @@haproxy::balancermember { "keystone_public_internal_cluster_${::fqdn}":
    listening_service => 'keystone_public_internal_cluster',
    server_names => $::hostname,
    ipaddresses => $::facts["ipaddress_${public_interface}"],
    ports => '5000',
    options => 'check inter 2000 rise 2 fall 5',
  }
}
