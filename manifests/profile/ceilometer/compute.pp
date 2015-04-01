class iaas::profile::ceilometer::compute (
  $password = hiera('iaas::profile::ceilometer::password', undef),
  $endpoint = hiera('iaas::role::endpoint::main_address', undef),
) {
  include iaas::profile::ceilometer::common
  class { '::ceilometer::agent::compute': }
}
