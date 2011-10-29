class mysql::server {
  
  package { "mysql-admin": ensure => installed }
  package { "mysql-server": ensure => installed }
  package { "mysql-common": ensure => installed }
  package { "mysql-client": ensure => installed }

  service { "mysql":
    enable  => true,
    ensure  => running,
    require => Package["mysql-server"],
  }

  file { "/var/lib/mysql/my.cnf":
    owner   => "mysql",
    group   => "mysql",
    source  => "puppet:///modules/mysql/my.cnf",
    notify  => Service["mysql"],
    require => Package["mysql-server"],
  }
 
  file { "/etc/my.cnf":
    require => File["/var/lib/mysql/my.cnf"],
    ensure => "/var/lib/mysql/my.cnf",
  }

  exec { "set-mysql-password":
    unless => "mysqladmin -uroot -p$mysql_password status",
    path => ["/bin", "/usr/bin"],
    command => "mysqladmin -uroot password $mysql_password",
    require => Service["mysql"],
  }
}

define mysqldb( $user, $password ) {
  exec { "create-${name}-db":
    unless => "/usr/bin/mysql -u${user} -p${password} ${name}",
    command => "/usr/bin/mysql -uroot -p$mysql_password -e \"create database ${name}; grant all on ${name}.* to ${user}@localhost identified by '$password';\"",
    require => Service["mysql"],
  }
}
