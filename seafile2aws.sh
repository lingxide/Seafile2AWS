init(){

	###Please modify the following settings###


	#Source Path, the path that this script run with
	SOURCE="/root/seafile-backup";

	#Target Amazon S3 Bucket
	TARGET="s3://my-seafile-backup";

	#mysqldump module£¬Please use "which mysqldump" if you are uncertain about the mysqldump path
	mysqldump="/usr/bin/mysqldump";

	#Mysql Database credential
	USERNAME="mysqluser";
	PASSWORD='mysqlpass';

	#Databases that you would like to backup, separate with space for multiple databases
	DATABASE="ccnet-db seafile-db seahub-db";

	#Define Seafile Install Dir
	SEAFILE_DIR="/root";

	#Define Seafile Version
	SEAFILE_VERSION="6.2.9";

	#Define which day would you make a full backup in a month
	CONFIG_BACKUP_DATE="10";

	#Define log path

	LOG_DIR="/var/log/";

	###Please modify the above settings###

	DATE=`date --rfc-3339=date`;
}

backup(){
	[ -d $SOURCE ] && cd $SOURCE || mkdir $SOURCE && cd $SOURCE
	[ -d $LOG_DIR ] || mkdir $LOG_DIR
	$mysqldump -u $USERNAME --password=$PASSWORD --databases $DATABASE > mysql-$DATE.sql && gzip -f mysql-$DATE.sql
	[ $? -ne 0 ] && echo -e "$DATE Mysql Backup Failed" >> $LOG_DIR/seafile2aws.log || echo -e "$DATE Mysql Backup Successfully" >> $LOG_DIR/seafile2aws.log
	#If you want to modify backup dir, modify command below
	[[ `date +%d` == $CONFIG_BACKUP_DATE ]] && tar -cvzf config-$DATE.tar.gz $SEAFILE_DIR/ccnet $SEAFILE_DIR/conf $SEAFILE_DIR/pro-data $SEAFILE_DIR/seafile-data $SEAFILE_DIR/seafile-pro-server-$SEAFILE_VERSION $SEAFILE_DIR/seahub-data
	[[ `date +%d` == $CONFIG_BACKUP_DATE ]] && [ $? -ne 0 ] && echo -e "$DATE Config File Backup Failed" >> $LOG_DIR/seafile2aws.log 
	[[ `date +%d` == $CONFIG_BACKUP_DATE ]] && [ $? -eq 0 ] && echo -e "$DATE Config File Backup Successfully" >> $LOG_DIR/seafile2aws.log
}

upload(){
	#Mysql Upload
	aws s3 cp mysql-$DATE.sql.gz $TARGET
	[ $? -ne 0 ] && echo -e "$DATE Mysql Upload Failed" >> log/$LOG_DIR/seafile2aws.log || echo -e "$DATE Mysql Upload Successfully" >> $LOG_DIR/seafile2aws.log
	#Config Upload
	[[ `date +%d` == $CONFIG_BACKUP_DATE ]] && aws s3 cp config-$DATE.tar.gz $TARGET
	[[ `date +%d` == $CONFIG_BACKUP_DATE ]] && [ $? -ne 0 ] && echo -e "$DATE Config File Upload Failed" >> $LOG_DIR/seafile2aws.log
	[[ `date +%d` == $CONFIG_BACKUP_DATE ]] && [ $? -eq 0 ] && echo -e "$DATE Config File Upload Successfully" >> $LOG_DIR/seafile2aws.log
}

clean(){
	rm -f $SOURCE/*.sql.gz
	rm -f $SOURCE/*.tar.gz
}

main(){
	init
	backup
	upload
	clean
#	cat $LOG_DIR/seafile2aws.log
}

main