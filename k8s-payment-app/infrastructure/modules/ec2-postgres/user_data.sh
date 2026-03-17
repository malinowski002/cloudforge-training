#!/bin/bash
set -e

# format and mount the data volume
mkfs -t xfs /dev/xvdf
mkdir -p /var/lib/postgresql
echo '/dev/xvdf /var/lib/postgresql xfs defaults,nofail 0 2' >> /etc/fstab
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