class mbss {

####Limit Access To The Root Account From su 
 case $operatingsystem {
               centos, redhat: {
                       exec { "sed":
                             command => "sed -i 's/^#auth.*.required.*.pam_wheel.so.*.use_uid.*/auth           required        pam_wheel.so use_uid/g' /etc/pam.d/su",
                             path    => "/usr/local/bin/:/bin/",

                             }
                }
              debian, ubuntu: {
                         
                       exec { "sed":
                             command => "sed -i 's/\#auth       required   pam_wheel.so/auth       required   pam_wheel.so/g' /etc/pam.d/su",
                             path    => "/usr/local/bin/:/bin/",

                             }
                  }
  }

#########Enforcing limits - Disabling core dumps######
  exec { sed-limit:
      command => "sed -i '/* .*.hard.*.core.*.0/d'  /etc/security/limits.conf ",
      path =>  "/usr/local/bin/:/bin/",
  }

###############Changing wtmp permissions############
 file { "/var/log/wtmp":
     mode => 622,
 }

##############CHanging perms in logrotate.conf#######
exec { "logrotate":
    command => "sed -i 's/0664/0644/g' /etc/logrotate.conf", 
    path =>  "/usr/local/bin/:/bin/",
}

############## Changing messages permissions ##########
  file { "/var/log/messages":
    mode => 622,
  }

############### Restrict cron To Authorized Users ########
  exec { "cron-script":
          command => "touch /etc/cron.allow",
          path => "/bin:/usr/local/bin",
  }

############# Restrict at To Authorized Users #########
  exec { "at-script":
          command => "touch /etc/at.allow",
          path => "/bin:/usr/local/bin",
  } 


  file { "/etc/at.deny":
        ensure => "present",
  } 

########### Disabling services #########
  service { ["ypbind", "autofs", "oddjobd", "ntpdate", "atdabrtd", "avahi", "tftp", "systat", "rstatd", "finger", "rhnsd" ] :
  ensure => "stopped",
  enable => false,

  }

}
