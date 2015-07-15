#!/bin/bash
# TAJ @ Mirantis

DATE=$(date "+%H:%M:%S %m/%d/%Y");
HOSTNAME=$(uname -n);
SCRIPT_LOG_FILE="/tmp/$basename_$(date '+%H%M%S%m%d%Y').log";
PLATFORM=$(python -mplatform);
GET_ROOT_SHELL=$(getent passwd root | cut -d: -f7);
GET_ROOT_SHELL_LAST=$(getent passwd root | cut -d: -f 7 | cut -d/ -f3);

# REVERSE 0 = STANDARD OPERATIONS!
# REVERSE 1 = REVERSE CHANGES!
REVERSE=0;

# TESTRUN 0 = PERFORM CHANGES
# TESTRUN 1 = JUST SIMULATE
TESTRUN=0;

RETURNCODE=0;

MSG() {
        echo $@ | tee -a $SCRIPT_LOG_FILE;
};

CHECK_MSG() {
        echo "> Performing: $1" | tee -a $SCRIPT_LOG_FILE;
        echo ">Description: $2" | tee -a $SCRIPT_LOG_FILE;
};

CHECK_STATUS() {
        if [ $? -ne 0 ]; then
                echo "ERROR: $F" | tee -a $SCRIPT_LOG_FILE;
                exit 1;
        fi
};

MSG "Creating LOG File: $SCRIPT_LOG_FILE";


F="No.1";
CHECK_MSG "$F" "Limit Access To The Root Account From su ";
SU_PAM_FILE="/etc/pam.d/su";

if [ $REVERSE -eq 0 ]; then
        if [ -e $SU_PAM_FILE ]; then
                sed -i 's/\(#\).*.\(auth.*.required.*.pam_wheel.so$\)/\2/g' $SU_PAM_FILE;
        fi
fi

#REVERSE - No.1
if [ $REVERSE -eq 1 ]; then
        CHECK_MSG "$F" "REVERSING -> Limit Access To The Root Account From su ";
        sed -i 's/\(auth.*.required.*.pam_wheel.so$\)/#\1/g' $SU_PAM_FILE;
fi
#----------------------------------------------------

F="No.2";
CHECK_MSG "$F" "Changing wtmp permissions";
WTMP_FILE="/var/log/wtmp";

if [ $REVERSE -eq 0 ]; then
        chmod 0622 $WTMP_FILE;
fi

if [ $REVERSE -eq 1 ]; then
        chmod 0644 $WTMP_FILE;
fi


F="No.3";
CHECK_MSG "$F" "Changing messages permissions";
MESSAGE_FILE="/var/log/messages";

if [ $REVERSE -eq 0 ]; then
        chmod 0622 $MESSAGE_FILE;
fi

if [ $REVERSE -eq 1 ]; then
        chmod 0640 $MESSAGE_FILE;
fi


F="No.5";
CHECK_MSG "$F" "Restrict cron To Authorized Users - Checking if 'root' exists in /etc/cron.allow.";
CRON_ALLOW_FILE="/etc/cron.allow";

if [ $REVERSE -eq 0 ]; then

  if [ ! -e $CRON_ALLOW_FILE ]; then
   touch $CRON_ALLOW_FILE;
  else
   cp $CRON_ALLOW_FILE $CRON_ALLOW_FILE.bak;
  fi
  echo "root" > $CRON_ALLOW_FILE;
  for i in $(ls /var/spool/cron/crontabs);do echo $i >> $CRON_ALLOW_FILE; done;

fi

if [ $REVERSE -eq 1 ]; then
  CHECK_MSG "$F" "REVERSING Restrict at/cron To Authorized Users - Checking if 'root' exists in /etc/cron.allow";
  if [ -e $CRON_ALLOW_FILE ]; then
   rm $CRON_ALLOW_FILE;
  fi
  if [ -e $CRON_ALLOW_FILE.bak ]; then
   cp $CRON_ALLOW_FILE.bak $CRON_ALLOW_FILE;
  fi
fi

F="No.6";
CHECK_MSG "$F" "Restrict at To Authorized Users - Checking if 'root' exists in /etc/at.allow.";
CRON_ALLOW_FILE="/etc/at.allow";

if [ $REVERSE -eq 0 ]; then
  if [ ! -e $CRON_ALLOW_FILE ]; then
   touch $CRON_ALLOW_FILE;
  else
   cp $CRON_ALLOW_FILE $CRON_ALLOW_FILE.bak;
  fi
  echo "root" > $CRON_ALLOW_FILE;
  for i in $(ls /var/spool/cron/crontabs);do echo $i >> $CRON_ALLOW_FILE;done;
fi

if [ $REVERSE -eq 1 ]; then
  CHECK_MSG "$F" "REVERSING Restrict at/cron To Authorized Users - Checking if 'root' exists in /etc/cron.allow";
  if [ -e $CRON_ALLOW_FILE ]; then
   rm $CRON_ALLOW_FILE;
  fi
  if [ -e $CRON_ALLOW_FILE.bak ]; then
   cp $CRON_ALLOW_FILE.bak $CRON_ALLOW_FILE;
  fi
fi


F="No.7";
CHECK_MSG "$F" "Restrict at To Authorized Users - /etc/at.deny";
AT_DENY_FILE="/etc/at.deny";

if [ $REVERSE -eq 0 ]; then
        if [ ! -e $AT_DENY_FILE ]; then
                touch $AT_DENY_FILE;
        fi
fi

if [ $REVERSE -eq 1 ]; then
        if [ -e $AT_DENY_FILE ]; then
                rm $AT_DENY_FILE;
        fi
fi



F="No.12";
CHECK_MSG "$F" "Enforcing limits - Disabling core dumps";
LIMITS_FILE="/etc/security/limits.conf";

if [ $REVERSE -eq 0 ]; then
        if [ -e $LIMITS_FILE ]; then
                echo "* hard core 0" | tee -a $LIMITS_FILE;
        fi
fi

#REVERSE - No.1
if [ $REVERSE -eq 1 ]; then
        CHECK_MSG "$F" "REVERSING -> Enforcing limits - Disabling core dumps";
        sed -i "/* hard core 0/d" $LIMITS_FILE;
fi

F="No.29..41";
CHECK_MSG "$F" "Disabling services";

if [ $REVERSE -eq 0 ]; then
        for i in ypbind autofs oddjobd ntpdate atdabrtd avahi tftp ypbind systat rstatd finger rhnsd;
                do
                 initctl stop $i;
                 if [ -e /etc/init.d/$i ]; then
                        echo "manual" >> /etc/init/$i.override;
                 fi
        done

fi

#REVERSE - No.29..41
if [ $REVERSE -eq 1 ]; then
        CHECK_MSG "$F" "REVERSING -> Disabling services";
        for i in ypbind autofs oddjobd ntpdate atdabrtd avahi tftp ypbind systat rstatd finger rhnsd;
                do
                 if [ -e /etc/init.d/$i.override ]; then
                        initctl start $i;
                        rm /etc/init/$i.override;
                fi
        done
fi

F="No.689"
CHECK_MSG "$F" "CHeck if user sync can login to shell or not";
PASSWD_FILE="/etc/passwd"
if  [ $REVERSE -eq 0 ]; then
  sed -i 's/\/bin\:\/bin\/sync/\/bin\:\/usr\/sbin\/nologin/g' $PASSWD_FILE
fi

if [ $REVERSE -eq 1 ]; then
        CHECK_MSG "$F" "REVERSING -> CHeck if user sync can login to shell or not";
sed -i 's/\/bin\:\/usr\/sbin\/nologin/\/bin\:\/bin\/sync/g' $PASSWD_FILE
fi



F="No.715"
CHECK_MSG "$F" "CHeck if user games can login to shell or not";
if  [ $REVERSE -eq 0 ]; then
  sed -i 's/\/usr\/games\:\/bin\/sh/\/usr\/games\:\/usr\/sbin\/nologin/g'     $PASSWD_FILE
fi

if [ $REVERSE -eq 1 ]; then
   CHECK_MSG "$F" "REVERSING -> CHeck if user games can login to shell or not";
 sed -i 's/\/usr\/games\:\/usr\/sbin\/nologin/\/usr\/games\:\/bin\/sh/g'     $PASSWD_FILE
fi

F="No.717"
CHECK_MSG "$F" "CHeck if user lp can login to shell or not";
if  [ $REVERSE -eq 0 ]; then
  sed -i 's/\/var\/spool\/lpd\:\/bin\/sh/\/var\/spool\/lpd\:\/usr\/sbin\/nologin/g' $PASSWD_FILE
fi

if [ $REVERSE -eq 1 ]; then
   CHECK_MSG "$F" "REVERSING -> CHeck if user lp can login to shell or not";
sed -i 's/\/var\/spool\/lpd\:\/usr\/sbin\/nologin/\/var\/spool\/lpd\:\/bin\/sh/g'    $PASSWD_FILE
fi

F="No.718"
CHECK_MSG "$F" "CHeck if user nobody can login to shell ";
if  [ $REVERSE -eq 0 ]; then
  sed -i 's/\/nonexistent\:\/bin\/sh/\/nonexistent\:\/usr\/sbin\/nologin/g'  $PASSWD_FILE
fi

if [ $REVERSE -eq 1 ]; then
   CHECK_MSG "$F" "REVERSING -> CHeck if user nobody can login to shell ";
sed -i 's/\/nonexistent\:\/usr\/sbin\/nologin/\/nonexistent\:\/bin\/sh/g'    $PASSWD_FILE
fi

F="No.721"
CHECK_MSG "$F" "CHeck if user uucp can login to shell "
if  [ $REVERSE -eq 0 ]; then
  sed -i 's/\/var\/spool\/uucp\:\/bin\/sh/\/var\/spool\/uucp\:\/usr\/sbin\/nologin/g'    $PASSWD_FILE
fi

if [ $REVERSE -eq 1 ]; then
   CHECK_MSG "$F" "REVERSING -> CHeck if user uucp can login to shell ";
sed -i 's/\/var\/spool\/uucp\:\/usr\/sbin\/nologin/\/var\/spool\/uucp\:\/bin\/sh/g'   $PASSWD_FILE
fi

F="No.734"
CHECK_MSG "$F" "Permissions for the encrypted account password";
if  [ $REVERSE -eq 0 ]; then
   chmod 0600 /etc/gshadow
fi

if [ $REVERSE -eq 1 ]; then
   CHECK_MSG "$F" "REVERSING -> Permissions for the encrypted account password";
chmod 0644 /etc/gshadow
fi

F="No.735"
CHECK_MSG "$F" "Permissions for the interfaces that allow root login";
if  [ $REVERSE -eq 0 ]; then
   chmod 0600 /etc/securetty
fi

if [ $REVERSE -eq 1 ]; then
   CHECK_MSG "$F" "REVERSING -> Permissions for the interfaces that allow root login";
chmod 0644 /etc/securetty
fi

F="No.703"
CHECK_MSG "$F" "Permissions for the user permitted to use cron";
if  [ $REVERSE -eq 0 ]; then
 chmod 0400 /etc/cron.allow
fi

if [ $REVERSE -eq 1 ]; then
   CHECK_MSG "$F" "REVERSING ->  Permissions for the user permitted to use crona";
chmod 0644 /etc/cron.allow
fi

F="No.052"
CHECK_MSG "$F" "Changing shadow file permissions";
SHADOW_FILE="/etc/shadow";

if [ $REVERSE -eq 0 ]; then
        chmod 0400 $SHADOW_FILE;
fi

if [ $REVERSE -eq 1 ]; then
CHECK_MSG "$F" "Reversing -> Changing shadow file permissions";
        chmod 0640 $SHADOW_FILE;
fi

#----------------------------------------------------------------

F="No.046";
CHECK_MSG "$F" "Changing cron dir permissions";
CRON_DIR="/var/spool/cron";

if [ $REVERSE -eq 0 ]; then
        chmod 0640 $CRON_DIR;
fi


if [ $REVERSE -eq 1 ]; then
CHECK_MSG "$F" "Reversing-> Changing cron dir permissions"
chmod 0755 $CRON_DIR;
fi




##Banner##
MOTD_HEAD="/etc/update-motd.d/00-header";

echo "printf '"This system is for the use of authorized users only. Individuals using this computer system without authority, or in excess of their authority, are subject to having all of their activities on this system monitored and recorded by system personnel. In the course of monitoring individuals improperly using this system, or in the course of system maintenance, the activities of authorized users may also be monitored. Anyone using this system expressly consents to such monitoring and is advised that if such monitoring reveals possible evidence of criminal activity, system personnel may provide the evidence of such monitoring to law enforcement officials."' " >> $MOTD_HEAD



exit 0;
#EOF

