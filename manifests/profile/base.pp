class iaas::profile::base (
  $dns_servers,
  $dns_searchdomain,
  $ssh_public_key,
  $ntp_servers,
) {
  # Keep-alive values
  sysctl { 'net.ipv4.tcp_keepalive_time': value => '30' }
  sysctl { 'net.ipv4.tcp_keepalive_intvl': value => '15' }

  # Ubuntu repository for OpenStack Juno
  apt::source { 'ubuntu-cloud-archive':
    location => 'http://ubuntu-cloud.archive.canonical.com/ubuntu',
    release => "${::lsbdistcodename}-updates/juno",
    repos => 'main',
    required_packages => 'ubuntu-cloud-keyring',
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
}
