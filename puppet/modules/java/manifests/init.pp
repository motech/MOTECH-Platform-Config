class java::open_jdk {
  case $operatingsystem {
    centos, redhat: {
      $package_name = 'java-1.6.0-openjdk'
    }
    debian, ubuntu: {
      $package_name = 'openjdk-6-jdk'
    }
  }
                                                  
  package { $package_name:
    ensure  =>  "present",
    alias => java,
  }
}
