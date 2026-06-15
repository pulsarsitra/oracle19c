#!/bin/bash
# startup.sh
# Entrypoint for the Oracle container

# Source Oracle environment
export ORACLE_BASE=/opt/oracle
export ORACLE_HOME=/opt/oracle/product/19c/dbhome_1
export ORACLE_SID=ORCLCDB
export PATH=$ORACLE_HOME/bin:$PATH

DB_DATA_DIR=/opt/oracle/oradata

# Check if the database has already been created
if [ ! -d "$DB_DATA_DIR/$ORACLE_SID" ]; then
    echo "Database does not exist. Creating database $ORACLE_SID..."
    
    dbca -silent -createDatabase \
        -templateName General_Purpose.dbc \
        -gdbname $ORACLE_SID \
        -sid $ORACLE_SID \
        -responseFile NO_VALUE \
        -characterSet AL32UTF8 \
        -sysPassword "Oracl3_19c_Passw0rd" \
        -systemPassword "Oracl3_19c_Passw0rd" \
        -createAsContainerDatabase true \
        -numberOfPDBs 1 \
        -pdbName ORCLPDB1 \
        -pdbAdminPassword "Oracl3_19c_Passw0rd" \
        -databaseType MULTIPURPOSE \
        -automaticMemoryManagement false \
        -totalMemory 2048 \
        -storageType FS \
        -datafileDestination "$DB_DATA_DIR" \
        -emConfiguration NONE \
        -ignorePreReqs
    
    if [ $? -ne 0 ]; then
        echo "Database creation failed!"
        exit 1
    fi
    echo "Database created successfully."
else
    echo "Database already exists. Starting database..."
    
    # Start the listener
    lsnrctl start
    
    # Start the database
    sqlplus / as sysdba << EOF
STARTUP;
ALTER PLUGGABLE DATABASE ALL OPEN;
EXIT;
EOF
fi

echo "Database is up and running."

# Keep the container running by tailing the alert log
ALERT_LOG="$ORACLE_BASE/diag/rdbms/${ORACLE_SID,,}/${ORACLE_SID}/trace/alert_${ORACLE_SID}.log"

if [ -f "$ALERT_LOG" ]; then
    tail -f "$ALERT_LOG"
else
    # Fallback if alert log is not immediately found
    tail -f /dev/null
fi
