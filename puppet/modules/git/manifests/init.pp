class git {
  include repos::epel
  package { "git":
    ensure  =>  "present",
    require => [Package["epel-release-5-4"]],
  }
}
