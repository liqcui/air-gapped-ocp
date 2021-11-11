JUMP_HOST=$1
if [ $# -eq 1 ];then
mkdir -p /var/www/html/content/dist/rhel8/8/x86_64/appstream/
ln -s /opt/mirror-repos/rhel-8-appstream-rhui-rpms /var/www/html/content/dist/rhel8/8/x86_64/appstream/os
mkdir -p /var/www/html/content/dist/rhel8/8/x86_64/baseos/
ln -s /opt/mirror-repos/rhel-8-baseos-rhui-rpms/ /var/www/html/content/dist/rhel8/8/x86_64/baseos/os

mkdir -p  /var/www/html/nvidia-container-runtime/centos7/
curl -s -L https://nvidia.github.io/nvidia-container-runtime/centos7/nvidia-container-runtime.repo | \
    tee  /var/www/html/nvidia-container-runtime/centos7/nvidia-container-runtime.repo
sed -i 's;https://nvidia.github.io;http://${JUMP_HOST}:8080;' /var/www/html/nvidia-container-runtime/centos7/nvidia-container-runtime.repo
sed -i 's/repo_gpgcheck=1/repo_gpgcheck=0/' /var/www/html/nvidia-container-runtime/centos7/nvidia-container-runtime.repo

mkdir -p  /var/www/html/libnvidia-container/stable/centos7/
mkdir -p  /var/www/html/libnvidia-container/experimental/centos7/
mkdir -p  /var/www/html/nvidia-container-runtime/stable/centos7/
mkdir -p  /var/www/html/nvidia-container-runtime/experimental/centos7/
ln -s /opt/mirror-repos/libnvidia-container/ /var/www/html/libnvidia-container/stable/centos7/x86_64
ln -s /opt/mirror-repos/libnvidia-container-experimental/  /var/www/html/libnvidia-container/experimental/centos7/x86_64
ln -s /opt/mirror-repos/nvidia-container-runtime/  /var/www/html/nvidia-container-runtime/stable/centos7/x86_64
ln -s /opt/mirror-repos/nvidia-container-runtime-experimental /var/www/html/nvidia-container-runtime/experimental/centos7/x86_64

mkdir -p /var/www/html/3XX0/donkey/releases/download/v1.1.0/
curl -fsSL -o /var/www/html/3XX0/donkey/releases/download/v1.1.0/donkey https://github.com/3XX0/donkey/releases/download/v1.1.0/donkey 

mkdir -p /var/www/html/torvalds/linux/master/scripts/
curl -fsSL -o  /var/www/html/torvalds/linux/master/scripts/extract-vmlinux https://raw.githubusercontent.com/torvalds/linux/master/scripts/extract-vmlinux
 
export BASE_URL=https://us.download.nvidia.com/tesla
export DRIVER_VERSION=418.87.01
export SHORT_DRIVER_VERSION=418.87
export DRIVER_VERSION=$DRIVER_VERSION

mkdir -p  /var/www/html/tesla/$SHORT_DRIVER_VERSION/
cd /var/www/html/tesla/$SHORT_DRIVER_VERSION/
pwd
curl -fSsl -O $BASE_URL/$SHORT_DRIVER_VERSION/NVIDIA-Linux-x86_64-$DRIVER_VERSION.run
else
   echo "Please input jumphost, do not include port number"
fi
