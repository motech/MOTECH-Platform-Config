node default {

  include couchdb
  include java::open_jdk
  include activemq
  include mysql::server
  include activemq::db
  include tomcat
  
#  tomcat::deployment {"motech":
#    path => "",
#  }
}

import "dev"
