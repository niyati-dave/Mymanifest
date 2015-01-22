exec {"apt-get":
                  command => "apt-get update",
                  path =>"/bin:/usr/bin",
                } ->

exec {'tz-set':
  command => '/usr/bin/timedatectl set-timezone Asia/Kolkata'
} ->

package { "build-essential":
    ensure => "installed"
} ->

package { "unzip":
    ensure => "installed"
} ->

package { "openssl":
    ensure => "installed"
} ->

package { "libssl-dev":
    ensure => "installed"
} ->

##########New Packages for Security modules############
package { "liblua5.2":
    ensure => "installed"
} ->

package { "libcurl4-openssl-dev":
    ensure => "installed"
} ->

package { "libexpat1-dev":
    ensure => "installed"
} ->
############# End of new packages ###############


file { [ "/usrdata/archive", "/usrdata/apps", "/usrdata/apps/syspacks", "/usrdata/apps/syspacks/pcre", "/usrdata/apps/httpserver/" ] :
   ensure => "directory",
} ->

file { [ "/usrdata/logs" ] :
owner => "jersey",
      group => "servicesusrgroup",
      ensure => "directory",
} ->


exec {'script-download':
     command => "/usr/bin/wget -e use_proxy=yes -e http_proxy=10.135.80.164:8678 -O /usrdata/archive/http-pkg-install.sh  http://10.135.80.168/private_repo/PRIVATE_REPO/Apache-Files-Puppet/http-pkg-install.sh; /usr/bin/wget -e use_proxy=yes -e http_proxy=10.135.80.164:8678 -O /usrdata/archive/security-install.sh  http://10.135.80.168/private_repo/PRIVATE_REPO/Apache-Files-Puppet/security-addon-install.sh"
   } ->


### FOr later Use ################

#exec {'source-download':
#    command => " "
#}

exec {'conf-files-download':
     command => "/usr/bin/wget -e use_proxy=yes -e http_proxy=10.135.80.164:8678 -O /usrdata/apps/httpserver/conf/httpd.conf  http://10.135.80.168/private_repo/PRIVATE_REPO/Apache-Files-Puppet/httpd.conf; /usr/bin/wget -e use_proxy=yes -e http_proxy=10.135.80.164:8678 -O /usrdata/apps/httpserver/conf/mod-ssl.conf  http://10.135.80.168/private_repo/PRIVATE_REPO/Apache-Files-Puppet/mod-ssl.conf; /usr/bin/wget -e use_proxy=yes -e http_proxy=10.135.80.164:8678 -O /usrdata/apps/httpserver/conf/mod_jk.conf  http://10.135.80.168/private_repo/PRIVATE_REPO/Apache-Files-Puppet/mod_jk.conf; /usr/bin/wget -e use_proxy=yes -e http_proxy=10.135.80.164:8678 -O /usrdata/apps/httpserver/conf/security.conf http://10.135.80.168/private_repo/PRIVATE_REPO/Apache-Files-Puppet/security.conf; /usr/bin/wget -e use_proxy=yes -e http_proxy=10.135.80.164:8678 -O /usrdata/archive/ufw.sh http://10.135.80.168/private_repo/PRIVATE_REPO/Apache-Files-Puppet/ufw.sh; /usr/bin/wget -e use_proxy=yes -e http_proxy=10.135.80.164:8678 -O /usrdata/apps/httpserver/conf/uriworkermap.properties http://10.135.80.168/private_repo/PRIVATE_REPO/Apache-Files-Puppet/uriworkermap.properties; /usr/bin/wget -e use_proxy=yes -e http_proxy=10.135.80.164:8678 -O /usrdata/apps/httpserver/conf/workers.properties  http://10.135.80.168/private_repo/PRIVATE_REPO/Apache-Files-Puppet/workers.properties"
} ->

exec {'pkg-script':
  command => '/bin/sh /usrdata/archive/http-pkg-install.sh'
} ->
 
exec {'security-script':
  command => '/bin/sh /usrdata/archive/security-install.sh'
} ->

exec { 'ufw-start':
  command => '/bin/sh /usrdata/archive/ufw.sh'
} ->

exec {'start-scr':
  command => '/bin/cp /usrdata/apps/httpserver/bin/apachectl /etc/init.d/httpd'
} ->

file { '/etc/init.d/httpd':
    owner => "jersey",
    group => "servicesusrgroup",
    mode => "554",
    ensure => "present",
} ->


exec {'update-rc':
  command => '/usr/sbin/update-rc.d httpd defaults'
} ->


