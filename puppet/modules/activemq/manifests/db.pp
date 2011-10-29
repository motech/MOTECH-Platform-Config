class activemq::db
  mysqldb { "activemq":
    user => "motech",
    password => "password",
  }
}
