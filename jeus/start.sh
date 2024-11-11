#!/bin/sh

. ${SCRIPT_HOME}/env.sh


## standalone start script
# startCloudServer -u username -p password -server servername
#${JEUS_HOME}/bin/startCloudServer -u $JEUS_USER -p $PASSWORD -domain domain1 -server ${SERVERNAME} ${SCF_GROUP_ID} ${ADD_START_OPT}
${JEUS_HOME}/bin/startDomainAdminServer -u $JEUS_USER -p $PASSWORD -domain domain1 -server ${SERVERNAME} ${SCF_GROUP_ID} ${ADD_START_OPT}
#${JEUS_HOME}/bin/startManagedServer -u $JEUS_USER -p $PASSWORD -domain domain1 -server ${SERVERNAME} ${SCF_GROUP_ID} ${ADD_START_OPT}