#!/usr/bin/env ruby
#^syntax detection

forge "git://forge.puppetlabs.com"

# Role base
mod 'ntp',
    :git => 'git://github.com/puppetlabs/puppetlabs-ntp'
mod 'concat', #Required by ssh
    :git => 'git://github.com/puppetlabs/puppetlabs-concat'
mod 'ssh',
    :git => 'git://github.com/saz/puppet-ssh'
mod 'resolv_conf',
    :git => 'git://github.com/saz/puppet-resolv_conf'
mod 'locales',
    :git => 'git://github.com/saz/puppet-locales'
mod 'kmod',
    :git => 'git://github.com/camptocamp/puppet-kmod'
mod 'network',
    :git => 'git://github.com/puppet-community/puppet-network'
mod 'apt',
    :git => 'git://github.com/puppetlabs/puppetlabs-apt'
mod 'inifiles',
    :git => 'git://github.com/puppetlabs/puppetlabs-inifile'
mod 'xinetd',
    :git => 'git://github.com/puppetlabs/puppetlabs-xinetd'
mod 'staging',
    :git => 'git://github.com/nanliu/puppet-staging'
mod 'stdlib',
    :git => 'git://github.com/puppetlabs/puppetlabs-stdlib'

# Role Controller
mod 'mysql', # Required by galera
    :git => 'git://github.com/puppetlabs/puppetlabs-mysql',
    :ref => '2.3.0' # This is only required because of git://github.com/michaeltchapman/puppet-galera/pull/22
mod 'galera',
    :git => 'git://github.com/michaeltchapman/puppet-galera'
mod 'erlang', # Required by rabbitmq
    :git => 'git://github.com/garethr/garethr-erlang'
mod 'rabbitmq',
    :git => 'git://github.com/puppetlabs/puppetlabs-rabbitmq'
mod 'apache', #Required by horizon
    :git => 'git://github.com/puppetlabs/puppetlabs-apache'
mod 'deric/zookeeper',
    :git => 'git://github.com/deric/puppet-zookeeper'
mod 'richardc/datacat', #Required by zookeeper
    :git => 'git://github.com/richardc/puppet-datacat'

# Role Storage
mod 'ceph',
    :git => 'git://github.com/stackforge/puppet-ceph'

# Role Endpoint
mod 'haproxy',
    :git => 'git://github.com/puppetlabs/puppetlabs-haproxy'
mod 'sysctl',
    :git => 'git://github.com/thias/puppet-sysctl'

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
  :git => "git://github.com/puppetlabs/puppetlabs-vcsrepo",
  :ref => "master"

mod "tempest",
  :git => "git://github.com/stackforge/puppet-tempest",
  :ref => "master"

mod "vswitch",
  :git => "git://github.com/stackforge/puppet-vswitch",
  :ref => "master"
