class iaas::profile::ceilometer::common (
  $secret = hiera('iaas::profile::ceilometer::secret', undef),

  $password = hiera('iaas::profile::ceilometer::password', undef),
  $region = hiera('iaas::region', undef),

  $rabbitmq_user = hiera('iaas::profile::rabbitmq::user', 'guest'),
  $rabbitmq_password = hiera('iaas::profile::rabbitmq::password', 'guest'),
  $rabbitmq_hosts = hiera('iaas::profile::rabbitmq::hosts', '127.0.0.1'),
  $rabbitmq_port = hiera('iaas::profile::rabbitmq::port', '5672'),

  $public_address = hiera('iaas::profile::keystone::public_address', undef),
  $internal_address = hiera('iaas::profile::keystone::internal_address', undef),
  $admin_address = hiera('iaas::profile::keystone::admin_address', undef),
  $public_port = hiera('iaas::profile::keystone::public_port', '5000'),
  $internal_port = hiera('iaas::profile::keystone::internal_port', '5000'),
  $admin_port = hiera('iaas::profile::keystone::admin_port', '35357'),
) {
  class { '::ceilometer':
    metering_secret => $secret,
    rabbit_userid => $rabbitmq_user,
    rabbit_password => $rabbitmq_password,
    rabbit_hosts => [$rabbitmq_hosts],
    rabbit_port => $rabbitmq_port,
  }

  class { '::ceilometer::agent::auth':
    auth_url => "http://${public_address}:${public_port}/v2.0",
    auth_password => $password,
    auth_region => $region,
  }

  # Change default polling interval from 10min to 0.5m for all sources
  exec { 'ceilometer_pipeline_interval':
    command => "sed -i 's/interval: 600$/interval: 30/' /etc/ceilometer/pipeline.yaml",
  }
}
