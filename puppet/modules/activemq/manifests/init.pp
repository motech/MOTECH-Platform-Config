class activemq {
  include java::open_jdk

  user { "activemq":
    ensure => present,
    home   => '/opt/activemq',
    name   => 'activemq',
  }
  
  file { "/tmp/apache-activemq-5.5.0-bin.tar.gz":
    owner  => activemq,
    group  => activemq,
    mode   => 755,
    source => "puppet:///modules/activemq/apache-activemq-5.5.0-bin.tar.gz",
  }

  exec { "activemq_untar":
    command => "tar -xzf /tmp/apache-activemq-5.5.0-bin.tar.gz",
    cwd     => "/opt",
    creates => "/opt/apache-activemq-5.5.0",
    path    => ["/bin",],
    require => File["/tmp/apache-activemq-5.5.0-bin.tar.gz"],
  }

  exec { "activemq_chown":
    command => "chown -R activemq:activemq /opt/apache-activemq-5.5.0",
    cwd     => "/opt",
    path    => ["/bin",],
    require => Exec["activemq_untar"],
  }

  file { '/opt/activemq':
    ensure => link,
    target => '/opt/apache-activemq-5.5.0',
  }

  file { "/etc/init.d/activemq":
    owner  => root,
    group  => root,
    mode   => 755,
    source => "puppet:///modules/activemq/activemq-init.d",
    require => File['/opt/activemq'],
  }

  file { "/opt/activemq/conf/activemq.xml":
    owner  => activemq,
    group  => activemq,
    mode   => 755,
    source => "puppet:///modules/activemq/conf/activemq.xml",
    require => File['/opt/activemq'],
  }

  service { "activemq":
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require => [Package["java"], File["/etc/init.d/activemq"]],
  }
}
