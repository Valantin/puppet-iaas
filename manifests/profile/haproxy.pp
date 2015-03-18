class iaas::profile::haproxy (
  $stats_enabled = undef,
  $stats_ports = undef,
  $stats_refresh = undef,
  $stats_login = undef,
  $stats_password = undef,
  $stats_uri = undef,
) {
  class { '::haproxy':
    defaults_options => {
      'retries' => '3',
      'timeout' => [
        'http-request 10s',
        'queue 24h',
        'connect 10s',
        'client 24h',
        'server 24h',
        'check 10s',
      ],
      'maxconn' => '8048',
    },
  }

  if stats_enabled {
    haproxy::listen { 'stats':
      ipaddress => '0.0.0.0',
      mode => 'http',
      ports => $stats_ports,
      options => {
        'stats' => [
          'enable',
          'hide-version',
          "refresh ${stats_refresh}",
          'show-node',
          "auth ${stats_login}:${stats_password}",
          "uri ${stats_uri}"
        ],
      }
    }
  }

  haproxy::listen { 'galera':
    ipaddress => '0.0.0.0',
    mode => 'tcp',
    ports => '3306',
    options => {
      'option' => ['httpchk'],
      'balance' => 'source',
    }
  }

  haproxy::listen { 'rabbitmq':
    ipaddress => '0.0.0.0',
    mode => 'tcp',
    ports => '5672',
    options => {
      'option' => ['tcpka'],
      'balance' => 'source',
    }
  }

  haproxy::listen { 'keystone_admin_cluster':
    ipaddress => '0.0.0.0',
    mode => 'tcp',
    ports => '35357',
    options => {
      'option' => ['tcpka', 'httpchk', 'tcplog'],
      'balance' => 'source',
    }
  }

  haproxy::listen { 'keystone_public_internal_cluster':
    ipaddress => '0.0.0.0',
    mode => 'tcp',
    ports => '5000',
    options => {
      'option' => ['tcpka', 'httpchk', 'tcplog'],
      'balance' => 'source',
    }
  }

  haproxy::listen { 'glance_api_cluster':
    ipaddress => '0.0.0.0',
    mode => 'tcp',
    ports => '9292',
    options => {
      'option' => ['tcpka', 'httpchk', 'tcplog'],
      'balance' => 'source',
    }
  }

  haproxy::listen { 'glance_registry_cluster':
    ipaddress => '0.0.0.0',
    mode => 'tcp',
    ports => '9191',
    options => {
      'option' => ['tcpka', 'httpchk', 'tcplog'],
      'balance' => 'source',
    }
  }

  haproxy::listen { 'cinder_api_cluster':
    ipaddress => '0.0.0.0',
    mode => 'tcp',
    ports => '8776',
    options => {
      'option' => ['tcpka', 'httpchk', 'tcplog'],
      'balance' => 'source',
    }
  }

  haproxy::listen { 'nova_api_cluster':
    ipaddress => '0.0.0.0',
    mode => 'tcp',
    ports => '8774',
    options => {
      'option' => ['tcpka', 'httpchk', 'tcplog'],
      'balance' => 'source',
    }
  }

  haproxy::listen { 'nova_metadata_api_cluster':
    ipaddress => '0.0.0.0',
    ports => '8775',
    options => {
      'option' => ['tcpka', 'httpchk', 'tcplog'],
      'balance' => 'source',
    }
  }

  haproxy::listen { 'nova_novncproxy':
    ipaddress => '0.0.0.0',
    mode => 'tcp',
    ports => '6080',
    options => {
      'option' => ['tcpka', 'tcplog'],
      'balance' => 'source',
    }
  }

  haproxy::listen { 'neutron_api_cluster':
    ipaddress => '0.0.0.0',
    mode => 'tcp',
    ports => '9696',
    options => {
      'option' => ['tcpka', 'httpchk', 'tcplog'],
      'balance' => 'source',
    }
  }

  haproxy::listen { 'heat_api_cluster':
    ipaddress => '0.0.0.0',
    mode => 'tcp',
    ports => '8004',
    options => {
      'option' => ['tcpka', 'httpchk', 'tcplog'],
      'balance' => 'source',
    }
  }

  haproxy::listen { 'horizon_cluster':
    ipaddress => '0.0.0.0',
    mode => 'http',
    ports => '80',
    options => {
      'option' => ['tcpka', 'httpchk', 'tcplog'],
      'balance' => 'source',
    }
  }
}
