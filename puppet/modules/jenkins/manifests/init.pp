class jenkins {
  include repos::jenkins
  include java::sun_jdk

  package { "jenkins":
    ensure  =>  "present",
    require   => [Yumrepo[jenkins], Exec["sun_jre_6"]]
  }

  service {"jenkins":
      enable  => true,
      ensure  => "running",
      hasrestart=> true,
      require => Package["jenkins"],
  }
}
