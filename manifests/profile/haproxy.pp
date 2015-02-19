class iaas::profile::haproxy {
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
