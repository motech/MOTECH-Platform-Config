class activemq {
  include java::open_jdk

  file { "/tmp/apache-activemq-5.5.0-bin.tar.gz":
    owner  => root,
    group  => root,
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
    owner  => root,
    group  => root,
    mode   => 755,
    source => "puppet:///modules/activemq/activemq-init.d",
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
