class iaas::profile::nova::controller (
  $password = undef,
  $public_ipaddress = hiera('iaas::public_ipaddress', undef),
  $admin_ipaddress = hiera('iaas::admin_ipaddress', undef),

  $neutron_secret = hiera('iaas::profile::neutron::secret', undef),
  $neutron_password = hiera('iaas::profile::neutron::password', undef),

  $region = hiera('iaas::region', undef),
  $endpoint = hiera('iaas::role::endpoint::main_address', undef),
  $rabbitmq_user = hiera('iaas::profile::rabbitmq::user', undef),
  $rabbitmq_password = hiera('iaas::profile::rabbitmq::password', undef),
) {
  include iaas::resources::connectors
  iaas::resources::database { 'nova': }

  include iaas::profile::nova::common

  class { '::nova::keystone::auth':
    password => $password,
    public_address => $public_ipaddress,
    admin_address => $admin_ipaddress,
    internal_address => $admin_ipaddress,
    region => $region,
  }

  class { '::nova::api':
    enabled => true,
    admin_password => $password,
    auth_host => $endpoint,
    neutron_metadata_proxy_shared_secret => $neutron_secret,
  }

  class { '::nova::vncproxy':
    enabled => true,
    host => $admin_ipaddress,
  }

  class { [ 'nova::scheduler', 'nova::consoleauth', 'nova::conductor']:
    enabled => true,
  }

  @@haproxy::balancermember { "nova_api_${::fqdn}":
    listening_service => 'nova_api_cluster',
    server_names => $::hostname,
    ipaddresses => $public_ipaddress,
    ports => '8774',
    options => 'check inter 2000 rise 2 fall 5',
  }

  @@haproxy::balancermember { "nova_novncproxy_${::fqdn}":
    listening_service => 'nova_novncproxy',
    server_names => $::hostname,
    ipaddresses => $public_ipaddress,
    ports => '6080',
    options => 'check inter 2000 rise 2 fall 5',
  }
}
