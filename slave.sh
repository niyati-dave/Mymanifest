#!/bin/bash
echo "Enter Current/Present internal Ip address of  Master server or FQDN name:"
read MIP
echo "Enter Internal Ip address of  Slave server or FQDN name:"
read SIP
#echo $MIP
#echo $SIP
CIP=`/sbin/ifconfig| grep "inet " | grep -v 127.0.0.1 | awk {'print $2'} | sed -e's/addr://g'`
#echo $CIP
if [ $SIP == $CIP ]
then
   echo " Correct: This is slave server"

### Take data/conf files backup 
dt=`date +%d%m%Y`
tar -cf /home/postgres/data-orig-master-$dt.tar /usr/local/pgsql-9.3/data

############# DB Backup section Start###########

#Take DB Backup from Orig slave server, restore it.
#ssh postgres@"$SIP" 
#ssh   postgres@"$SIP" "sh /home/postgres/bakup.sh"
echo "Take DB Backup from Orig slave server, restore it."
#ssh   postgres@$MIP '/usr/local/pgsql-9.3/bin/psql -c "select pg_start_backup('replibackup');"' 
ssh  postgres@192.168.59.24 /usr/local/pgsql-9.3/bin/psql <<'__END__'
SELECT pg_start_backup('replibackup');
__END__
ssh postgres@$MIP 'cd /usr/local/pgsql-9.3; tar -cf /tmp/data-bkp.tar data'
ssh   postgres@$MIP '/usr/local/pgsql-9.3/bin/psql -c "select pg_stop_backup();"'

scp postgres@$MIP:/tmp/data-bkp.tar /usr/local/pgsql-9.3/
#################End of DB Backup section########################

###################Restore Backup Tar##############
echo "checking postgres service is runing or not"
    STR=`ps -ef | grep postgres | grep checkpointer | grep -v grep | awk {'print $NF'}`
    if [ -z $STR ]
    then
        echo " service is not runing so extract the backup....."
        rm -rf /usr/local/pgsql-9.3/data
        cd /usr/local/pgsql-9.3/
        tar xf data-bkp.tar
    else
         echo "postgres service is running"
        /usr/local/pgsql-9.3/bin/pg_ctl -D /usr/local/pgsql-9.3/data -l logfile stop
        rm -rf /usr/local/pgsql-9.3/data
        cd /usr/local/pgsql-9.3/
        tar xf data-bkp.tar
    fi
###############End of Restore backup##################

###################Edit Conf file to make orig master to new slave ######################
     fin=`cat /usr/local/pgsql-9.3/data/pg_hba.conf | grep $MIP | grep -v "#"`
     echo $fin     
if [ -z $fin ]
     then
         echo "There is no slave entry pg_hba.conf file...."
          echo "host    replication    replicator  $MIP/32    md5" >> /usr/local/pgsql-9.3/data/pg_hba.conf
          echo "slave entry $MIP done in pg_hba.conf"
     else
         echo "There is already $MIP in pg-hba.conf"
     fi
    fin1=`cat /usr/local/pgsql-9.3/data/postgresql.conf | grep "hot_standby = on" | grep -v "#"`
    if [ -z $fin1 ]
    then
       echo "There is no hot_standby entry in postgresql.conf"
        echo "hot_standby = on" >> /usr/local/pgsql-9.3/data/postgresql.conf    
         sed -i 's/hot_standby\ \=\ off/\#hot_standby\ \=\ off/g' /usr/local/pgsql-9.3/data/postgresql.conf
         echo " Hot standby parameter added now"
else
    echo " There is hot_standby entryi, no action required "         
     # sed -i 's/hot_standby\ \=\ on/\#hot_standby\ \=\ off/g' /usrdata/pgsql/data/postgresql.conf
    fi 
 
cd /usr/local/pgsql-9.3/data
if [ -f recovery.done ]
then
  echo " Removing old recovery config"
  rm  /usr/local/pgsql-9.3/data/recovery.done
  echo " Adding new recovery conf"
   touch /usr/local/pgsql-9.3/data/recovery.conf
  echo "standby_mode = on" > /usr/local/pgsql-9.3/data/recovery.conf
  echo "trigger_file = '/tmp/postgresql.trigger'" >> /usr/local/pgsql-9.3/data/recovery.conf
  echo "primary_conninfo = 'host=$MIP  port=5432  user=replicator password=replicator'" >> /usr/local/pgsql-9.3/data/recovery.conf
else
  echo "No recovery config exists, so we will add a new conf file"
  touch /usr/local/pgsql-9.3/data/recovery.conf
  echo "standby_mode = on" > /usr/local/pgsql-9.3/data/recovery.conf
  echo "trigger_file = '/tmp/postgresql.trigger'" >> /usr/local/pgsql-9.3/data/recovery.conf
  echo "primary_conninfo = 'host=$MIP  port=5432  user=replicator password=replicator'" >> /usr/local/pgsql-9.3/data/recovery.conf
fi


# Now check the process
    
    echo "Start the service "
      /usr/local/pgsql-9.3/bin/pg_ctl -D /usr/local/pgsql-9.3/data -l logfile start
    
    
else
echo " this is not slave server"
fi
