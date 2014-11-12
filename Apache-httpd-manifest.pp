class staging {

exec {'tz-set':
  command => '/usr/bin/timedatectl set-timezone Asia/Kolkata'
} 

package { "build-essential":
    ensure => "installed"
} 

package { "unzip":
    ensure => "installed"
} 

package { "openssl":
    ensure => "installed"
} 

package { "libssl-dev":
    ensure => "installed"
} 

#file { [ "/usrdata/archive", "/usrdata/apps", "/usrdata/apps/appserver", "/usrdata/apps/sysapps", "/usrdata/apps/jiolib", "/usrdata/apps/sysapps/apr", "/usrdata/apps/sysapps/apr-util", "/usrdata/apps/sysapps/tomcat-native" ] :
#    ensure => "directory",
#} 

file { [ "/usrdata/archive", "/usrdata/apps", "/usrdata/apps/syspacks", "/usrdata/apps/syspacks/pcre", "/usrdata/apps/httpserver/" ] :
   ensure => "directory",
}

file { [ "/usrdata/logs" ] :
owner => "jersey",
      group => "servicesusrgroup",
      ensure => "directory",
}

file { '/usrdata/archive/http-pkg-install.sh':
    owner => "jersey",
    group => "servicesusrgroup",
    mode => "755",
    source => "puppet:///modules/staging/http-files/http-pkg-install.sh",
} ->

exec {'pkg-script':
  command => '/bin/sh /usrdata/archive/http-pkg-install.sh'
} 

file { '/usrdata/apps/httpserver/conf/httpd.conf':
#    owner => "jersey",
#    group => "servicesusrgroup",
#    mode => "755",
    source => "puppet:///modules/staging/http-files/httpd.conf",
}

file { '/usrdata/apps/httpserver/conf/mod_jk.conf':
 source => "puppet:///modules/staging/http-files/mod_jk.conf",
}

file { '/usrdata/apps/httpserver/conf/workers.properties':
   source => "puppet:///modules/staging/http-files/workers.properties",
}

file { '/usrdata/apps/httpserver/conf/uriworkermap.properties':
    source => "puppet:///modules/staging/http-files/uriworkermap.properties",
}

file { '/usrdata/archive/ufw.sh':
   source =>  "puppet:///modules/staging/http-files/ufw.sh",
   mode => "755",
}

exec { 'ufw-start':
  command => '/bin/sh /usrdata/archive/ufw.sh'
}

exec {'start-scr':
  command => '/bin/cp /usrdata/apps/httpserver/bin/apachectl /etc/init.d/httpd'
}

file { '/etc/init.d/httpd':
    owner => "jersey",
    group => "servicesusrgroup",
    mode => "554",
    ensure => "present",
} 

exec {'update-rc':
  command => '/usr/sbin/update-rc.d httpd defaults'
}

}


