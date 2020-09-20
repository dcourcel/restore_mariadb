# Docker image to restore a mariaDB dump
This image restore a mariadb dump compressed as a bz2 archive to a mariadb server.


The information to specify to restore the dump can be either with environment variables or with command line arguments. The syntax of command line is [--delete-archive] MYSQL_HOST MYSQL_USER MYSQL_PASSWD_FILE ARCHIVE_NAME. Here is the explanation of the parameters.
| Variable           | Parameter         | Description                                        |
| ------------------ | ----------------- | -------------------------------------------------- |
| $DELETE_ARCHIVE    | --delete-archive  | If specified, The archive file will be deleted after the restoration if it succeeds. |
| $MYSQL_HOST        | MYSQL_HOST        | The host address to communicate with.              |
| $MYSQL_USER        | MYSQL_USER        | The username used to connect to the database.      |
| $MYSQL_PASSWD_FILE | MYSQL_PASSWD_FILE | The path to the file containing the password to use to connect to the database. |
| $ARCHIVE_NAME      | ARCHIVE_NAME      | The path and name of the bz2 archive file.         |

## Examples of execution
You can run the restoration by specifying the parameters with environment variables.
> docker run --env MYSQL_HOST=mariadb --env MYSQL_USER=root --env MYSQL_PASSWD_FILE=/root/passwd.txt --env ARCHIVE_NAME=/media/backup/my_database.sql.bz2 --network mariadb --mount type=volume,src=test_backup,dst=/media/backup --mount type=volume,src=mariadb_passwd,dst=/root restore_mariadb

You can also run the restoration by specifying the parameters with command line parameters.
> docker run --network mariadb --mount type=volume,src=test_backup,dst=/media/backup --mount type=volume,src=mariadb_passwd,dst=/root restore_mariadb mariadb root /root/passwd.txt /media/backup/my_database.sql.bz2
