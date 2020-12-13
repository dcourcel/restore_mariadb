#!/bin/ash

set -o pipefail

function cleanup()
{
    # Kill the background task if it exists before removing the backup file
    kill %1 2> /dev/null
    if [ -f "$BACKUP_FILE" ]; then
        rm -f "$BACKUP_FILE"
    fi
    exit 3
}

trap 'cleanup' SIGINT
trap 'cleanup' SIGTERM

# Read parameters from command line if there is at least one parameter.
# Otherwise, the environment variables are assumed to be already defined.
if [ -n "$1" ]; then
    DELETE_ARCHIVE=""
    while [ $# -eq 0 -a "${1::2}" = "--" ]; do
        case $1 in
            "--delete-archive")
            DELETE_ARCHIVE=yes
            ;;

            *)
            echo "Invalid parameter $1"
            exit 2
            ;;
        esac
        shift
    done

    MYSQL_HOST="$1"
    MYSQL_USER="$2"
    MYSQL_PASSWD_FILE="$3"
    BACKUP_FOLDER="$4"
    ARCHIVE_NAME="$5"
    DATE_DIR_FILE="$6"
fi

# Verify if arguments exist
ERR=0
if [ -z "$MYSQL_HOST" ]; then
    echo 'Error. No host specified.'
    ERR=1
fi
if [ -z "$MYSQL_USER" ]; then
    echo 'Error. No user specified.'
    ERR=1
fi
if [ ! -f "$MYSQL_PASSWD_FILE" ]; then
    echo 'Error. No password file specified or the file doesn'\''t exist.'
    ERR=1
fi
if [ -z "$BACKUP_FOLDER" ]; then
    echo '$BACKUP_FOLDER' is not defined
    ERR=1
fi;
if [ -n "$DATE_DIR_FILE" ]; then
    if [ ! -f "$DATE_DIR_FILE" ]; then
        echo "\$DATE_DIR_FILE ($DATE_DIR_FILE) is not a file."
        ERR=1
    else
        date_dir=$(head -n 1 $DATE_DIR_FILE)
        if [ -z "$date_dir" ]; then
            echo "The file $DATE_DIR_FILE is empty."
            ERR=1
        fi
    fi
else
    echo "\$DATE_DIR_FILE is not defined."
    ERR=1
fi;
BACKUP_FILE=/media/backup/$BACKUP_FOLDER/$date_dir/$ARCHIVE_NAME
if [ $ERR -eq 0 ]; then
    if [ -z "$ARCHIVE_NAME" ]; then
        echo "\$ARCHIVE_NAME is empty."
        ERR=1
    elif [ ! -f "$BACKUP_FILE" ]; then
        echo "The file $BACKUP_FILE doesn't exist."
        ERR=1
    fi
fi

if [ $ERR -eq 1 ]; then
     exit 1
fi;


echo '----------------------------------------'
echo 'Begin Database restoration.'

# Extract the archive and execute it with mysql.
bzip2 -cd "$BACKUP_FILE" | mysql "-h$MYSQL_HOST" "-u$MYSQL_USER" "-p$(cat $MYSQL_PASSWD_FILE)" &
wait $!


ERR_CODE="$?"
if [ $ERR_CODE -eq 0 ]; then
    if [ -n "$DELETE_ARCHIVE" ]; then
        echo "Delete file $BACKUP_FILE"
        rm -f "$BACKUP_FILE"
    fi
    echo 'Database restoration completed.'
else
    echo "Database backup failed with error code $ERR_CODE"
fi
echo -e '----------------------------------------\n'
exit $ERR_CODE
