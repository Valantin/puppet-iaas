#!/usr/bin/env ruby
#^syntax detection

forge "https://forge.puppetlabs.com"

# Role base
mod 'puppetlabs-ntp',
    :git => 'https://github.com/puppetlabs/puppetlabs-ntp.git'
mod 'saz-ssh',
    :git => 'https://github.com/saz/puppet-ssh.git'
mod 'saz-resolv_conf',
    :git => 'https://github.com/saz/puppet-resolv_conf.git'
mod 'saz-memcached',
    :git => 'https://github.com/saz/puppet-memcached.git'
mod 'saz-locales',
    :git => 'https://github.com/saz/puppet-locales.git'
mod 'camptocamp-kmod',
    :git => 'https://github.com/camptocamp/puppet-kmod.git'
mod 'adrien-network',
    :git => 'https://github.com/puppet-community/puppet-network.git'
mod 'puppetlabs-apt',
    :git => 'https://github.com/puppetlabs/puppetlabs-apt.git'

# Role Controller
mod 'puppetlabs-mysql',
    :git => 'https://github.com/puppetlabs/puppetlabs-mysql.git',
    :ref => '2.3.0' # This is only required because of https://github.com/michaeltchapman/puppet-galera/pull/22
mod 'michaeltchapman-galera',
    :git => 'https://github.com/michaeltchapman/puppet-galera.git'
mod 'garethr-erlang', # Required by rabbitmq
    :git => 'https://github.com/garethr/garethr-erlang.git'
mod 'puppetlabs-rabbitmq',
    :git => 'https://github.com/puppetlabs/puppetlabs-rabbitmq.git'
mod 'puppetlabs-apache', #Required by horizon
:git => 'https://github.com/puppetlabs/puppetlabs-apache.git'

# Role Storage
mod 'stackforge-ceph',
    :git => 'https://github.com/stackforge/puppet-ceph.git'

# Role Endpoint
mod 'puppetlabs-haproxy',
    :git => 'https://github.com/puppetlabs/puppetlabs-haproxy.git'

## The core OpenStack modules
mod "keystone",
  :git => "git://github.com/stackforge/puppet-keystone",
  :ref => "master"

mod "swift",
  :git => "git://github.com/stackforge/puppet-swift",
  :ref => "master"

mod "glance",
  :git => "git://github.com/stackforge/puppet-glance",
  :ref => "master"

mod "cinder",
  :git => "git://github.com/stackforge/puppet-cinder",
  :ref => "master"

mod "neutron",
  :git => "git://github.com/stackforge/puppet-neutron",
  :ref => "master"

mod "nova",
  :git => "git://github.com/stackforge/puppet-nova",
  :ref => "master"

mod "heat",
  :git => "git://github.com/stackforge/puppet-heat",
  :ref => "master"

mod "ceilometer",
  :git => "git://github.com/stackforge/puppet-ceilometer",
  :ref => "master"

mod "horizon",
  :git => "git://github.com/stackforge/puppet-horizon",
  :ref => "master"

mod "openstacklib",
  :git => "git://github.com/stackforge/puppet-openstacklib",
  :ref => "master"

mod "tempest",
  :git => "git://github.com/stackforge/puppet-tempest",
  :ref => "master"

mod "vswitch",
  :git => "git://github.com/stackforge/puppet-vswitch",
  :ref => "master"
