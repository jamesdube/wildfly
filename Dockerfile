# Use latest jboss/base-jdk:11 image as the base
FROM jboss/base-jdk:8

# Set the WILDFLY_VERSION env variable
ENV WILDFLY_VERSION 8.2.0.Final
ENV WILDFLY_SHA1 d78a864386a9bc08812eed9781722e45812a7826
ENV JBOSS_HOME /opt/jboss/wildfly

USER root

# Add the WildFly distribution to /opt, and make wildfly the owner of the extracted tar content
# Make sure the distribution is available from a well-known place

# RUN cd $HOME
 # COPY wildfly-8.2.0.Final.tar.gz /root/wildfly-8.2.0.Final.tar.gz 
 # COPY mysql-connector-java-8.0.19.tar.gz /root/mysql-connector-java-8.0.19.tar.gz
COPY module.xml /root/module.xml
# RUN pwd && ls -lh

RUN cd $HOME \
    && curl -O https://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz \
    && curl -O -L https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.19.tar.gz \
    && tar -xvzf mysql-connector-java-8.0.19.tar.gz \
    && sha1sum wildfly-$WILDFLY_VERSION.tar.gz | grep $WILDFLY_SHA1 \
    && tar xf wildfly-$WILDFLY_VERSION.tar.gz \
    && mv $HOME/wildfly-$WILDFLY_VERSION $JBOSS_HOME \
    && mkdir -p $JBOSS_HOME/modules/system/layers/base/com/mysql/main/ \
    && mv $HOME/mysql-connector-java-8.0.19/mysql-connector-java-8.0.19.jar $JBOSS_HOME/modules/system/layers/base/com/mysql/main/ \
    && mv $HOME/module.xml $JBOSS_HOME/modules/system/layers/base/com/mysql/main/ \
    && rm wildfly-$WILDFLY_VERSION.tar.gz \
    && chown -R jboss:0 ${JBOSS_HOME} \
    && mkdir -p /data/ \
    && chown -R jboss:0 /data/ \
    && chmod -R g+rw ${JBOSS_HOME} \
    && chmod -R g+rw /data/

ENV LAUNCH_JBOSS_IN_BACKGROUND true

USER jboss

# Expose the ports we're interested in
EXPOSE 8080 9990

# Set the default command to run on boot
# This will boot WildFly in the standalone mode and bind to all interface
CMD ["/opt/jboss/wildfly/bin/standalone.sh","-c", "standalone.xml","-b", "0.0.0.0" ,"-bmanagement","--debug", "0.0.0.0"]
