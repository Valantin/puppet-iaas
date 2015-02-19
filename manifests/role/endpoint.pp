class iaas::role::endpoint (

) {
  class { 'iaas::profile::base': }
  class { 'iaas::profile::haproxy': }
}
