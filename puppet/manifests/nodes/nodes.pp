node default {
  include couchdb
  include java::open_jdk
  include activemq
  include mysql::server
# include tomcat
  
#  tomcat::deployment { "SimpleServlet":
#    path => '/srv/puppet-tomcat-demo/java_src/SimpleServlet.war'
#  }

}

import "dev"
