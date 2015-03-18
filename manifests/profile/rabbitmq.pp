class iaas::profile::rabbitmq (
  $admin_interface = hiera('iaas::admin_interface', undef),

  $servers = undef,
  $user = undef,
  $password = undef,
  $erlang = undef,
) {
  class {'erlang': } ->
  package { 'erlang-base':
    ensure => 'latest',
  } ->
  class { '::rabbitmq':
    service_ensure => 'running',
    port => 5672,
    delete_guest_user => true,
    config_cluster => true,
    cluster_nodes => $servers,
    erlang_cookie => $erlang,
    cluster_node_type => 'ram',
    wipe_db_on_cookie_change => true,
    cluster_partition_handling => 'pause_minority',
    tcp_keepalive => true, #FIXME May cause connectivity issues with OpenStack in some configurations
  } ->
  rabbitmq_user { $user:
    admin => true,
    password => $password,
    provider => 'rabbitmqctl',
  } ->
  rabbitmq_user_permissions { "${user}@/":
    configure_permission => '.*',
    write_permission => '.*',
    read_permission => '.*',
    provider => 'rabbitmqctl',
  } ->
  exec { 'rabbitmq_ha_queues':
    command => "rabbitmqctl set_policy ha-all \"^.*\" \'{\"ha-mode\":\"all\"}\'",
    unless => "rabbitmqctl list_policies | grep ha-all"
  }

  @@haproxy::balancermember { "rabbitmq_${::fqdn}":
    listening_service => 'rabbitmq',
    server_names => $::hostname,
    ipaddresses => $::facts["ipaddress_${admin_interface}"],
    ports => '5672',
    options => 'check inter 2000 rise 2 fall 5',
  }
}
