#!/bin/bash

DATE=$(date +"%Y%m%d%H%M")

CONTAINER_NAME=medapp_db_1
DB_NAME=medfinals
DB_USER=medfinals
DB_PASSWORD=0161Mannyonthemap
BACKUP_DIR="/home/ubuntu/backups"

find $BACKUP_DIR -name "db_backup_*.sql" -type f -mtime +7 -exec rm -f {} \;

docker exec -e PGPASSWORD=$DB_PASSWORD $CONTAINER_NAME pg_dump -U $DB_USER $DB_NAME > $BACKUP_DIR/db_backup_$DATE.sql

echo "Backup created at $BACKUP_DIR/db_backup_$DATE.sql"
