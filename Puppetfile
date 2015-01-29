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

# Role Controller
mod 'puppetlabs-mysql', # This is only required because of https://github.com/michaeltchapman/puppet-galera/pull/22
    :git => 'https://github.com/puppetlabs/puppetlabs-mysql.git',
    :ref => '2.2.0'
mod 'michaeltchapman-galera',
    :git => 'https://github.com/michaeltchapman/puppet-galera.git'
mod 'garethr-erlang', # Required by rabbitmq
    :git => 'https://github.com/garethr/garethr-erlang.git'
mod 'puppetlabs-rabbitmq',
    :git => 'https://github.com/puppetlabs/puppetlabs-rabbitmq.git'

# Role Storage
mod 'stackforge-ceph',
    :git => 'https://github.com/stackforge/puppet-ceph.git'

# Role Endpoint
mod 'puppetlabs-haproxy',
    :git => 'https://github.com/puppetlabs/puppetlabs-haproxy.git'
