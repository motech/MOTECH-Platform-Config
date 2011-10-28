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
  
  exec { "rename_activemq_dir":
    command => "mv apache-activemq-5.5.0 activemq",
    cwd => '/opt',
    path => ["/bin",],
    require => Exec["activemq_untar"],
    creates => '/opt/activemq',
  }

  file { "/etc/init.d/activemq":
    owner  => root,
    group  => root,
    mode   => 755,
    source => "puppet:///modules/activemq/activemq-init.d",
    require => Exec["rename_activemq_dir"],
  }

  service { "activemq":
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require => [Package["java"], File["/etc/init.d/activemq"]],
  }
}
