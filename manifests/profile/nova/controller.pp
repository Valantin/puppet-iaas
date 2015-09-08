class iaas::profile::nova::controller (
  $password = undef,
  $public_interface = hiera('iaas::public_interface', undef),
  $admin_interface = hiera('iaas::admin_interface', undef),

  $neutron_secret = hiera('iaas::profile::neutron::secret', undef),
  $neutron_password = hiera('iaas::profile::neutron::password', undef),

  $region = hiera('iaas::region', undef),

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

  $nova_api = '8774',
  $nova_metadata_api = '8775',
  $nova_novncproxy = '6080',
) {

  include iaas::profile::nova::common

  class { '::nova::keystone::auth':
    password => $password,
    public_address => $public_address,
    admin_address => $admin_address,
    internal_address => $internal_address,
    region => $region,
  }

  class { '::nova::api':
    enabled => true,
    admin_password => $password,
    auth_uri => "http://${public_address}:${public_port}/v2.0",
    identity_uri => "http://${admin_address}:${admin_port}",
    neutron_metadata_proxy_shared_secret => $neutron_secret,
  }

  class { '::nova::vncproxy':
    enabled => true,
    host => $::facts["ipaddress_${admin_interface}"],
  }

  class { [ 'nova::scheduler', 'nova::consoleauth', 'nova::conductor', 'nova::cert']:
    enabled => true,
  }

  @@haproxy::balancermember { "nova_api_${::fqdn}":
    listening_service => 'nova_api_cluster',
    server_names => $::hostname,
    ipaddresses => $::facts["ipaddress_${public_interface}"],
    ports => "${nova_api}",
    options => 'check inter 2000 rise 2 fall 5',
  }

  @@haproxy::balancermember { "nova_metadata_api_${::fqdn}":
    listening_service => 'nova_metadata_api_cluster',
    server_names => $::hostname,
    ipaddresses => $::facts["ipaddress_${admin_interface}"],
    ports => "${nova_metadata_api}",
    options => 'check inter 2000 rise 2 fall 5',
  }

  @@haproxy::balancermember { "nova_novncproxy_${::fqdn}":
    listening_service => 'nova_novncproxy',
    server_names => $::hostname,
    ipaddresses => $::facts["ipaddress_${public_interface}"],
    ports => "${nova_novncproxy}",
    options => 'check inter 2000 rise 2 fall 5',
  }
}
