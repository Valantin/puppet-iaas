class iaas::role::controller {
  # Base
  class { 'iaas::profile::base': } ->
  class { 'iaas::profile::database': } ->
  class { 'iaas::profile::rabbitmq': } ->
  class { 'memcached': } ->
  class { 'iaas::profile::keystone': } ->
  # class { 'iaas::profile::ceilometer::controller': } ->
  class { 'iaas::profile::glance': } ->
  class { 'iaas::profile::cinder': } ->
  class { 'iaas::profile::nova::controller': } ->
  class { 'iaas::profile::neutron::server': }
}
