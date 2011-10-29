$mysql_password = "password"

$tomcat_port = 8080
$tomcat_password = 'password'

node dev {
  include activemq::db
  
}
