class iaas::profile::ceilometer::compute {
  include iaas::profile::ceilometer::common
  class { '::ceilometer::agent::compute': }
}
