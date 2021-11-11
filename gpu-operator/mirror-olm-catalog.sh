JUMP_HOST=$1
if [ $# -eq 1 ];then

export LOCAL_SECRET_JSON=~/pull-secret.json
cp pull-secret.json.template ${LOCAL_SECRET_JSON}
sed -i "s;JUMP_HOST;${JUMP_HOST};g" ${LOCAL_SECRET_JSON}
export REGISTRY_AUTH_FILE=~/pull-secret.json
export REG_CREDS=~/pull-secret.json
oc adm catalog mirror --insecure=true --index-filter-by-os='linux/amd64' quay.io/openshift-psap-qe/redhat-operator-index:v4.8 ${JUMP_HOST}/redhat -a ${REGISTRY_AUTH_FILE}

oc adm catalog mirror --insecure=true --index-filter-by-os='linux/amd64' quay.io/openshift-psap-qe/certified-operator-index:v4.8 ${JUMP_HOST}/redhat -a ${REGISTRY_AUTH_FILE}
else
  echo "Please input jumphost ip"
  echo "$0: jump host"
fi
