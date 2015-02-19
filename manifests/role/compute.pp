class iaas::role::compute (

) {
  class { 'iaas::profile::base': } ->
  class { 'iaas::profile::neutron::client': }
  class { 'iaas::profile::nova::compute': } # ->
}
