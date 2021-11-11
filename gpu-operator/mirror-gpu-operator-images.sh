Mirror_Images()
{
 REGISTRY_AUTH_FILE=~/pull-secret.json
 JUMP_HOST=$1
 TRUE_FALSE=$2
 HELM_VERSION=$3
 #Base on gpu operator values.yaml to extract images we need to mirror
 if [[ $TRUE_FALSE == "true" || $TRUE_FALSE == "false" ]];then
	 echo "set insecure to $TRUE_FALSE"
 else
	 echo "Invalid parameter for TRUE_FALSE, please use true or false"
	 exit 1
 fi
 if [[ $HELM_VERSION == "master" ]];then
     if [ ! -f values.yaml ];then
         curl -sO https://raw.githubusercontent.com/NVIDIA/gpu-operator/${HELM_VERSION}/deployments/gpu-operator/values.yaml 
     fi  
       grep 'repository:\|image:\|version:' values.yaml| sed  's/ //g'|tr ":" "=">./images.lst
 else
     if [ ! -f values-${HELM_VERSION}.yaml ];then
         curl -s -o values-${HELM_VERSION}.yaml https://raw.githubusercontent.com/NVIDIA/gpu-operator/${HELM_VERSION}/deployments/gpu-operator/values.yaml 
     fi 
     grep 'repository:\|image:\|version:' values-${HELM_VERSION}.yaml| sed  's/ //g'|tr ":" "=">./images.lst
 fi
 TOTAL_LINES=`cat ./images.lst|wc -l`
 LOOP_TIMES=$(( $TOTAL_LINES / 3 ))
 INIT_NUM=1
 echo $TOTAL_LINES $LOOP_TIMES
 while [ $INIT_NUM -le $LOOP_TIMES ]
 do
 cat ./images.lst | sed -n '1,3p'>./3vars.lst
 source ./3vars.lst
 if [[ -z $version ]];then
	 echo "------------------------------------------------------"
	 echo "${repository}/${image} =>${JUMP_HOST}/`echo ${repository}|cut -d'/' -f2-`/${image}"
   oc image mirror ${repository}/${image} ${JUMP_HOST}/`echo ${repository}|cut -d'/' -f2-`/${image} -a ${REGISTRY_AUTH_FILE} --insecure=${TRUE_FALSE}
 else
         if [[ $image == "driver" ]];then
             #Please add new os version
	     #460.73.01-rhcos4.8
	     for osversion in rhcos4.5 rhcos4.7 rhcos4.8 rhcos4.9
	     do
	       driverversion=${version}-${osversion}
	       echo driverversion is $driverversion
	 echo "------------------------------------------------------"
	 echo "${repository}/${image}:${driverversion} =>${JUMP_HOST}/`echo ${repository}|cut -d'/' -f2-`/${image}:${driverversion} "
               oc image mirror ${repository}/${image}:${driverversion} ${JUMP_HOST}/`echo ${repository}|cut -d'/' -f2-`/${image}:${driverversion} -a ${REGISTRY_AUTH_FILE} --insecure=${TRUE_FALSE}
	     done
	 else
	 echo "------------------------------------------------------"
	 echo "${repository}/${image}:${version} =>${JUMP_HOST}/`echo ${repository}|cut -d'/' -f2-`/${image}:${version} "
               oc image mirror ${repository}/${image}:${version} ${JUMP_HOST}/`echo ${repository}|cut -d'/' -f2-`/${image}:${version} -a ${REGISTRY_AUTH_FILE} --insecure=${TRUE_FALSE}
         fi
 fi
 sed -i '1,3d' ./images.lst
 INIT_NUM=$(( $INIT_NUM + 1))
done
   oc image mirror quay.io/openshift-psap/gpu-burn:latest ${JUMP_HOST}/openshift-psap/gpu-burn:latest  -a ${REGISTRY_AUTH_FILE} --insecure=${TRUE_FALSE}
   oc image mirror quay.io/shivamerla/k8s-driver-manager:v0.1.0 ${JUMP_HOST}/shivamerla/k8s-driver-manager:v0.1.0 -a $REGISTRY_AUTH_FILE --insecure=${TRUE_FALSE}
   oc image mirror nvidia/dcgm-exporter:2.1.8-2.4.0-rc.3-ubi8 ${JUMP_HOST}/nvidia/k8s/dcgm-exporter:2.1.8-2.4.0-rc.3-ubi8 -a $REGISTRY_AUTH_FILE --insecure=${TRUE_FALSE}
}
Usage()
{
	echo "$0: -s JUMP_HOST(https: hostname, http: hostname:5000) -b \"--insecure is true or false\" -v HELM_VERSION(master,v1.8.0,v1.7.1)"
}
while getopts :s:b:v: OPTS;
do
    case $OPTS in
        s) JUMP_HOST=$OPTARG
                ;;
        b) TRUE_FALSE=$OPTARG
                ;;
        v) HELM_VERSION=$OPTARG
                ;;
        [?])
          echo "Invalid Options";
       esac
done

if [ $# -eq 6 ];then
     Mirror_Images $JUMP_HOST $TRUE_FALSE $HELM_VERSION
else
        Usage
fi
