StartupService()
{
JUMPHOST=$1
cp Dockerfile4registry.template Dockerfile4registry
sed -i "s/JUMPHOST/${JUMPHOST}/g" Dockerfile4registry
podman build -t docker.io/library/registry:2.7.1  -f Dockerfile4registry
podman run -d  --restart=always --name ocp-registry -e REGISTRY_HTTP_ADDR=0.0.0.0:443 -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key -p 443:443 docker.io/library/registry:2.7.1

}

Usage()
{
  echo "$0 -s "Jumphost Name""
}
while getopts :s: OPTS;
do 
    case $OPTS in
	s) HOSTNAME=$OPTARG
		;;
	[?]) 
	  echo "Invalid Options"; 
       esac
done

if [ $# -eq 2 ];then
	StartupService $HOSTNAME
else
	Usage
fi
