exec {"apt-get":
                  command => "apt-get update",
                  path =>"/bin:/usr/bin",
                } ->
package {"libaio1":
                      ensure => "installed",
                    } ->
file    {"/usrdata/mysql":
                      ensure => "directory",
                    } ->
group { "mysql":
   ensure => present,
} ->

 user {"mysql":
                  ensure     => "present",
                  managehome => true,
                  groups  => 'mysql',
                 } ->

exec {"mysql-download":
                  command =>  "mkdir /usrdata/source;wget -e use_proxy=yes -e http_proxy=10.135.80.164:8678 -O /usrdata/source/mysql-5.6.22-linux-glibc2.5-x86_64.tar.gz http://cdn.mysql.com/Downloads/MySQL-5.6/mysql-5.6.22-linux-glibc2.5-x86_64.tar.gz",
                  path =>"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
} ->

exec {"mysql-untar":
#           cwd => 'usrdata/source',
          command => '/bin/sh -c "cd /usrdata/source;tar -zxvf mysql-5.6.22-linux-glibc2.5-x86_64.tar.gz; cp -R /usrdata/source/mysql-5.6.22-linux-glibc2.5-x86_64/* /usrdata/mysql/; chown -R mysql /usrdata/mysql; chgrp -R mysql /usrdata/mysql"',
 path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
} ->

exec {"mysql-install":
    command =>  '/bin/sh -c "cd /usrdata/mysql; /usrdata/mysql/scripts/mysql_install_db --user=mysql"',
 #path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
} ->
exec {"mysql-setup":
#command => '/bin/sh -c "cd /usrdata/mysql; chown -R root /usrdata/mysql ; chown -R mysql /usrdata/mysql/data; mv /usrdata/mysql/my.cnf  /usrdata/mysql/my.cnf-org"',
              command => '/bin/sh -c "cd /usrdata/mysql; mv /usrdata/mysql/my.cnf  /usrdata/mysql/my.cnf-org"',
                path =>"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
} ->

file { '/usrdata/mysql/my.cnf':
  ensure  => file,
  content => '[mysqld]
user = mysql
port = 15306
basedir = /usrdata/mysql
datadir = /usrdata/mysql/data
tmpdir  = /tmp
log_error = /usrdata/logs/error.log
innodb_buffer_pool_size = 9000M
#nnodb_file_per_table = 1
# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%
# innodb_buffer_pool_size = 128
# Remove leading # to turn on a very important data integrity option: logging
# changes to the binary log between backups.
#        log_bin
#
# Instead of skip-networking the default is now to listen only on
# localhost which is more compatible and is not less secure.
#bind-address = 0.0.0.0
key_buffer = 16M
max_allowed_packet = 16M
thread_stack            = 192K
thread_cache_size       = 8',
} ->

exec {'script-download':
     command => "/usr/bin/wget --no-cache -e use_proxy=yes -e http_proxy=10.135.80.164:8678 -O /etc/init.d/mysql.server http://10.135.80.168/private_repo/PRIVATE_REPO/Mysql-5.6/mysql.server-newpath",
} ->

file { '/etc/init.d/mysql.server':
  ensure  => file,
  mode => 755,
} ->

file { '/usrdata/mysql/startscript.sh':
        ensure  => file,
  content => '#!/bin/bash
cd /usrdata/mysql/
chown -R root /usrdata/mysql
chown -R mysql /usrdata/mysql/data
./bin/mysqld_safe --user=mysql &  > /usrdata/source/statuslog
/etc/init.d/mysql.server start >> /usrdata/source/statuslog
./bin/mysqladmin -u root password "root123" >> /usrdata/source/statuslog
ps -ef | grep mysql > /usrdata/source/status',
          mode => 755,
} ->

exec { 'startscr':
command => '/bin/bash /usrdata/mysql/startscript.sh',
}


#exec {'mysql-start':
#    command => '/bin/sh -c "cd /usrdata/mysql; ./bin/mysqld_safe --user=mysql &"',
#     path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usrdata/mysql/bin",
#} -> 

#exec {'mysql-root':
#     command => "/usrdata/mysql/bin/mysqladmin -u root password 'root123'",
#}
