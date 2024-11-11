#!/bin/bash

export PATH="$JEUS_HOME/bin:$JEUS_HOME/lib:$PATH"

# JEUS properties option(ex: -Djeus.scf.group-id=prozone-1 #######
ADD_START_OPT="${ADD_START_OPT}"
export ADD_START_OPT

# Set SCF ID NAME ################################################
if [ -z $SCF_ID ]; then SCF_ID="prozone-1"; fi
SCF_GROUP_ID="-Djeus.scf.group-id=${SCF_ID}"
export SCF_ID
export SCF_GROUP_ID
##################################################################

# Set JVM-Option #################################################
export JAVA_VM_PROPERTIES="${JAVA_VM_PROPERTIES} -Xms1024m -Xmx1024m "
##################################################################

# DOMAIN ID set ##################################################
BASE_ADDRESS=`grep "${HOSTNAME}" /etc/hosts | awk '{print $1}'`
if [ -z $BASE_ADDRESS ]; then export BASE_ADDRESS=0.0.0.0; fi
sed -i "s/%BASE_ADDRESS%/${BASE_ADDRESS}/g" ${DOMAIN_HOME}/config/domain.xml

if [ -z $SERVERNAME ]; then export SERVERNAME=`hostname`; fi
sed -i "s/%SERVERNAME%/${SERVERNAME}/g" ${DOMAIN_HOME}/config/domain.xml

if [ -z $BASE_PORT ]; then export BASE_PORT=9736; fi
sed -i "s/%BASE_PORT%/${BASE_PORT}/g" ${DOMAIN_HOME}/config/domain.xml

if [ -z $HTTP_PORT ]; then export HTTP_PORT=8080; fi
sed -i "s/%HTTP_PORT%/${HTTP_PORT}/g" ${DOMAIN_HOME}/config/domain.xml

if [ -z $HTTP_THREAD_MIN ]; then export HTTP_THREAD_MIN=10; fi
sed -i "s/%HTTP_THREAD_MIN%/${HTTP_THREAD_MIN}/g" ${DOMAIN_HOME}/config/domain.xml

if [ -z $HTTP_THREAD_MAX ]; then export HTTP_THREAD_MAX=20; fi
sed -i "s/%HTTP_THREAD_MAX%/${HTTP_THREAD_MAX}/g" ${DOMAIN_HOME}/config/domain.xml

if [ -z $APP_DIR ]; then export APP_DIR="${INSTALL_HOME}/app"; fi
sed -i "s+%APP_DIR%+${APP_DIR}+g" ${DOMAIN_HOME}/config/domain.xml

if [ -z $APP_NAME_1 ]; then export APP_NAME_1=examples; fi
sed -i "s/%APP_NAME_1%/${APP_NAME_1}/g" ${DOMAIN_HOME}/config/domain.xml

if [ -z $APPLICATION_PATH_1 ]; then export APPLICATION_PATH_1=examples.ear; fi
sed -i "s/%APPLICATION_PATH_1%/${APPLICATION_PATH_1}/g" ${DOMAIN_HOME}/config/domain.xml

if [ -z $APP_TYPE_1 ]; then export APP_TYPE_1=EAR; fi
sed -i "s/%APP_TYPE_1%/${APP_TYPE_1}/g" ${DOMAIN_HOME}/config/domain.xml

if [ -z $NODE_JAVA_1 ]; then export NODE_JAVA_1=false; fi
sed -i "s/%NODE_JAVA_1%/${NODE_JAVA_1}/g" ${DOMAIN_HOME}/config/domain.xml

# JEUS admin IP/PW
if [ -z $JEUS_USER ]; then export JEUS_USER=jeus; fi
if [ -z $PASSWORD ]; then export PASSWORD=jeus; fi