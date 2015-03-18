class iaas::profile::neutron::server (
  $public_interface = hiera('iaas::public_interface', undef),
  $admin_interface = hiera('iaas::admin_interface', undef),

  $neutron_password = hiera('iaas::profile::neutron::password', undef),
  $nova_password = hiera('iaas::profile::nova::controller::password', undef),

  $region = hiera('iaas::region', undef),
  $endpoint = hiera('iaas::role::endpoint::main_address', undef),
) {
  include iaas::resources::connectors
  iaas::resources::database { 'neutron': }

  include iaas::profile::neutron::common

  class { '::neutron::server':
    auth_uri => "http://${endpoint}:5000/v2.0",
    identity_uri => "http://${endpoint}:35357",
    auth_password => $neutron_password,
    database_connection => $iaas::resources::connectors::neutron,
    enabled => true,
    sync_db => true,
    mysql_module => '2.3',
    l3_ha => true,
    allow_automatic_l3agent_failover => true,
  }

  class { '::neutron::keystone::auth':
    password => $neutron_password,
    public_address => $endpoint,
    admin_address => $endpoint,
    internal_address => $endpoint,
    region => $region,
  }

  class { '::neutron::server::notifications':
    nova_url => "http://${endpoint}:8774/v2",
    nova_admin_auth_url => "http://${endpoint}:35357/v2.0",
    nova_admin_password => $nova_password,
    nova_region_name    => $region,
  }

  @@haproxy::balancermember { "neutron_api_${::fqdn}":
      listening_service => 'neutron_api_cluster',
      server_names => $::hostname,
      ipaddresses => $::facts["ipaddress_${public_interface}"],
      ports => '9696',
      options => 'check inter 2000 rise 2 fall 5',
    }
}
