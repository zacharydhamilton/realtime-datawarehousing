#!/bin/sh

# Add the right configs before restarting
cat <<EOF > /var/lib/postgresql/data/postgresql.conf 
# LOGGING
# log_min_error_statement = fatal
# log_min_messages = DEBUG1

# CONNECTION
listen_addresses = '*'

# MODULES
shared_preload_libraries = 'decoderbufs,pg_cron'
cron.database_name='postgres'

# REPLICATION
wal_level = logical             # minimal, archive, hot_standby, or logical (change requires restart)
max_wal_senders = 25             # max number of walsender processes (change requires restart)
#wal_keep_segments = 4          # in logfile segments, 16MB each; 0 disables
wal_sender_timeout = 60s       # in milliseconds; 0 disables
max_replication_slots = 25       # max number of replication slots (change requires restart)
EOF

# Restart for configs to work 
pg_ctl -D "$PGDATA" -m fast -w restart