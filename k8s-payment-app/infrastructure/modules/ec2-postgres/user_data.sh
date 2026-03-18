#!/bin/bash
set -e

# format and mount the data volume (NVMe device name on Nitro instances)
DATA_DEVICE=$(lsblk -dpno NAME,TYPE | awk '$2=="disk" && $1!~/nvme0/ {print $1; exit}')
mkfs -t xfs "$DATA_DEVICE"
mkdir -p /var/lib/postgresql
echo "$DATA_DEVICE /var/lib/postgresql xfs defaults,nofail 0 2" >> /etc/fstab
mount -a

# install PostgreSQL 16
dnf install -y postgresql16 postgresql16-server

# init db on the data volume
PGDATA=/var/lib/postgresql/data
mkdir -p "$PGDATA"
chown postgres:postgres "$PGDATA"
chmod 700 "$PGDATA"

sudo -u postgres /usr/bin/initdb -D "$PGDATA"

# configure PostgreSQL to listen on all interfaces
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PGDATA/postgresql.conf"

# allow password auth from VPC CIDR
echo "host  all  all  10.20.0.0/16  scram-sha-256" >> "$PGDATA/pg_hba.conf"

# start end enable
systemctl enable postgresql
PGDATA="$PGDATA" systemctl start postgresql

# create DB, user and set password
sudo -u postgres psql <<SQL
CREATE DATABASE payments;
CREATE USER payments WITH ENCRYPTED PASSWORD '${db_password}';
GRANT ALL PRIVILEGES ON DATABASE payments TO payments;
\c payments
GRANT ALL ON SCHEMA public TO payments;
SQL

# create backup script
cat > /usr/local/bin/db-backup.sh <<'SCRIPT'
#!/bin/bash
BACKUP_DIR="/var/backups/postgresql"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/payments_$TIMESTAMP.dump"
mkdir -p "$BACKUP_DIR"
PGPASSWORD="${db_password}" pg_dump -h localhost -U payments -d payments -Fc -f "$BACKUP_FILE"
find "$BACKUP_DIR" -name "*.dump" -mtime +7 -delete
SCRIPT

chmod +x /usr/local/bin/db-backup.sh
mkdir -p /var/backups/postgresql
chown postgres:postgres /var/backups/postgresql

# schedule daily backup at 2 AM
echo "0 2 * * * postgres /usr/local/bin/db-backup.sh" > /etc/cron.d/postgresql-backup
chmod 644 /etc/cron.d/postgresql-backup