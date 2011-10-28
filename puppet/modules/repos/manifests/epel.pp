class repos::epel {
  file { "/usr/local/src/epel-release-5-4.noarch.rpm":
    source => "puppet:///modules/repos/epel-release-5-4.noarch.rpm"
  }

  package { "epel-release-5-4":
    provider => "rpm",
    ensure => "present",
    source => "/usr/local/src/epel-release-5-4.noarch.rpm",
    require => File["/usr/local/src/epel-release-5-4.noarch.rpm"]
  }
}
