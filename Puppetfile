#!/usr/bin/env ruby
#^syntax detection

forge "https://forge.puppetlabs.com"

# Role base
mod 'ntp',
    :git => 'https://github.com/puppetlabs/puppetlabs-ntp.git'
mod 'concat', #Required by ssh
    :git => 'https://github.com/puppetlabs/puppetlabs-concat.git'
mod 'ssh',
    :git => 'https://github.com/saz/puppet-ssh.git'
mod 'resolv_conf',
    :git => 'https://github.com/saz/puppet-resolv_conf.git'
mod 'memcached',
    :git => 'https://github.com/saz/puppet-memcached.git'
mod 'locales',
    :git => 'https://github.com/saz/puppet-locales.git'
mod 'kmod',
    :git => 'https://github.com/camptocamp/puppet-kmod.git'
mod 'network',
    :git => 'https://github.com/puppet-community/puppet-network.git'
mod 'apt',
    :git => 'https://github.com/puppetlabs/puppetlabs-apt.git'
mod 'inifiles',
    :git => 'https://github.com/puppetlabs/puppetlabs-inifile.git'
mod 'xinetd',
    :git => 'https://github.com/puppetlabs/puppetlabs-xinetd.git'
mod 'staging',
    :git => 'https://github.com/nanliu/puppet-staging.git'
mod 'stdlib',
    :git => 'https://github.com/puppetlabs/puppetlabs-stdlib.git'

# Role Controller
mod 'mysql', # Required by galera
    :git => 'https://github.com/puppetlabs/puppetlabs-mysql.git',
    :ref => '2.3.0' # This is only required because of https://github.com/michaeltchapman/puppet-galera/pull/22
mod 'galera',
    :git => 'https://github.com/michaeltchapman/puppet-galera.git'
mod 'erlang', # Required by rabbitmq
    :git => 'https://github.com/garethr/garethr-erlang.git'
mod 'rabbitmq',
    :git => 'https://github.com/puppetlabs/puppetlabs-rabbitmq.git'
mod 'apache', #Required by horizon
:git => 'https://github.com/puppetlabs/puppetlabs-apache.git'

# Role Storage
mod 'ceph',
    :git => 'https://github.com/stackforge/puppet-ceph.git'

# Role Endpoint
mod 'haproxy',
    :git => 'https://github.com/puppetlabs/puppetlabs-haproxy.git'
mod 'sysctl',
    :git => 'https://github.com/thias/puppet-sysctl.git'

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

mod "vcsrepo", # Required by Tempest
  :git => "git://github.com/puppetlabs/puppetlabs-vcsrepo.git",
  :ref => "master"

mod "tempest",
  :git => "git://github.com/stackforge/puppet-tempest",
  :ref => "master"

mod "vswitch",
  :git => "git://github.com/stackforge/puppet-vswitch",
  :ref => "master"
