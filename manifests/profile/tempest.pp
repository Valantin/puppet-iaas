class iaas::profile::tempest (
  $admin_user = undef,
  $user = undef,
  $alt_user = undef,
  $image_id = undef,
  $alt_image_id = undef,
  $flavor_ref = undef,
  $alt_flavor_ref = undef,
  $image_ssh_user = undef,
  $alt_image_ssh_user = undef,
  $public_network_id = undef,

  $neutron_password = hiera('iaas::profile::neutron::password', undef),
  $glance_password = hiera('iaas::profile::glance::password', undef),
  $rabbitmq_user = hiera('iaas::profile::rabbitmq::user', undef),
  $rabbitmq_password = hiera('iaas::profile::rabbitmq::password', undef),

  $endpoint = hiera('iaas::role::endpoint::main_address', undef),
  $region = hiera('iaas::region', undef),

  $users = hiera('iaas::profile::keystone::users', undef),
) {
  package { 'python-openstackclient':
    ensure => present,
  }

  ########################################################################
  class { '::neutron':
    allow_overlapping_ips => true,
    rabbit_host => $endpoint,
    rabbit_user => $rabbitmq_user,
    rabbit_password => $rabbitmq_password,
  }

  class { '::neutron::keystone::auth':
    password => $neutron_password,
    public_address => $endpoint,
    admin_address => $endpoint,
    internal_address => $endpoint,
    region => $region,
  }

  class { '::neutron::server':
    auth_uri => "http://${endpoint}:5000/v2.0",
    identity_uri => "http://${endpoint}:35357",
    auth_password       => $neutron_password,
    enabled             => false,
    sync_db             => false,
    mysql_module        => '2.3',
  }
  ########################################################################

  class { '::glance::api':
    keystone_password => $glance_password,
    auth_uri => "http://${endpoint}:5000/v2.0",
    identity_uri => "http://${endpoint}:35357",
    registry_host => $endpoint,
    os_region_name => $region,
  }

  class { '::tempest':
    setup_venv => true,
    tempest_repo_revision => 'master',

    cinder_available => true,
    glance_available => true,
    heat_available => true,
    horizon_available => true,
    neutron_available => true,
    nova_available => true,
    swift_available => false,
    ceilometer_available => true,
    
    configure_images => true,
    image_ref => $image_id,
    image_ref_alt => $alt_image_id,
    image_ssh_user => $image_ssh_user,
    image_alt_ssh_user => $alt_image_ssh_user,
    flavor_ref => $flavor_ref,
    flavor_ref_alt => $alt_flavor_ref,

    configure_networks => 'true',
    public_network_id => $public_network_id,

    identity_uri => "http://${endpoint}:5000/v2.0",
    admin_username => $admin_user,
    admin_password => $users[$admin_user]['password'],
    admin_tenant_name => $users[$admin_user]['tenant'],
    username => $user,
    password => $users[$user]['password'],
    tenant_name => $users[$user]['tenant'],
    alt_username => $alt_user,
    alt_password => $users[$alt_user]['password'],
    alt_tenant_name => $users[$alt_user]['tenant'],
  }

  Tempest_config {
    path    => $::tempest::tempest_conf,
    require => File[$::tempest::tempest_conf],
  }

  tempest_config {
    'oslo_concurrency/lock_path': value => "lock";

    'dashboard/dashboard_url': value => "http://${endpoint}/horizon";
    'dashboard/login_url':     value => "http://${endpoint}/horizon/auth/login/";

    'identity-feature-enabled/api_v3': value => "false";
    'identity/region': value => $region;

    'boto/s3_url': value => "";
    'boto/ec2_url': value => "";
  }
}
