#!/bin/bash
# startup.sh
# Entrypoint for the PostgreSQL container

# Default password if not provided
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-postgres}

# Check if the database data directory is empty
if [ -z "$(ls -A $PGDATA)" ]; then
    echo "Initializing PostgreSQL database..."
    
    # Initialize the database cluster
    initdb -D "$PGDATA"
    
    # Configure postgresql.conf to listen on all addresses
    echo "listen_addresses = '*'" >> "$PGDATA/postgresql.conf"
    
    # Configure pg_hba.conf to allow connections from any IP
    echo "host all all 0.0.0.0/0 scram-sha-256" >> "$PGDATA/pg_hba.conf"
    
    # Start the server temporarily in the background to create the user
    pg_ctl -D "$PGDATA" -w start
    
    echo "Setting password for user postgres..."
    psql -c "ALTER USER postgres WITH PASSWORD '$POSTGRES_PASSWORD';"
    
    # Stop the temporary server
    pg_ctl -D "$PGDATA" -m fast -w stop
    
    echo "Database initialization complete."
fi

# Start the PostgreSQL server in the foreground
echo "Starting PostgreSQL server..."
exec postgres -D "$PGDATA"
