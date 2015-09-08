class iaas::profile::heat (
  $password = undef,
  $encryption_key = undef,
  $public_interface = hiera('iaas::public_interface', undef),

  $region = hiera('iaas::region', undef),
  $endpoint = hiera('iaas::role::endpoint::main_address', undef),

  $rabbitmq_user = hiera('iaas::profile::rabbitmq::user', 'guest'),
  $rabbitmq_password = hiera('iaas::profile::rabbitmq::password', 'guest'),
  $rabbitmq_hosts = hiera('iaas::profile::rabbitmq::hosts', '127.0.0.1'),
  $rabbitmq_port = hiera('iaas::profile::rabbitmq::port', '5672'),
  
  $db_user = hiera('iaas::mysql::heat::user', 'heat'),
  $db_password = hiera('iaas::mysql::heat::password', undef),
  $db_address = hiera('iaas::mysql::heat::host', undef),


  $public_address = hiera('iaas::profile::keystone::public_address', undef),
  $internal_address = hiera('iaas::profile::keystone::internal_address', undef),
  $admin_address = hiera('iaas::profile::keystone::admin_address', undef),
  $public_port = hiera('iaas::profile::keystone::public_port', '5000'),
  $internal_port = hiera('iaas::profile::keystone::internal_port', '5000'),
  $admin_port = hiera('iaas::profile::keystone::admin_port', '35357'),

  $heat_api = '8004',
  $heat_api_cnf = '8000',
  $heat_api_cw = '8003',
) {

  class { '::heat::keystone::auth':
    password => $password,
    public_address => $public_address,
    admin_address => $admin_address,
    internal_address => $internal_address,
    region => $region,
  }
  class { '::heat::keystone::auth_cfn':
    password => $password,
    public_address => $public_address,
    admin_address => $admin_address,
    internal_address => $internal_address,
    region => $region,
  }

  class { '::heat':
    database_connection => "mysql://${db_user}:${db_password}@${db_address}/heat",
    rabbit_userid => $rabbitmq_user,
    rabbit_password => $rabbitmq_password,
    rabbit_hosts => $rabbitmq_hosts,
    rabbit_port => $rabbitmq_port,
    auth_uri => "http://${public_address}:${public_port}/v2.0",
    identity_uri => "http://${admin_address}:${admin_port}",
    keystone_password => $password,
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
    auth_url => "http://${public_address}:${public_port}/v2.0",
    keystone_password => $password,
    domain_name => 'heat',
    domain_admin => 'heat_admin',
    domain_password => 'heat_admin',
  }

  @@haproxy::balancermember { "heat_api_${::fqdn}":
    listening_service => 'heat_api_cluster',
    server_names => $::hostname,
    ipaddresses => $::facts["ipaddress_${public_interface}"],
    ports => "${heat_api}",
    options => 'check inter 2000 rise 2 fall 5',
  }

  @@haproxy::balancermember { "heat_api_cfn_${::fqdn}":
    listening_service => 'heat_api_cfn_cluster',
    server_names => $::hostname,
    ipaddresses => $::facts["ipaddress_${public_interface}"],
    ports => "${heat_api_cfn}",
    options => 'check inter 2000 rise 2 fall 5',
  }

  @@haproxy::balancermember { "heat_api_cw_${::fqdn}":
    listening_service => 'heat_api_cw_cluster',
    server_names => $::hostname,
    ipaddresses => $::facts["ipaddress_${public_interface}"],
    ports => "${heat_api_cw}",
    options => 'check inter 2000 rise 2 fall 5',
  }
}
