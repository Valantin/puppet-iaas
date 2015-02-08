define iaas::resources::database (
  $user = hiera("iaas::mysql::${title}::user", $title),
  $password = hiera("iaas::mysql::${title}::password", $title),
  $allowed_hosts = hiera('iaas::mysql::allowed_hosts', ''),
) {
  class { "::${title}::db::mysql":
    user => $user,
    password => $password,
    dbname => $title,
    host => "localhost",
    allowed_hosts => $allowed_hosts,
    mysql_module => '2.3',
    require => Anchor['database-service'],
  }
}
