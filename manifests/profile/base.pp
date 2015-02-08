class iaas::profile::base (
  $ipaddress,
  $netmask,
  $gateway,
  $dns_servers,
  $dns_searchdomain,
  $ssh_public_key,
  $ntp_servers
) {
  # Apt repo
  apt::source { 'ubuntu-cloud-archive':
    location => 'http://ubuntu-cloud.archive.canonical.com/ubuntu',
    release => "${::lsbdistcodename}-updates/juno",
    repos => 'main',
    required_packages => 'ubuntu-cloud-keyring',
  } -> exec { "apt_upgrade":
    command => "apt-get update && apt-get -y upgrade"
  }

  # Locales
  class { 'locales':
    default_locale  => 'en_US.UTF-8',
    locales         => ['en_US.UTF-8 UTF-8'],
    lc_ctype => 'en_US.UTF-8'
  }

  # VLAN module
  package { 'vlan': }
  kmod::load {'8021q':
    require => Package['vlan']
  }

  # NTP
  class { '::ntp':
    servers => $ntp_servers,
    restrict => ['127.0.0.1'],
  }

  # Network
  package { 'ifupdown-extra': } ->
  network_config { "eth0":
    ensure => 'present',
    family => 'inet',
    method => 'static',
    ipaddress => $ipaddress,
    netmask => $netmask,
  } ~>
  network_route { 'route_default':
    ensure => 'present',
    gateway => $gateway,
    interface => 'eth0',
    netmask => '0.0.0.0',
    network => 'default'
  } ~>
  exec { "ifup_eth0":
    command => "ifdown eth0 && ifup eth0"
  }

  class { 'resolv_conf':
    nameservers => $dns_servers,
    domainname  => $dns_searchdomain,
  }

  # SSH
  class { 'ssh::server':
    storeconfigs_enabled => false,
    options => {
      'PermitRootLogin'        => 'yes',
      'Port'                   => [22],
    }
  } ~>
  exec { 'sshd_restart':
    command => '/etc/init.d/ssh restart',
    returns => [0, 1]
  }
  file { "/root/.ssh":
    ensure => "directory",
    owner  => "root",
    group  => "root",
    mode   => 755,
  }
  file { '/root/.ssh/authorized_keys2':
    owner => root,
    group => root,
    mode => 644,
    content => $ssh_public_key
  }

  # Puppet
  service { "puppet":
    ensure => "running",
  }
}
