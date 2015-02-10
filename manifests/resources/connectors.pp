class iaas::resources::connectors {
  $endpoint = hiera('iaas::role::endpoint::main_address', '127.0.0.1')

  $user_keystone = hiera('iaas::mysql::keystone::user', 'keystone')
  $pass_keystone = hiera('iaas::mysql::keystone::password', 'keystone')
  $keystone = "mysql://${user_keystone}:${pass_keystone}@${endpoint}/keystone"

  $user_glance = hiera('iaas::mysql::glance::user', 'glance')
  $pass_glance = hiera('iaas::mysql::glance::password', 'glance')
  $glance = "mysql://${user_glance}:${pass_glance}@${endpoint}/glance"

  $user_cinder = hiera('iaas::mysql::cinder::user', 'cinder')
  $pass_cinder = hiera('iaas::mysql::cinder::password', 'cinder')
  $cinder = "mysql://${user_cinder}:${pass_cinder}@${endpoint}/cinder"

  $user_nova = hiera('iaas::mysql::nova::user', 'nova')
  $pass_nova = hiera('iaas::mysql::nova::password', 'nova')
  $nova = "mysql://${user_nova}:${pass_nova}@${endpoint}/nova"

  $user_neutron = hiera('iaas::mysql::neutron::user', 'neutron')
  $pass_neutron = hiera('iaas::mysql::neutron::password', 'neutron')
  $neutron = "mysql://${user_neutron}:${pass_neutron}@${endpoint}/neutron"

  $user_heat = hiera('iaas::mysql::heat::user', 'heat')
  $pass_heat = hiera('iaas::mysql::heat::password', 'heat')
  $heat = "mysql://${user_heat}:${pass_heat}@${endpoint}/heat"
}
