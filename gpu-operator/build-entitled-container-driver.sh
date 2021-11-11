#!/bin/bash
JUMPHOST=$1
if [ $# -eq 1 ];then

echo -n | openssl s_client -showcerts -connect ${JUMPHOST}:5000 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/ocp-registry.crt
sudo cp -f /tmp/ocp-registry.crt /etc/pki/ca-trust/source/anchors
sudo update-ca-trust extract 
sudo openssl verify /tmp/ocp-registry.crt 

#oc image mirror --insecure=true -a ${LOCAL_SECRET_JSON} registry.access.redhat.com/ubi8:latest ${JUMPHOST}/ubi8:latest
cp rhsm.conf.template rhsm.conf
echo "##################Update 0003-cluster-wide-machineconfigs-disconn.yaml"
sed -i   "s!baseurl.*!baseurl = http://${JUMPHOST}:8080/!" rhsm.conf
RHSMCONF=`cat rhsm.conf | base64 -w 0`
cp 0003-cluster-wide-machineconfigs-disconn.yaml.template 0003-cluster-wide-machineconfigs-disconn.yaml
sed -i "s/RHSM_BASE64/$RHSMCONF/g" 0003-cluster-wide-machineconfigs-disconn.yaml
export SUBS_SERIAL=`ls *.pem | awk -F'.' '{print $1}'`
VALID_CERTS=$SUBS_SERIAL.pem

BASE64_PEM_FILE=$(base64 -w 0 ${VALID_CERTS})
cat > ed_replace <<EOL
%s/BASE64_ENCODED_PEM_FILE/${BASE64_PEM_FILE}/g
w
q
EOL
< ed_replace ed 0003-cluster-wide-machineconfigs-disconn.yaml
echo "##################Update ubi images"
cat <<EOF >./Dockerfile
FROM registry.access.redhat.com/ubi8:latest
RUN rm -rf /etc/yum.repos.d/*.repo
EOF
cat ./Dockerfile
podman build -t ${JUMPHOST}:5000/ubi8:latest -f Dockerfile
podman push  ${JUMPHOST}:5000/ubi8:latest --tls-verify=false
#podman push --authfile=/home/mirroradmin/pull-secret.json ${JUMPHOST}/ubi8:latest
cp 0004-cluster-wide-entitled-pod-disconn.yaml.template 0004-cluster-wide-entitled-pod-disconn.yaml
echo "##################Update 0004-cluster-wide-entitled-pod-disconn.yaml"
sed -i "s/JUMPHOST/${JUMPHOST}:5000/g" 0004-cluster-wide-entitled-pod-disconn.yaml
cp 0005-nvidia-driver-container.yaml.template 0005-nvidia-driver-container.yaml
echo "######################update 0005-nvidia-driver-container.yaml"
sed -i "s;uri:.*;uri: http://${JUMPHOST}/zvonkok/driver.git;" 0005-nvidia-driver-container.yaml
else
	echo "Please input jumphost name"
fi
