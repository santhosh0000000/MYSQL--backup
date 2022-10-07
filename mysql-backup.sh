#!/bin/bash

# List all of the MySQL databases that you want to backup in here,
databases="db_name"
backup_path="/mysql_bkup"

# MySQL dump command, use the full path name here
mysqldumpcmd=/usr/bin/mysqldump

# MySQL Username and password
userpassword=" --user=root --password=stackmax"


# MySQL dump options
dumpoptions=" --quick --add-drop-table --add-locks --extended-insert --lock-tables"

# Unix Commands
gzip=/bin/gzip
mail=/bin/mail

# Send Backup?  Would you like the backup emailed to you?
# Set to "y" if you do
sendbackup="n"
subject="Backup is done"
mailto="sahul.s@open-v.net"

date=$(date +"%Y-%m-%d %H:%M:%S")

# Create our backup directory if not already there
mkdir -p ${backupdir}
if [ ! -d ${backupdir} ]
then
   echo "Not a directory: ${backupdir}"
   exit 1
fi

# Dump all of our databases
echo "Dumping MySQL Databases"
for database in $databases
do
   $mysqldumpcmd $userpassword $dumpoptions $database > ${backupdir}/$date-${database}.sql
done

# Compress all of our backup files
echo "Compressing Dump Files"
for database in $databases
do
  tar -czf ${backupdir}/${date}-${database}.sql.gz "${backupdir}/${date}-${database}.sql"

done


if [ $sendbackup = "y" ]
then
   for database in $databases
   do
     $mail -s "$subject : $database" $mailto <${backupdir}/${date}-${database}.sql.gz
   done
fi

# print end status message
echo "."
echo "."
echo "."
echo "... Backup SUCCESS!"
date
echo ""
echo "Delete old files !"
find $dest -mtime +30 -type f -delete
echo ""

# And we're done
ls -l ${backupdir}
echo "Dump Complete!"
exit
