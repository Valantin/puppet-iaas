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
    password         => $password,
    public_address   => $endpoint,
    admin_address    => $endpoint,
    internal_address => $endpoint,
    region           => $region,
  }

  # Run Heat w/ Keystone V2
  package { 'git':
    name => 'git',
    ensure => 'present'
  }
  exec { 'heat_keystoneclient_v2':
    command => 'git clone https://github.com/openstack/heat.git /tmp/heat && cd /tmp/heat/contrib/heat_keystoneclient_v2/ && python setup.py install && rm -rf /tmp/heat',
    creates => '/usr/local/lib/heat/heat_keystoneclient_v2',
    require => Package['git'],
  }
  heat_config {
    'DEFAULT/plugin_dirs': value => "=/usr/lib64/heat,/usr/lib/heat,/usr/local/lib/heat";
    'DEFAULT/keystone_backend': value => "heat.engine.plugins.heat_keystoneclient_v2.client.KeystoneClientV2";
  }

  class { '::heat':
    database_connection => $iaas::resources::connectors::heat,
    rabbit_host         => $endpoint,
    rabbit_userid       => $rabbitmq_user,
    rabbit_password     => $rabbitmq_password,
    keystone_host       => $endpoint,
    keystone_password   => $password,
    mysql_module        => '2.3',
    database_idle_timeout => 3,
  }

  class { '::heat::api':
    bind_host => $::facts["ipaddress_${public_interface}"],
  }

  class { '::heat::engine':
    auth_encryption_key => $encryption_key,
  }

  @@haproxy::balancermember { "heat_api_${::fqdn}":
    listening_service => 'heat_api_cluster',
    server_names => $::hostname,
    ipaddresses => $::facts["ipaddress_${public_interface}"],
    ports => '8004',
    options => 'check inter 2000 rise 2 fall 5',
  }
}
