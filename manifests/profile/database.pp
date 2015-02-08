class iaas::profile::database (
  $servers = undef,
  $galera_master = undef,
  $galera_password = undef,
) {
  class { 'galera':
    galera_servers => $servers,
    galera_master => $galera_master,
    root_password => $galera_password,
    configure_firewall => false,
  } -> Service['mysqld'] -> anchor { 'database-service': }

  @@haproxy::balancermember { "galera_${::fqdn}":
    listening_service => 'galera',
    server_names      => $::hostname,
    ipaddresses       => $::ipaddress,
    ports             => '3306',
    options           => 'check port 9200 inter 2000 rise 2 fall 5',
  }
}
