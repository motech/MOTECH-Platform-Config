#!/bin/sh 
# chkconfig 2345 05 95
# ------------------------------------------------------------------------
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ------------------------------------------------------------------------
#
# This script controls standalone Apache ActiveMQ service processes.
# To ensure compatibility to macosx and cygwin we do not utilize 
# lsb standard infrastructure for controlling daemons like 
# "start-stop-daemon".
#
# See also http://activemq.apache.org/activemq-command-line-tools-reference.html
# for additional commandline arguments
#
# Authors:
# Marc Schoechlin <ms@256bit.org>

# ------------------------------------------------------------------------
# CONFIGURATION
ACTIVEMQ_CONFIGS="/etc/default/activemq $HOME/.activemqrc"

# Backup invocation parameters
COMMANDLINE_ARGS="$@"

# For using instances
if ( basename $0 | grep "activemq-instance-" > /dev/null);then
   INST="$(basename $0|sed 's/^activemq-instance-//;s/\.sh$//')"
   ACTIVEMQ_CONFIGS="/etc/default/activemq-instance-${INST} $HOME/.activemqrc-instance-${INST}"
   echo "INFO: Using alternative activemq configuration files: $ACCTIVEMQ_CONFIGS"
fi

## START:DEFAULTCONFIG
# ------------------------------------------------------------------------
# Configuration file for running Apache Active MQ as standalone provider
# 
# This file overwrites the predefined settings of the sysv init-script
#
# Active MQ installation dir

ACTIVEMQ_HOME=/opt/activemq

if [ -z "$ACTIVEMQ_HOME" ] ; then
  # try to find ACTIVEMQ
  if [ -d /opt/activemq ] ; then
    ACTIVEMQ_HOME=/opt/activemq
  fi

  if [ -d "${HOME}/opt/activemq" ] ; then
    ACTIVEMQ_HOME="${HOME}/opt/activemq"
  fi

  ## resolve links - $0 may be a link to activemq's home
  PRG="$0"
  progname=`basename "$0"`
  saveddir=`pwd`

  # need this for relative symlinks
  dirname_prg=`dirname "$PRG"`
  cd "$dirname_prg"

  while [ -h "$PRG" ] ; do
    ls=`ls -ld "$PRG"`
    link=`expr "$ls" : '.*-> \(.*\)$'`
    if expr "$link" : '.*/.*' > /dev/null; then
    PRG="$link"
    else
    PRG=`dirname "$PRG"`"/$link"
    fi
  done

  ACTIVEMQ_HOME=`dirname "$PRG"`/..

  cd "$saveddir"

  # make it fully qualified
  ACTIVEMQ_HOME=`cd "$ACTIVEMQ_HOME" && pwd`
fi

if [ -z "$ACTIVEMQ_BASE" ] ; then
  ACTIVEMQ_BASE="$ACTIVEMQ_HOME"
fi

# Active MQ configuration directory
ACTIVEMQ_CONFIG_DIR="$ACTIVEMQ_BASE/conf"

# Active MQ configuration directory
if [ -z "$ACTIVEMQ_DATA_DIR" ]; then
  ACTIVEMQ_DATA_DIR="$ACTIVEMQ_BASE/data"
fi

if [ ! -d "$ACTIVEMQ_DATA_DIR" ]; then
    mkdir $ACTIVEMQ_DATA_DIR
fi

# Location of the pidfile
if [ -z "$ACTIVEMQ_PIDFILE" ]; then
  ACTIVEMQ_PIDFILE="$ACTIVEMQ_DATA_DIR/activemq.pid"
fi

# Location of the java installation
# Specify the location of your java installation using JAVA_HOME, or specify the 
# path to the "java" binary using JAVACMD
# (set JAVACMD to "auto" for automatic detection)
#JAVA_HOME=""
JAVACMD="auto"

# Configure a user with non root priviledges, if no user is specified do not change user
ACTIVEMQ_USER="activemq"

# Set jvm memory configuration
ACTIVEMQ_OPTS_MEMORY="-Xms256M -Xmx256M"

if [ -z "$ACTIVEMQ_OPTS" ] ; then
    ACTIVEMQ_OPTS="$ACTIVEMQ_OPTS_MEMORY -Dorg.apache.activemq.UseDedicatedTaskRunner=true -Djava.util.logging.config.file=logging.properties"
fi

# Uncomment to enable audit logging
#ACTIVEMQ_OPTS="$ACTIVEMQ_OPTS -Dorg.apache.activemq.audit=true"

# Set jvm jmx configuration
# This enables jmx access over a configured jmx-tcp-port.
# You have to configure the first four settings if you run a ibm jvm, caused by the
# fact that IBM's jvm does not support VirtualMachine.attach(PID).
# JMX access is needed for quering a running activemq instance to gain data or to
# trigger management operations.
# 
# Example for ${ACTIVEMQ_CONFIG_DIR}/jmx.access:
# ---
# # The "monitorRole" role has readonly access.
# # The "controlRole" role has readwrite access.
# monitorRole readonly
# controlRole readwrite
# ---
#
# Example for ${ACTIVEMQ_CONFIG_DIR}/jmx.password:
# ---
# # The "monitorRole" role has password "abc123".
# # # The "controlRole" role has password "abcd1234".
# monitorRole abc123
# controlRole abcd1234
# ---
#
# ACTIVEMQ_SUNJMX_START="-Dcom.sun.management.jmxremote.port=11099 "
# ACTIVEMQ_SUNJMX_START="$ACTIVEMQ_SUNJMX_START -Dcom.sun.management.jmxremote.password.file=${ACTIVEMQ_CONFIG_DIR}/jmx.password"
# ACTIVEMQ_SUNJMX_START="$ACTIVEMQ_SUNJMX_START -Dcom.sun.management.jmxremote.access.file=${ACTIVEMQ_CONFIG_DIR}/jmx.access"
# ACTIVEMQ_SUNJMX_START="$ACTIVEMQ_SUNJMX_START -Dcom.sun.management.jmxremote.ssl=false"
ACTIVEMQ_SUNJMX_START="$ACTIVEMQ_SUNJMX_START -Dcom.sun.management.jmxremote"

# Set jvm jmx configuration for controlling the broker process
# You only have to configure the first four settings if you run a ibm jvm, caused by the
# fact that IBM's jvm does not support VirtualMachine.attach(PID)
# (see also com.sun.management.jmxremote.port, .jmx.password.file and .jmx.access.file )
#ACTIVEMQ_SUNJMX_CONTROL="--jmxurl service:jmx:rmi:///jndi/rmi://127.0.0.1:11099/jmxrmi --jmxuser controlRole --jmxpassword abcd1234"
ACTIVEMQ_SUNJMX_CONTROL=""

# Specify the queue manager URL for using "browse" option of sysv initscript
ACTIVEMQ_QUEUEMANAGERURL="--amqurl tcp://localhost:61616"

# Set additional JSE arguments
ACTIVEMQ_SSL_OPTS="$SSL_OPTS"

# Uncomment to enable YourKit profiling
#ACTIVEMQ_DEBUG_OPTS="-agentlib:yjpagent"

# Uncomment to enable remote debugging
#ACTIVEMQ_DEBUG_OPTS="-Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005"

# ActiveMQ tries to shutdown the broker by jmx, 
# after a specified number of seconds send SIGKILL
ACTIVEMQ_KILL_MAXSECONDS=30

## END:DEFAULTCONFIG

# ------------------------------------------------------------------------
# LOAD CONFIGURATION

# load activemq configuration
CONFIG_LOAD="no"
for ACTIVEMQ_CONFIG in $ACTIVEMQ_CONFIGS;do
   if [ -f "$ACTIVEMQ_CONFIG" ] ; then
     ( . $ACTIVEMQ_CONFIG >/dev/null 2>&1 )
     if [ "$?" != "0" ];then
      echo "ERROR: There are syntax errors in '$ACTIVEMQ_CONFIG'"
      exit 1
     else
       echo "INFO: Loading '$ACTIVEMQ_CONFIG'"
       . $ACTIVEMQ_CONFIG
      CONFIG_LOAD="yes"
     fi
   fi
done

# inform user that default configuration is loaded, no suitable configfile found
if [ "$CONFIG_LOAD" != "yes" ];then
   if [ "$1" != "setup" ];then
      echo "INFO: Using default configuration";
      echo "(you can configure options in one of these file: $ACTIVEMQ_CONFIGS)"
      echo
      echo "INFO: Invoke the following command to create a configuration file"
      CONFIGS=`echo $ACTIVEMQ_CONFIGS|sed 's/[ ][ ]*/ | /'`
      echo "$0 setup [ $CONFIGS ]"
      echo
   fi
fi

# create configuration if requested
if [ "$1" = "setup" ];then
   if [ -z "$2" ];then
      echo "ERROR: Specify configuration file"
      exit 1
   fi
   echo "INFO: Creating configuration file: $2"
   (
   P_STATE="0"
   while read LINE ;do
      if (echo "$LINE" | grep "START:DEFAULTCONFIG" >/dev/null );then
         P_STATE="1"
         continue;
      fi
      if (echo "$LINE" | grep "END:DEFAULTCONFIG" >/dev/null);then
         P_STATE="0"
         break;
      fi
      if [ "$P_STATE" -eq "1" ];then
         echo $LINE
      fi
   done < $0
   ) > $2
   echo "INFO: It's recommend to limit access to '$2' to the priviledged user"
   echo "INFO: (recommended: chown `whoami`:nogroup '$2'; chmod 600 '$2')"
   exit $?
fi

# ------------------------------------------------------------------------
# OS SPECIFIC SUPPORT

OSTYPE="unknown"

case "`uname`" in
  CYGWIN*) OSTYPE="cygwin" ;;
  Darwin*) 
           OSTYPE="darwin"
           if [-z "$JAVA_HOME"] && [ "$JAVACMD" = "auto" ];then
             JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home
           fi
           ;;
esac

# For Cygwin, ensure paths are in UNIX format before anything is touched
if [ "$OSTYPE" = "cygwin" ]; then
  [ -n "$ACTIVEMQ_HOME" ] &&
    ACTIVEMQ_HOME="`cygpath --unix "$ACTIVEMQ_HOME"`"
  [ -n "$JAVA_HOME" ] &&
    JAVA_HOME="`cygpath --unix "$JAVA_HOME"`"
  [ -n "$CLASSPATH" ] &&
    CLASSPATH="`cygpath --path --unix "$CLASSPATH"`"
fi

# Detect the location of the java binary
if [ -z "$JAVACMD" ] || [ "$JAVACMD" = "auto" ] ; then
  if [ -n "$JAVA_HOME"  ] ; then
    if [ -x "$JAVA_HOME/jre/sh/java" ] ; then
      # IBM's JDK on AIX uses strange locations for the executables
      JAVACMD="$JAVA_HOME/jre/sh/java"
    else
      JAVACMD="$JAVA_HOME/bin/java"
    fi
  fi
fi

# Hm, we still do not know the location of the java binary
if [ ! -x "$JAVACMD" ] ; then
    JAVACMD=`which java 2> /dev/null `
    if [ -z "$JAVACMD" ] ; then
        JAVACMD=java
    fi
fi
# Stop here if no java installation is defined/found
if [ ! -x "$JAVACMD" ] ; then
  echo "ERROR: Configuration variable JAVA_HOME or JAVACMD is not defined correctly."
  echo "       (JAVA_HOME='$JAVAHOME', JAVACMD='$JAVACMD')"
  exit 1
fi

echo "INFO: Using java '$JAVACMD'"

if [ -z "$ACTIVEMQ_BASE" ] ; then
  ACTIVEMQ_BASE="$ACTIVEMQ_HOME"
fi

# For Cygwin, switch paths to Windows format before running java if [ "$OSTYPE" = "cygwin" ]; then
if [ "$OSTYPE" = "cygwin" ];then
  ACTIVEMQ_HOME=`cygpath --windows "$ACTIVEMQ_HOME"`
  ACTIVEMQ_BASE=`cygpath --windows "$ACTIVEMQ_BASE"`
  ACTIVEMQ_CLASSPATH=`cygpath --path --windows "$ACTIVEMQ_CLASSPATH"`
  JAVA_HOME=`cygpath --windows "$JAVA_HOME"`
  CLASSPATH=`cygpath --path --windows "$CLASSPATH"`
  CYGHOME=`cygpath --windows "$HOME"`
  if [ -n "$CYGHOME" ]; then
      ACTIVEMQ_CYGWIN="-Dcygwin.user.home=\"$CYGHOME\""
  fi
fi

# Set default classpath
# Add instance conf dir before AMQ install conf dir to pick up instance-specific classpath entries first
ACTIVEMQ_CLASSPATH="${ACTIVEMQ_CONFIG_DIR};${ACTIVEMQ_CLASSPATH}"
if [ "${ACTIVEMQ_BASE}" != "${ACTIVEMQ_HOME}" ]; then
    ACTIVEMQ_CLASSPATH="${ACTIVEMQ_BASE}/conf;${ACTIVEMQ_CLASSPATH}"
fi



# ------------------------------------------------------------------------
# HELPER FUNCTIONS

# Start the ActiveMQ JAR
#
#
# @ARG1 : the name of the PID-file
#         If specified, this function starts the java process in background as a daemon
#         and stores the pid of the created process in the file.
#         Output on stdout/stderr will be supressed if this parameter is specified
# @RET  : If unless 0 something went wrong
#
# Note: This function uses a lot of globally defined variables
# - if $ACTIVEMQ_USER is set, the function tries starts the java process whith the specified
#   user
invokeJar(){
   PIDFILE="$1"
   RET="1"
   CUSER="$(whoami 2>/dev/null)"

   # Solaris fix
   if [ ! $? -eq 0 ]; then
      CUSER="$(/usr/ucb/whoami)"
   fi

   if [ ! -f "${ACTIVEMQ_HOME}/bin/run.jar" ];then
    echo "ERROR: '${ACTIVEMQ_HOME}/bin/run.jar' does not exist"
    exit 1
   fi
  
   if ( [ -z "$ACTIVEMQ_USER" ] || [ "$ACTIVEMQ_USER" = "$CUSER" ] );then
      DOIT_PREFIX="sh -c "
      DOIT_POSTFIX=";"
   elif [ "$(id -u)" = "0" ];then
      DOIT_PREFIX="su -c "
      DOIT_POSTFIX=" - $ACTIVEMQ_USER"
      echo "INFO: changing to user '$ACTIVEMQ_USER' to invoke java"
   fi
   # Execute java binary
   if [ -n "$PIDFILE" ] && [ "$PIDFILE" != "stop" ];then
      $DOIT_PREFIX "$JAVACMD $ACTIVEMQ_OPTS $ACTIVEMQ_DEBUG_OPTS \
              -Dactivemq.classpath=\"${ACTIVEMQ_CLASSPATH}\" \
              -Dactivemq.home=\"${ACTIVEMQ_HOME}\" \
              -Dactivemq.base=\"${ACTIVEMQ_BASE}\" \
              $ACTIVEMQ_CYGWIN \
              -jar \"${ACTIVEMQ_HOME}/bin/run.jar\" $COMMANDLINE_ARGS >/dev/null 2>&1 & 
              RET=\"\$?\"; APID=\"\$!\";
              echo \$APID > $PIDFILE;
              echo \"INFO: pidfile created : '$PIDFILE' (pid '\$APID')\";exit \$RET" $DOIT_POSTFIX
      RET="$?"
   elif [ -n "$PIDFILE" ] && [ "$PIDFILE" = "stop" ];then
          PID=`cat $ACTIVEMQ_PIDFILE`
          $DOIT_PREFIX "$JAVACMD $ACTIVEMQ_OPTS $ACTIVEMQ_DEBUG_OPTS \
              -Dactivemq.classpath=\"${ACTIVEMQ_CLASSPATH}\" \
              -Dactivemq.home=\"${ACTIVEMQ_HOME}\" \
              -Dactivemq.base=\"${ACTIVEMQ_BASE}\" \
              $ACTIVEMQ_CYGWIN \
              -jar \"${ACTIVEMQ_HOME}/bin/run.jar\" $COMMANDLINE_ARGS --pid $PID &
              RET=\"\$?\"; APID=\"\$!\"; 
              echo \$APID > $ACTIVEMQ_DATA_DIR/stop.pid; exit \$RET" $DOIT_POSTFIX
      RET="$?"
   else
      $DOIT_PREFIX "$JAVACMD $ACTIVEMQ_OPTS $ACTIVEMQ_DEBUG_OPTS \
              -Dactivemq.classpath=\"${ACTIVEMQ_CLASSPATH}\" \
              -Dactivemq.home=\"${ACTIVEMQ_HOME}\" \
              -Dactivemq.base=\"${ACTIVEMQ_BASE}\" \
              $ACTIVEMQ_CYGWIN \
              -jar \"${ACTIVEMQ_HOME}/bin/run.jar\" $COMMANDLINE_ARGS" $DOIT_POSTFIX
      RET="$?"
   fi
   return $RET
}

# Check if ActiveMQ is running
#
# @RET  : 0 => the activemq process is running
#         1 => process id in $ACTIVEMQ_PIDFILE does not exist anymore
#         2 => something is wrong with the pid file
#
# Note: This function uses globally defined variables
# - $ACTIVEMQ_PIDFILE : the name of the pid file


checkRunning(){
    if [ -f "$ACTIVEMQ_PIDFILE" ]; then
       if  [ -z "$(cat $ACTIVEMQ_PIDFILE)" ];then
        echo "ERROR: Pidfile '$ACTIVEMQ_PIDFILE' exists but contains no pid"
        return 2
       fi
       PID=`cat $ACTIVEMQ_PIDFILE`
       RET=`ps -p $PID|grep java`
       if [ -n "$RET" ];then
         return 0;
       else
         return 1;
       fi
    else
         return 1;
    fi
}

checkStopRunning(){
    PID=$ACTIVEMQ_DATA_DIR/stop.pid
    if [ -f "$PID" ]; then
       if  [ -z "$(cat $PID)" ];then
        echo "ERROR: Pidfile '$PID' exists but contains no pid"
        return 2
       fi
       RET=`ps -p $(cat $PID)|grep java`
       if [ -n "$RET" ];then
         return 0;
       else
         return 1;
       fi
    else
         return 1;
    fi
}

# Check if ActiveMQ is running
#
# @RET  : 0 => the activemq process is running
#         1 => the activemq process is not running
#
# Note: This function uses globally defined variables
# - $ACTIVEMQ_PIDFILE : the name of the pid file


invoke_status(){
    if ( checkRunning );then
         PID=`cat $ACTIVEMQ_PIDFILE`
         echo "ActiveMQ is running (pid '$PID')"
         exit 0
    fi
    echo "ActiveMQ not running"
    exit 1
}

# Start ActiveMQ if not already running
#
# @RET  : 0 => is now started, is already started
#         !0 => something went wrong
#
# Note: This function uses globally defined variables
# - $ACTIVEMQ_PIDFILE      : the name of the pid file
# - $ACTIVEMQ_OPTS         : Additional options 
# - $ACTIVEMQ_SUNJMX_START : options for JMX settings
# - $ACTIVEMQ_SSL_OPTS     : options for SSL encryption

invoke_start(){
    if ( checkRunning );then
      PID=`cat $ACTIVEMQ_PIDFILE`
      echo "INFO: Process with pid '$PID' is already running"
      exit 0
    fi

    ACTIVEMQ_OPTS="$ACTIVEMQ_OPTS $ACTIVEMQ_SUNJMX_START $ACTIVEMQ_SSL_OPTS"

    echo "INFO: Starting - inspect logfiles specified in logging.properties and log4j.properties to get details"
    invokeJar $ACTIVEMQ_PIDFILE
    exit "$?" 
}

# Start ActiveMQ in foreground (for debugging)
#
# @RET  : 0 => is now started, is already started
#         !0 => something went wrong
#
# Note: This function uses globally defined variables
# - $ACTIVEMQ_PIDFILE      : the name of the pid file
# - $ACTIVEMQ_OPTS         : Additional options 
# - $ACTIVEMQ_SUNJMX_START : options for JMX settings
# - $ACTIVEMQ_SSL_OPTS     : options for SSL encryption

invoke_console(){
    if ( checkRunning );then
      echo "ERROR: ActiveMQ is already running"
      exit 1
    fi

    ACTIVEMQ_OPTS="$ACTIVEMQ_OPTS $ACTIVEMQ_SUNJMX_START $ACTIVEMQ_SSL_OPTS"

    COMMANDLINE_ARGS="start $(echo $COMMANDLINE_ARGS|sed 's,^console,,')"
    echo "INFO: Starting in foreground, this is just for debugging purposes (stop process by pressing CTRL+C)"
    invokeJar
    exit "$?" 
}

# Stop ActiveMQ
#
# @RET  : 0 => stop was successful
#         !0 => something went wrong
#
# Note: This function uses globally defined variables
# - $ACTIVEMQ_PIDFILE         : the name of the pid file
# - $ACTIVEMQ_KILL_MAXSECONDS : the number of seconds to wait for termination of broker after sending 
#                              shutdown signal by jmx interface

invoke_stop(){
    RET="1"
    if ( checkRunning );then
       ACTIVEMQ_OPTS="$ACTIVEMQ_OPTS $ACTIVEMQ_SSL_OPTS"
       COMMANDLINE_ARGS="$COMMANDLINE_ARGS $ACTIVEMQ_SUNJMX_CONTROL"
       invokeJar "stop"
       RET="$?"
       PID=`cat $ACTIVEMQ_PIDFILE`
       echo "INFO: Waiting at least $ACTIVEMQ_KILL_MAXSECONDS seconds for regular process termination of pid '$PID' : "
       FOUND="0"
       i=1
       while [ $i != $ACTIVEMQ_KILL_MAXSECONDS ]; do
        
         if [ ! checkStopRunning ];then
            if [ ! checkRunning ]; then
               echo " FINISHED"
               FOUND="1"              
            fi
            break
         fi
        
         if (checkRunning);then
            sleep 1
            printf  "."
         else
            echo " FINISHED"
            FOUND="1"
            break
         fi
         i=`expr $i + 1`
       done
       if [ "$FOUND" -ne "1" ];then
         echo
         echo "INFO: Regular shutdown not successful,  sending SIGKILL to process with pid '$PID'"
         kill -KILL $PID
         RET="1"
       fi
    elif [ -f "$ACTIVEMQ_PIDFILE" ];then
       echo "ERROR: No or outdated process id in '$ACTIVEMQ_PIDFILE'"
       echo
       echo "INFO: Removing $ACTIVEMQ_PIDFILE"
    else
       echo "ActiveMQ not running"
       exit 0
    fi
    rm -f $ACTIVEMQ_PIDFILE >/dev/null 2>&1
    rm -f $ACTIVEMQ_DATA_DIR/stop.pid >/dev/null 2>&1
    exit $RET
}

# Invoke a task on a running ActiveMQ instance
#
# @RET  : 0 => successful
#         !0 => something went wrong
#
# Note: This function uses globally defined variables
# - $ACTIVEMQ_QUEUEMANAGERURL : The url of the queuemanager
# - $ACTIVEMQ_OPTS            : Additional options
# - $ACTIVEMQ_SUNJMX_START    : options for JMX settings
# - $ACTIVEMQ_SSL_OPTS        : options for SSL encryption
invoke_task(){
    # call task in java binary
    if ( checkRunning );then
      if [ "$1" = "browse" ] && [ -n "$ACTIVEMQ_QUEUEMANAGERURL" ];then
         ACTIVEMQ_OPTS="$ACTIVEMQ_OPTS $ACTIVEMQ_SSL_OPTS"
         COMMANDLINE_ARGS="$1 $ACTIVEMQ_QUEUEMANAGERURL $(echo $COMMANDLINE_ARGS|sed 's,^browse,,')"
      elif [ "$1" = "query" ]  && [ -n "$ACTIVEMQ_QUEUEMANAGERURL" ];then
         ACTIVEMQ_OPTS="$ACTIVEMQ_OPTS $ACTIVEMQ_SSL_OPTS"
         COMMANDLINE_ARGS="$1 $ACTIVEMQ_SUNJMX_CONTROL $(echo $COMMANDLINE_ARGS|sed 's,^query,,')"
      else 
         ACTIVEMQ_OPTS="$ACTIVEMQ_OPTS $ACTIVEMQ_SSL_OPTS"
         COMMANDLINE_ARGS="$COMMANDLINE_ARGS $ACTIVEMQ_SUNJMX_CONTROL"
      fi
      invokeJar
      exit $?
    else
      invokeJar
      exit 1
    fi
}

show_help() {
  invokeJar
  RET="$?"
  cat << EOF
Tasks provided by the sysv init script:
    restart         - stop running instance (if there is one), start new instance
    console         - start broker in foreground, useful for debugging purposes
    status          - check if activemq process is running
    setup           - create the specified configuration file for this init script
                      (see next usage section)

Configuration of this script:
    The configuration of this script can be placed on /etc/default/activemq or $HOME/.activemqrc.
    To use additional configurations for running multiple instances on the same operating system
    rename or symlink script to a name matching to activemq-instance-<INSTANCENAME>.
    This changes the configuration location to /etc/default/activemq-instance-<INSTANCENAME> and
    \$HOME/.activemqrc-instance-<INSTANCENAME>. Configuration files in /etc have higher precedence. 
EOF
  exit $RET
}

# ------------------------------------------------------------------------
# MAIN

# show help
if [ -z "$1" ];then
 show_help
fi

case "$1" in
  status)    
      invoke_status
    ;;
  restart)
    if ( checkRunning );then
      $0 stop
    fi
    $0 status
    $0 start
    $0 status
    ;;
  start)    
    invoke_start
    ;;
  console)
    invoke_console
    ;;
  stop)    
    invoke_stop
    ;;
  *)
    invoke_task
esac
