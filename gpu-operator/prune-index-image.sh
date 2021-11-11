JUMPHOST=$1
VERSION=$2
if [ $# -eq 2 ];then

export LOCAL_SECRET_JSON=~/pull-secret.json
cp pull-secret.json.template ${LOCAL_SECRET_JSON}
sed -i "s;JUMPHOST;${JUMPHOST};g" ${LOCAL_SECRET_JSON}
export REGISTRY_AUTH_FILE=~/pull-secret.json
export REG_CREDS=~/pull-secret.json
wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest-4.6/opm-linux.tar.gz
tar xvf opm-linux.tar.gz
podman login registry.redhat.io
podman logout quay.io
<<<<<<< HEAD
=======
podman login quay.io -u rhn_support_liqcui -p "Redhat00!"
>>>>>>> 56ca2e0ad49242d0d7c9f40efa573fd18a31aeef
./opm index prune -f  registry.redhat.io/redhat/certified-operator-index:v${VERSION} -p gpu-operator-certified -t ${JUMPHOST}/certified-operator-index:v${VERSION} 
podman push ${JUMPHOST}/certified-operator-index:v${VERSION}
./opm index prune -f registry.redhat.io/redhat/redhat-operator-index:v${VERSION} -p nfd,performance-addon-operator,nfd-operator  -t ${JUMPHOST}/redhat-operator-index:v${VERSION}
podman push ${JUMPHOST}/redhat-operator-index:v${VERSION}
./opm index prune -f registry.redhat.io/redhat/community-operator-index:v${VERSION} -p openshift-nfd-operator,special-resource-operator -t ${JUMPHOST}/community-operator-index:v${VERSION}
podman push ${JUMPHOST}/community-operator-index:v${VERSION}
<<<<<<< HEAD
./opm index prune -f quay.io/openshift-qe-optional-operators/ocp4-index:latest -p special-resource-operator,nfd -t ${JUMPHOST}/ocp4-index:v${VERSION}
=======
./opm index prune -f quay.io/openshift-qe-optional-operators/ocp4-index:latest -p special-resource-operator,nfd,sriov-network-operator -t ${JUMPHOST}/ocp4-index:v${VERSION}
>>>>>>> 56ca2e0ad49242d0d7c9f40efa573fd18a31aeef
podman push ${JUMPHOST}/ocp4-index:v${VERSION}
else
  echo "Please input jumphost ip"
  echo "$0: jump host: quay.io/openshift-psap-qe 4.8"
fi
