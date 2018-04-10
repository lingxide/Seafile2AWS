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


	###Please modify the above settings###

	DATE=`date --rfc-3339=date`;
}

backup(){
	[ -d $SOURCE ] && cd $SOURCE || mkdir $SOURCE && cd $SOURCE
	[ -d $SOURCE/log ] || mkdir $SOURCE/log
	$mysqldump -u $USERNAME --password=$PASSWORD --databases $DATABASE > mysql-$DATE.sql && gzip -f mysql-$DATE.sql
	[ $? -ne 0 ] && echo -e "Mysql Backup Failed" >> $DATE-Backup.log || echo -e "Mysql Backup Successfully" >> log/$DATE-Backup.log
	#If you want to modify backup dir, modify command below
	[[ `date +%d` == $CONFIG_BACKUP_DATE ]] && tar -cvzf config-$DATE.tar.gz $SEAFILE_DIR/ccnet $SEAFILE_DIR/conf $SEAFILE_DIR/pro-data $SEAFILE_DIR/seafile-data $SEAFILE_DIR/seafile-pro-server-$SEAFILE_VERSION $SEAFILE_DIR/seahub-data
	[[ `date +%d` == $CONFIG_BACKUP_DATE ]] && [ $? -ne 0 ] && echo -e "Config File Backup Failed" >> $DATE-Backup.log || echo -e "Config File Backup Successfully" >> log/$DATE-Backup.log
}

upload(){
	#Mysql Upload
	aws s3 cp mysql-$DATE.sql.gz $TARGET
	[ $? -ne 0 ] && echo -e "Mysql Upload Failed" >> log/$DATE-Backup.log || echo -e "Mysql Upload Successfully" >> log/$DATE-Backup.log
	#Config Upload
	[[ `date +%d` == $CONFIG_BACKUP_DATE ]] && aws s3 cp config-$DATE.tar.gz $TARGET
	[[ `date +%d` == $CONFIG_BACKUP_DATE ]] && [ $? -ne 0 ] && echo -e "Config File Upload Failed" >> $DATE-Backup.log || echo -e "Config File Upload Successfully" >> log/$DATE-Backup.log
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
	cat log/$DATE-Backup.log
}

main