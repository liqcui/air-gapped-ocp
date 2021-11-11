Mirror_Gitlab()
{
  JUMP_HOST=$1
  if [[ -z $JUMP_HOST ]];then
	  echo "NO jump host was found"
	  exit 1
  fi
  echo "Detecte and remove old gitlab container"
  GITLAB_NUM=`podman ps -a |grep gitlab|wc -l`
  if [ $GITLAB_NUM -gt 0 ];then
	  podman stop gitlab;
	  podman rm gitlab;
	  rm -rf /opt/gitlab/
	  sleep 30
  fi
  echo "Exract sample projects of gitlab"
  tar -C /opt/ -xf gitlab.tar.gz
  chmod -R 755 /opt/gitlab/data
  chmod -R 755 /opt/gitlab/logs
  GITLAB_HOME=/opt/gitlab
  sleep 30
  podman run --detach   --publish 8443:443 --publish 80:80 --name gitlab   --restart always   --volume $GITLAB_HOME/config:/etc/gitlab:Z   --volume $GITLAB_HOME/logs:/var/log/gitlab:Z   --volume $GITLAB_HOME/data:/var/opt/gitlab:Z -e "GITLAB_ROOT_PASSWORD=openshift+psap+qe"  docker.io/gitlab/gitlab-ee
  podman exec -it gitlab update-permissions
  podman stop gitlab
  sleep 30
  podman start gitlab
  echo "Wait 300s for gitlab startup"
  sleep  300
  #Clone driver code and update hostname to jumphostname
  cd /tmp/
  if [ -d driver ];then     
	  rm -rf driver  
  fi
  git clone -b entitled https://gitlab.com/zvonkok/driver.git
  cd /tmp/driver
  git checkout entitled
  git remote add origin http://${JUMP_HOST}/zvonkok/driver.git
  sed  -i "s;https://gitlab.com;http://${JUMP_HOST};" .git/config
  find ./ -name Dockerfile | xargs sed -i "s;https://nvidia.github.io;http://${JUMP_HOST}:8080;g"
  find ./ -name Dockerfile | xargs sed -i "s;https://us.download.nvidia.com;http://${JUMP_HOST}:8080;g"
  find ./ -name Dockerfile | xargs sed -i "s;registry.access.redhat.com;${JUMP_HOST}:5000;g"
  find ./ -name Dockerfile | xargs sed -i '1 a\RUN rm -rf /etc/yum.repos.d*.repo/'

  find ./ -name Dockerfile | xargs sed -i "s;https://github.com;http://${JUMP_HOST}:8080;g"
  find ./ -name Dockerfile | xargs sed -i "s;https://raw.githubusercontent.com;http://${JUMP_HOST}:8080;g"
  find ./ -name Dockerfile | xargs sed -i '1 a\RUN rm -rf /etc/yum.repos.d*.repo/'
  
  cat <<EOF >./entitled/CentOS-Base.repo
[LocalBaseOS]
name=LocalYum-$releasever - Base
baseurl= http://${JUMP_HOST}:8080/content/dist/rhel8/8/x86_64/baseos/os
gpgcheck=1
gpgkey=file:/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
protect=1
priority=1
enabled=1

[rhel-8-appstream-rhui-rpms]
name=Red Hat Enterprise Linux 8 for $basearch - AppStream from RHUI (RPMs)
baseurl= http://${JUMP_HOST}:8080/content/dist/rhel8/8/x86_64/appstream/os
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
protect=1
priority=1
EOF
cat <<EOF >./rhel8/CentOS-Base.repo
[LocalBaseOS]
name=LocalYum-$releasever - Base
baseurl= http://${JUMP_HOST}:8080/content/dist/rhel8/8/x86_64/baseos/os
gpgcheck=1
gpgkey=file:/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
protect=1
priority=1
enabled=1
[rhel-8-appstream-rhui-rpms]
name=Red Hat Enterprise Linux 8 for $basearch - AppStream from RHUI (RPMs)
baseurl= http://${JUMP_HOST}:8080/content/dist/rhel8/8/x86_64/appstream/os
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
protect=1
priority=1

EOF
cat ./entitled/CentOS-Base.repo
cat ./rhel8/CentOS-Base.repo
##########################################################
git add .
git config --global user.email "liqcui@redhat.com"
git config --global user.name "psap-user"
git commit -m "Initial commit"
git push --all
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
        Mirror_Gitlab $HOSTNAME
else
        Usage
fi
