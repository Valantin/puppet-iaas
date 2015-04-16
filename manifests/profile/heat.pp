class iaas::profile::heat (
  $password = undef,
  $encryption_key = undef,
  $public_interface = hiera('iaas::public_interface', undef),

  $region = hiera('iaas::region', undef),
  $endpoint = hiera('iaas::role::endpoint::main_address', undef),
  $rabbitmq_user = hiera('iaas::profile::rabbitmq::user', undef),
  $rabbitmq_password = hiera('iaas::profile::rabbitmq::password', undef),
) {
  include iaas::resources::connectors
  iaas::resources::database { 'heat': }

  class { '::heat::keystone::auth':
    password => $password,
    public_address => $endpoint,
    admin_address => $endpoint,
    internal_address => $endpoint,
    region => $region,
  }
  class { '::heat::keystone::auth_cfn':
    password => $password,
    public_address => $endpoint,
    admin_address => $endpoint,
    internal_address => $endpoint,
    region => $region,
  }

  class { '::heat':
    database_connection => $iaas::resources::connectors::heat,
    rabbit_host => $endpoint,
    rabbit_userid => $rabbitmq_user,
    rabbit_password => $rabbitmq_password,
    auth_uri => "http://${endpoint}:5000/v2.0",
    identity_uri => "http://${endpoint}:35357",
    keystone_password => $password,
    mysql_module => '2.3',
    database_idle_timeout => 3,
    region_name => $region,
  }

  class { '::heat::api': }
  class { '::heat::api_cfn': }
  class { '::heat::api_cloudwatch': }

  class { '::heat::engine':
    auth_encryption_key => $encryption_key,
  }

  file { "/usr/bin/heat-keystone-setup-domain":
      mode   => 550,
      owner  => root,
      group  => root,
      source => "puppet:///modules/iaas/heat-keystone-setup-domain"
  } ->
  class { 'heat::keystone::domain':
    auth_url => "http://${endpoint}:5000/v2.0",
    keystone_admin => "heat",
    keystone_password => $password,
    keystone_tenant   => "services",
    domain_name => 'heat',
    domain_admin => 'heat_admin',
    domain_password => 'heat_admin',
  }

  @@haproxy::balancermember { "heat_api_${::fqdn}":
    listening_service => 'heat_api_cluster',
    server_names => $::hostname,
    ipaddresses => $::facts["ipaddress_${public_interface}"],
    ports => '8004',
    options => 'check inter 2000 rise 2 fall 5',
  }

  @@haproxy::balancermember { "heat_api_cfn_${::fqdn}":
    listening_service => 'heat_api_cfn_cluster',
    server_names => $::hostname,
    ipaddresses => $::facts["ipaddress_${public_interface}"],
    ports => '8000',
    options => 'check inter 2000 rise 2 fall 5',
  }

  @@haproxy::balancermember { "heat_api_cw_${::fqdn}":
    listening_service => 'heat_api_cw_cluster',
    server_names => $::hostname,
    ipaddresses => $::facts["ipaddress_${public_interface}"],
    ports => '8003',
    options => 'check inter 2000 rise 2 fall 5',
  }
}
