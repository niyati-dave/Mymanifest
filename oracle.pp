file { [ "/u01/oracle_binaries" ] :
   ensure => "directory",
} ->

exec  {'addhost':
  command => "echo \"`/sbin/ifconfig eth0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}'` `hostname` \"  >> /etc/hosts ",
   path =>"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
} ->

group { "oinstall":
ensure => present,
}

group { "dba":
ensure => present,
} 

file { '/etc/security/limits.d/90-nproc.conf':
ensure => file,
content => '# Default limit for number of user's processes to prevent
# accidental fork bombs.
# See rhbz #432903 for reasoning.

*          -    nproc     16384
root       soft    nproc     unlimited',
} ->

file { '/etc/selinux/config':
ensure => file,
content => '# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=permissive
# SELINUXTYPE= can take one of these two values:
#     targeted - Targeted processes are protected,
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted',
} ->

exec {'set-sel':
  command => "setenforce Permissive",
   path =>"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
} ->


exec {'iptab-1':
command => "/etc/init.d/iptables stop",
 path =>"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
} ->

exec {'iptab-2':
  command => "chkconfig iptables off",
  path =>"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
} ->

package {"oracle-rdbms-server-12cR1-preinstall":
ensure => "installed",
allow_virtual => false,
} ->

file_line { 'fs.file-max':
path  => '/etc/sysctl.conf',
  line  => 'fs.file-max = 6815744',
  match => 'file-max',
} ->

file_line { 'kernel.sem':
path  => '/etc/sysctl.conf',
  line  => 'kernel.sem = 250 32000 100 128',
  match => 'kernel.sem',
} ->

file_line { 'kernel.shmmni':
path  => '/etc/sysctl.conf',
  line  => 'kernel.shmmni = 4096',
   match => 'kernel.shmmni',
} ->

file_line { 'kernel.shmall':
path  => '/etc/sysctl.conf',
  line  => 'kernel.shmall = 1073741824',
   match => 'kernel.shmall',
} ->

file_line { 'kernel.shmmax':
path  => '/etc/sysctl.conf',
line  => 'kernel.shmmax = 81604378624',
match => 'kernel.shmmax',
} ->

file_line { 'net.core.rmem_default':
path  => '/etc/sysctl.conf',
line  => 'net.core.rmem_default = 262144'
match => 'net.core.rmem_default',
} ->

file_line { 'net.core.rmem_max':
path  => '/etc/sysctl.conf',
line  => 'net.core.rmem_max = 4194304', 
match => 'net.core.rmem_max',
} ->

file_line { 'net.core.wmem_default':
path  => '/etc/sysctl.conf',
line => 'net.core.wmem_default = 262144',
match => 'net.core.wmem_default'
} ->

file_line { 'net.core.wmem_max':
path  => '/etc/sysctl.conf',
line => 'net.core.wmem_max = 1048576',
match => 'net.core.wmem_max',
} ->

file_line { 'fs.aio-max-nr':
path => '/etc/sysctl.conf',
line => 'fs.aio-max-nr = 1048576',
match => 'fs.aio-max-nr',
} ->

file_line {'net.ipv4.ip_local_port_range':
path => '/etc/sysctl.conf',
line => 'net.ipv4.ip_local_port_range = 9000 65500',
match => 'net.ipv4.ip_local_port_range',
} ->

exec { 'sysctl-cmd':
command => "/sbin/sysctl -p",
} ->

exec {'limits-conf-file':
command => "echo \" oracle soft nofile 1024 
oracle hard nofile 65536 
oracle soft nproc 16384 
oracle hard nproc 16384 
oracle soft stack 10240 
oracle hard stack 32768 \" >> /etc/security/limits.conf "
} ->


$enhancers = [ "binutils", "compat-libcap1", "compat-libstdc++-33", "strace", "gcc", "glibc", "glibc-devel", "ksh", "libgcc", "libstdc++", "libstdc++-devel", "libaio", "libaio-devel", "libXext", "libXtst", "libX11", "libXau", "libxcb", "libXi", "make", "sysstat", "unixODBC" ]

package { $enhancers:

       ensure => "installed",
       allow_virtual => false,
 } ->


file { [ "/u01", "/u01/app", "/u01/app/oracle", "/u01/app/oracle/onlinearch", "/u01/app/oracle/fast_recovery_area", "/u01/oracle_binaries" ] :
ensure => "directory",
} ->

user { "oracle":
ensure => present,
groups => oinstall,
managehome => true,
home => '/u01/app/oracle',
shell => '/bin/bash',
password => '',
} ->

file { "/u01/app/oracle/.bash_profile":
ensure => file,
content => 'umask 022
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/12.1.0/dbhome_1
export ORACLE_SID=reimsdb
export PATH=/usr/sbin:$PATH
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_TERM=xterm
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/lib:/usr/lib:/usr/local/lib
export CLASSPATH=$ORACLE_HOME/JRE
export CLASSPATH=${CLASSPATH}:$ORACLE_HOME/jlib
export CLASSPATH=${CLASSPATH}:$ORACLE_HOME/rdbms/jlib
export TEMP=/tmp
export TEMPDIR=/tmp',
} ->

exec { 'mount-tmpfs':
command => "mount -t tmpfs shmfs -o size=77824m /dev/shm",
} ->

exec { 'add-infstab':
command => "echo \"tmpfs                   /dev/shm                tmpfs   size=77824m      0 0 \" >> /etc/fstab ",
} ->

exec {'oracle-download':
command => "/usr/bin/wget -e use_proxy=yes -e http_proxy=10.135.80.164:8678 -O /u01/oracle_binaries/oracle.zip http://10.135.80.168/private_repo/PRIVATE_REPO/   ", 
} ->

exec { 'install-oracle':
command => "DISPLAY=`hostname`:0.0;export DISPLAY;cd /u01/oracle_binaries; sh database/runInstaller",
path =>"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
}
