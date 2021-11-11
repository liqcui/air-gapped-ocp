JUMP_HOST=$1
if [ $# -eq 1 ];then
    if [[ -z $JUMP_HOST ]];then
	    echo "No jump host was found"
	    exit 1
    fi
mkdir -p /var/www/html/content/dist/rhel8/8/x86_64/appstream/
ln -s /opt/mirror-repos/rhel-8-appstream-rhui-rpms /var/www/html/content/dist/rhel8/8/x86_64/appstream/os
mkdir -p /var/www/html/content/dist/rhel8/8/x86_64/baseos/
ln -s /opt/mirror-repos/rhel-8-baseos-rhui-rpms/ /var/www/html/content/dist/rhel8/8/x86_64/baseos/os

else
   echo "Please input jumphost, do not include port number"
fi
