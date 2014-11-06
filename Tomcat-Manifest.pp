class staging {

exec {'tz-set':
  command => '/usr/bin/timedatectl set-timezone Asia/Kolkata'
}

file { [ "/usrdata/archive", "/usrdata/apps", "/usrdata/apps/appserver", "/usrdata/apps/sysapps", "/usrdata/apps/jiolib", "/usrdata/apps/sysapps/apr", "/usrdata/apps/sysapps/apr-util", "/usrdata/apps/sysapps/tomcat-native" ] :
    ensure => "directory",
}

user { "jersey":
   ensure => present,
}

group { "servicesusrgroup":
   ensure => present,
}

#file { [ "/usrdata/logs", "/usrdata/logs/tomcatlogs", /usrdata/logs/applogs", "/usrdata/logs/tomcatlogs/archive", "/usrdata/logs/applogs/archive", "/usrdata/logs/tomcatlogs/heapdump" ] :
file { ["/usrdata/logs", "/usrdata/logs/tomcatlogs" ] :
      owner => "jersey",
      group => "servicesusrgroup",
      ensure => "directory",
}

file { ["/usrdata/logs/applogs", "/usrdata/logs/tomcatlogs/archive" ] :
      owner => "jersey",
      group => "servicesusrgroup",
      ensure => "directory",
}

file { "/usrdata/logs/tomcatlogs/heapdump":
      owner => "jersey",
      group => "servicesusrgroup",
      ensure => "directory",
}

file { "/usrdata/archive/apache-tomcat-7.0.56.tar.gz":
    source => "puppet:///modules/staging/source/apache-tomcat-7.0.56.tar.gz",
    ensure => "present",
}

#exec { 'Extract-tar':
#    path => "/bin:/usr/bin",
#    command => "tar -zxf /usrdata/archive/apache-tomcat-7.0.56.tar.gz"
#}

exec { 'cp-tar':
    command => "/bin/cp -R  /usrdata/archive/apache-tomcat-7.0.56 /usrdata/apps/appserver/ "
}

file { '/usrdata/apps/appserver/apache-tomcat-7.0.56' :
       owner => "jersey",
    group => "servicesusrgroup",
    recurse => true,
 ensure => "directory",
}

file { '/etc/init.d/tomcat':
    owner => "jersey",
    group => "servicesusrgroup",
    mode => "755",
    source => "puppet:///modules/staging/tomcat",
} 

exec { 'Rc-add':
      command => "/usr/sbin/update-rc.d tomcat defaults"
}

file { '/usrdata/apps/appserver/apache-tomcat-7.0.56/lib/log4j.properties':
      owner => "jersey",
     group => "servicesusrgroup",
     source => "puppet:///modules/staging/log4j",
}

file { '/usrdata/apps/appserver/apache-tomcat-7.0.56/lib/log4j-1.2.17.jar':
      owner => "jersey",
     group => "servicesusrgroup",
     source => "puppet:///modules/staging/source/apache-log4j-1.2.17/log4j-1.2.17.jar",
}

file { '/usrdata/apps/appserver/apache-tomcat-7.0.56/lib/apache-log4j-extras-1.2.17.jar':
    owner => "jersey",
     group => "servicesusrgroup",
    source => "puppet:///modules/staging/source/apache-log4j-extras-1.2.17/apache-log4j-extras-1.2.17.jar",
}

file { '/usrdata/apps/appserver/apache-tomcat-7.0.56/bin/tomcat-juli.jar':
    owner => "jersey",
     group => "servicesusrgroup",
    source => "puppet:///modules/staging/source/tomcat-juli.jar",
}

file { '/usrdata/apps/appserver/apache-tomcat-7.0.56/lib/tomcat-juli-adapters.jar':
    owner => "jersey",
     group => "servicesusrgroup",
    source => "puppet:///modules/staging/source/tomcat-juli-adapters.jar",
}

 file { 'logging.properties':
    path => "/usrdata/apps/appserver/apache-tomcat-7.0.56/conf/logging.properties", 
    ensure => absent,
  }

package { "build-essential":
    ensure => "installed"
}

package { "libapr1-dev":
    ensure => "installed"
}

package { "libssl-dev":
    ensure => "installed"

}

file { '/usrdata/apps/appserver/apache-tomcat-7.0.56/bin/setenv.sh':
    owner => "jersey",
    group => "servicesusrgroup",
    mode => "755",
    source => "puppet:///modules/staging/setenv.sh",
}

file { '/usrdata/archive/pkg-install.sh':
    owner => "jersey",
    group => "servicesusrgroup",
    mode => "755",
    source => "puppet:///modules/staging/pkg-install.sh",
}

exec {'pkg-script':
  command => '/bin/sh /usrdata/archive/pkg-install.sh'
}

file {'/usrdata/apps/appserver/apache-tomcat-7.0.56/conf/server.xml':
    owner => "jersey",
    group => "servicesusrgroup",
    source => "puppet:///modules/staging/server.xml",
}

file {'/usrdata/apps/appserver/apache-tomcat-7.0.56/conf/catalina.properties':
    owner => "jersey",
    group => "servicesusrgroup",
    source => "puppet:///modules/staging/catalina.properties",
}


}
