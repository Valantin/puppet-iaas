class iaas::profile::nova::controller (
  $password = undef,
  $public_interface = hiera('iaas::public_interface', undef),
  $admin_interface = hiera('iaas::admin_interface', undef),

  $neutron_secret = hiera('iaas::profile::neutron::secret', undef),
  $neutron_password = hiera('iaas::profile::neutron::password', undef),

  $region = hiera('iaas::region', undef),
  $endpoint = hiera('iaas::role::endpoint::main_address', undef),
) {
  include iaas::resources::connectors
  iaas::resources::database { 'nova': }

  include iaas::profile::nova::common

  class { '::nova::keystone::auth':
    password => $password,
    public_address => $endpoint,
    admin_address => $endpoint,
    internal_address => $endpoint,
    region => $region,
  }

  class { '::nova::api':
    enabled => true,
    admin_password => $password,
    auth_uri => "http://${endpoint}:5000/v2.0",
    identity_uri => "http://${endpoint}:35357",
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
    ports => '8774',
    options => 'check inter 2000 rise 2 fall 5',
  }

  @@haproxy::balancermember { "nova_metadata_api_${::fqdn}":
    listening_service => 'nova_metadata_api_cluster',
    server_names => $::hostname,
    ipaddresses => $::facts["ipaddress_${admin_interface}"],
    ports => '8775',
    options => 'check inter 2000 rise 2 fall 5',
  }

  @@haproxy::balancermember { "nova_novncproxy_${::fqdn}":
    listening_service => 'nova_novncproxy',
    server_names => $::hostname,
    ipaddresses => $::facts["ipaddress_${public_interface}"],
    ports => '6080',
    options => 'check inter 2000 rise 2 fall 5',
  }
}
