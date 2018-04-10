# Seafile2AWS

## Description

Backup your Seafile Config and Mysql Databases into Amazon S3.

Now this script enables an everyday databases backup and a monthly full config backup.

## Prerequisites

 - Please make sure that `pip` is already installed. If not, run the following command:

```
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py
```

 - Please make sure that `awscli` is already installed. If not, run the following command:

```
pip install awscli
```

 - Please make sure that AWS CLI is already configured. If not, run the following command:

```
aws configure
```

     Notice: Please prepare for your AWS Access Key ID and AWS Secret Access Key

Follow the guide and complete the initial configuration.

## Script Setting

After you download the script, please modify the configuration in `init` function.

If you need to change backup file, you will need to modify the `backup` function to make sure you backuped the right files.

## Show Log

If you need to review backup status, you can visit `log` directory located in your source path.

## Crontab Configuration

use `crontab -e` and add `0 2 * * * /path/seafile2aws.sh` to create a cron job run this backup in 2AM everyday.

## License

GPL v3

## Author

Liaochong