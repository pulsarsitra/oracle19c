# Stage 1: Builder
FROM oraclelinux:8 AS builder

ENV ORACLE_BASE=/opt/oracle \
    ORACLE_HOME=/opt/oracle/product/19c/dbhome_1 \
    INSTALL_FILE_1="LINUX.X64_193000_db_home.zip" \
    INSTALL_DIR=/opt/install \
	SLIMMING=true

RUN dnf -y install oracle-database-preinstall-19c unzip && \
    dnf clean all

RUN mkdir -p $ORACLE_BASE && \
    mkdir -p $ORACLE_HOME && \
    mkdir -p $INSTALL_DIR && \
    chown -R oracle:oinstall $ORACLE_BASE && \
    chown -R oracle:oinstall $INSTALL_DIR

COPY install_oracle.sh $INSTALL_DIR/
RUN chmod +x $INSTALL_DIR/install_oracle.sh && \
    chown -R oracle:oinstall $INSTALL_DIR

USER oracle
WORKDIR $INSTALL_DIR
COPY --chown=oracle:oinstall $INSTALL_FILE_1 $INSTALL_DIR/

ARG SLIMMING=true
ENV SLIMMING=${SLIMMING}

RUN cd $ORACLE_HOME && \
    unzip -q $INSTALL_DIR/$INSTALL_FILE_1 && \
    $INSTALL_DIR/install_oracle.sh && \
    rm -rf $INSTALL_DIR/* && \
    if [ "${SLIMMING}" == "true" ]; then \
        echo "Running aggressive SLIMMING process..." && \
        rm -rf $ORACLE_HOME/apex && \
        rm -rf $ORACLE_HOME/ords && \
        rm -rf $ORACLE_HOME/sqldeveloper && \
        rm -rf $ORACLE_HOME/ucp && \
        rm -rf $ORACLE_HOME/lib/*.zip && \
        rm -rf $ORACLE_HOME/inventory/backup/* && \
        rm -rf $ORACLE_HOME/network/tools/help && \
        rm -rf $ORACLE_HOME/assistants/dbua && \
        rm -rf $ORACLE_HOME/dmu && \
        rm -rf $ORACLE_HOME/install/pilot && \
        rm -rf $ORACLE_HOME/suptools && \
        find $ORACLE_HOME -name "*.zip" -exec rm -f {} \; ; \
    fi

# Stage 2: Final Image
FROM oraclelinux:8

ENV ORACLE_BASE=/opt/oracle \
    ORACLE_HOME=/opt/oracle/product/19c/dbhome_1 \
    ORACLE_SID=ORCLCDB \
    PATH=/opt/oracle/product/19c/dbhome_1/bin:$PATH

RUN dnf -y install oracle-database-preinstall-19c vim && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Copy the slimmed down Oracle binaries from the builder stage
COPY --from=builder --chown=oracle:oinstall $ORACLE_BASE $ORACLE_BASE

COPY startup.sh $ORACLE_BASE/
RUN chmod +x $ORACLE_BASE/startup.sh && \
    chown oracle:oinstall $ORACLE_BASE/startup.sh

USER oracle
WORKDIR $ORACLE_BASE

EXPOSE 1521 5500
ENTRYPOINT ["/opt/oracle/startup.sh"]
