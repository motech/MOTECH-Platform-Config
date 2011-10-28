class couchdb {
  
  package { "couchdb":
    ensure  =>  "present",
  }

  service { "couchdb":
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require => Package["couchdb"],
  }
}
