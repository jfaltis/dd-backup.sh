#!/bin/bash

directory=$PWD
notify_on_finish=false

function usage() {
	cat << EOF
	Usage: dd-backup.sh [OPTIONS]... [MOUNT_DIRS]...
	Backup MOUNT_DIRS to a .img file
	Example: ./dd-backup.sh -d /media/backup -n /home / /boot

	-d=DIRECTORY,    DIRECTORY where backups will be saved to
	-n,              Use notify-send to inform the user the backup is completed
EOF
}

# if no args are supplied print usage message
if [[ $# -eq 0 ]] ; then
    usage
    exit 0
fi

while getopts "nd:" o; do
  case $o in
    (n) notify_on_finish=true;;
    (d) directory=$OPTARG;;
  esac
done
shift $((OPTIND-1))

i=1

# for each mount directory supplied as argument
for mount_dir in "$@"
do
	mount_dir=${mount_dir%/} # remove trailing '/'
	# get line from df with partition, size and mount directory which matches $mount_dir
	partition=$(df -BM | awk '{print $1,$2,$6}' | awk '$NF ~ /^'$(echo $mount_dir | sed -e 's/\//\\\//g')'$/')

	if [ "$partition" = "" ]; then
		echo "Error: $mount_dir is not a mounted directory"
		((i++))
		continue
	fi

	if=$(echo $partition | awk '{print $1}') # partition (eg. /dev/sda5)
	p_size=$(echo $partition | awk '{print $2}') # get size for ETA of pv
 	
	# transform mount_dir to filename
	file_name=$(echo $partition | awk '{print $NF}' |sed 's/^\///' | sed 's/\//-/g')

	# if "/" is supplied set file name to root.img
	if [ "$file_name" = "" ]; then
		file_name="root"
	fi

	echo "($i/$#) Making backup of $if ($p_size) => ${directory%/}/$file_name.img"

	# if pv is installed use it for progress display
	if command -v pv >/dev/null 2>&1; then
		sudo dd if=$if status=none | sudo pv -petra -s $p_size > ${directory%/}/$file_name.img
	else
		echo "Install pv for detailed backup progress with ETA (Estimated time of arrival)"
		sudo dd if=$if status=progress of="${directory%/}/$file_name.img"
	fi

	((i++))
	echo 
done

if [[ "$notify_on_finish" = true ]]; then
	if command -v notify-send >/dev/null 2>&1; then
		notify-send backup.sh "Finished backup."
	else
		echo "Option -n was supplied but notify-send is not installed"
	fi
fi	
