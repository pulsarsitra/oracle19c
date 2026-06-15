#!/bin/bash
# install_oracle.sh
# Performs a silent installation of the Oracle database software

echo "Running Oracle Database 19c Silent Installation..."

# Make sure we are in the correct directory
cd $ORACLE_HOME

# Setup silent install response file inline or via arguments
export CV_ASSUME_DISTID=OEL8

./runInstaller -silent -force -waitforcompletion \
    oracle.install.option=INSTALL_DB_SWONLY \
    UNIX_GROUP_NAME=oinstall \
    INVENTORY_LOCATION=/opt/oracle/oraInventory \
    ORACLE_HOME=$ORACLE_HOME \
    ORACLE_BASE=$ORACLE_BASE \
    oracle.install.db.InstallEdition=EE \
    oracle.install.db.OSDBA_GROUP=dba \
    oracle.install.db.OSBACKUPDBA_GROUP=dba \
    oracle.install.db.OSDGDBA_GROUP=dba \
    oracle.install.db.OSKMDBA_GROUP=dba \
    oracle.install.db.OSRACDBA_GROUP=dba \
    SECURITY_UPDATES_VIA_MYORACLESUPPORT=false \
    DECLINE_SECURITY_UPDATES=true

INSTALL_STATUS=$?

if [ $INSTALL_STATUS -ne 0 ] && [ $INSTALL_STATUS -ne 6 ] && [ $INSTALL_STATUS -ne 254 ]; then
    echo "Oracle installation failed with status code: $INSTALL_STATUS"
    exit 1
fi

echo "Installation complete. Please note that root.sh needs to be run as root, but we skip it in the container for DB software only."
exit 0
