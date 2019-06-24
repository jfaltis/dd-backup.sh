# dd-backup.sh
A shellscript to back up multiple file systems with **progress visualizazion**, **estimated time of arrival** (ETA) and **notification** on finish. It saves an image file of each supplied mount directory to any given directory.

## Requirements
The shellscript will work without any additional software. However to provide an estimation of how long the backup process will take the Pipe Viewer ```pv``` is needed. The notification which will be displayed once the backup of all file systems has finished requires ```notify-send```

1. [pv](https://github.com/icetee/pv)
2. [notify-send](http://vaskovsky.net/notify-send/linux.html)
## Examples
Backup **boot**, **home** and **root** partition to /media/backups

```./dd-backup.sh -d /media/backups /boot /home /```

Backup **home** partition to current directory and send a notification on finish

```./dd-backup.sh -n /home```

**Output example**
```  
[jfaltis@jfaltis-pc ~]$ ./dd-backup.sh -d /media/toshiba/backups -n /boot /home
(1/2) Making backup of /dev/sda5 (500M) => /media/toshiba/backups/boot.img
0:00:14 [34,6MiB/s] [34,6MiB/s] [========================================================>] 100%            

(2/2) Making backup of /dev/sda8 (23984M) => /media/toshiba/backups/home.img
0:13:55 [29,3MiB/s] [29,3MiB/s] [=========================================================] 100%
```
## Usage
Make sure not to run the script as root because this prevents the notification from showing up
```
backup.sh [OPTIONS]... [MOUNT_DIRS]...

-d=DIRECTORY:    DIRECTORY where backups will be saved to. Default is the current directory

-n:              Use notify-send to inform the user the backup is completed
```
You can use ```df``` to see what file systems are mounted on which directory.
