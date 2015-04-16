class iaas::profile::ceilometer::common (
  $secret = hiera('iaas::profile::ceilometer::secret', undef),

  $password = hiera('iaas::profile::ceilometer::password', undef),
  $region = hiera('iaas::region', undef),
  $endpoint = hiera('iaas::role::endpoint::main_address', undef),
  $rabbitmq_user = hiera('iaas::profile::rabbitmq::user', undef),
  $rabbitmq_password = hiera('iaas::profile::rabbitmq::password', undef),
) {
  class { '::ceilometer':
    metering_secret => $secret,
    rabbit_hosts => [ $endpoint ],
    rabbit_userid => $rabbitmq_user,
    rabbit_password => $rabbitmq_password,
  }

  class { '::ceilometer::agent::auth':
    auth_url => "http://${endpoint}:5000/v2.0",
    auth_password => $password,
    auth_region => $region,
  }

  # Change default polling interval from 10min to 0.5m for all sources
  exec { 'ceilometer_pipeline_interval':
    command => "sed -i 's/interval: 600$/interval: 30/' /etc/ceilometer/pipeline.yaml",
  }
}
