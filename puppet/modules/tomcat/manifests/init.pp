class tomcat {

  notice("Establishing http://$hostname:$tomcat_port/")

  user { "tomcat7":
    ensure => present,
    home   => '/opt/tomcat',
    name   => 'tomcat7',
  }
  
  file { "/tmp/apache-tomcat-7.0.22.tar.gz":
    owner  => tomcat7,
    group  => tomcat7,
    mode   => 755,
    source => "puppet:///modules/tomcat/apache-tomcat-7.0.22.tar.gz",
  }

  exec { "tomcat_untar":
    command => "tar -xzf /tmp/apache-tomcat-7.0.22.tar.gz",
    cwd     => "/opt",
    creates => "/opt/apache-tomcat-7.0.22",
    path    => ["/bin",],
    require => File["/tmp/apache-tomcat-7.0.22.tar.gz"],
  }

  exec { "tomcat_chown":
    command => "chown -R tomcat7:tomcat7 /opt/apache-tomcat-7.0.22",
    cwd     => "/opt",
    path    => ["/bin",],
    require => Exec["tomcat_untar"],
  }

  file { '/opt/tomcat':
    ensure => link,
    target => '/opt/apache-tomcat-7.0.22',
  }

  file { "/etc/init.d/tomcat7":
    owner  => root,
    group  => root,
    mode   => 755,
    source => "puppet:///modules/tomcat/tomcat7-init.d",
    require => File['/opt/tomcat'],
  }

  file { "/opt/tomcat/conf/tomcat-users.xml":
    owner => 'tomcat7',
    group => 'tomcat7',
    require => File['/opt/tomcat'],
    content => template('tomcat/tomcat-users.xml.erb')
  }

  file { '/opt/tomcat/conf/server.xml':
    owner => 'tomcat7',
    group => 'tomcat7',
    require => File['/opt/tomcat'],
    content => template('tomcat/server.xml.erb'),
  }

  file { "/opt/tomcat/conf/policy.d":
    ensure => directory,
    recurse => true,
    purge => true,
    force => true,
    owner => "root",
    group => "tomcat7",
    mode => 0644,
    source => "puppet:///modules/tomcat/conf/policy.d",
  }

  service { 'tomcat7':
    ensure => running,
    require => File['/etc/init.d/tomcat7'],
  }   

}

define tomcat::deployment($path) {

  include tomcat
  notice("Establishing http://$hostname:${tomcat::tomcat_port}/$name/")

  file { "/var/lib/tomcat7/webapps/${name}.war":
    owner => 'root',
    source => $path,
  }

}
