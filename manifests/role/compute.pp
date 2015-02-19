class iaas::role::compute (

) {
  class { 'iaas::profile::base': } ->
  class { 'iaas::profile::neutron::client': }
}
