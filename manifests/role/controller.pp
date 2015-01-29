class iaas::role::controller (
  $servers = undef,
  $server_hosts = undef,
  $galera_master = undef,
  $galera_password = undef,
  $rabbitmq_user = undef,
  $rabbitmq_password = undef,
  $rabbitmq_erlang = undef,
) {
  # Base
  class { 'iaas::profile::base': } ->

  # Galera MySQL
  class { 'galera':
    galera_servers => $servers,
    galera_master => $galera_master,
    root_password => $galera_password,
    configure_firewall => false,
  } ->

  # RabbitMQ
  class {'erlang': } ->
  package { 'erlang-base':
    ensure => 'latest',
  } ->
  class { '::rabbitmq':
    service_ensure => 'running',
    port => 5672,
    delete_guest_user => true,
    config_cluster => true,
    cluster_nodes => $server_hosts,
    erlang_cookie => $rabbitmq_erlang,
    cluster_node_type => 'ram',
    wipe_db_on_cookie_change => true,
    cluster_partition_handling => 'pause_minority',
  } ->
  rabbitmq_user { $rabbitmq_user:
    admin => true,
    password => $rabbitmq_password,
    provider => 'rabbitmqctl',
  } ->
  rabbitmq_user_permissions { "${rabbitmq_user}@/":
    configure_permission => '.*',
    write_permission => '.*',
    read_permission => '.*',
    provider => 'rabbitmqctl',
  } -> # -> Anchor<| title == 'nova-start' |> ->

  # Memcached
  class { 'memcached': } #->

  ####################################################################################################
  ####################################################################################################
  ####################################################################################################

  # To a storage client : ceph::profile::client & ceph::keys to get keyrings in /etc/ceph/ceph.$key_name

  # Export for clients who need a balanced service
  #@@haproxy::balancermember { $::fqdn:
  #  listening_service => 'puppet00',
  #  server_names      => $::hostname,
  #  ipaddresses       => $::ipaddress,
  #  ports             => '8140',
  #  options           => 'check',
  #}
}
