FROM oraclelinux:8

ENV PG_VERSION=16 \
    PGDATA=/var/lib/pgsql/16/data \
    PATH=/usr/pgsql-16/bin:$PATH

# Install PostgreSQL 16 repository and server
RUN dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm && \
    dnf -qy module disable postgresql && \
    dnf install -y postgresql16-server && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Copy the startup script
COPY startup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/startup.sh && \
    chown postgres:postgres /usr/local/bin/startup.sh

# Ensure data directory has correct permissions
RUN mkdir -p /var/lib/pgsql/16/data && \
    chown -R postgres:postgres /var/lib/pgsql

# Switch to postgres user
USER postgres

# Define the working directory
WORKDIR /var/lib/pgsql

# Expose PostgreSQL default port
EXPOSE 5432

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/startup.sh"]
