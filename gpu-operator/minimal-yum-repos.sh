Minimal_YumRepos()
{
SOURCE_BASEDIR=$1
TARGET_BASEDIR=$2
rsync $SOURCE_BASEDIR/ -avzP --exclude={*.rpm,} --omit-dir-times $TARGET_BASEDIR/
for pkgname in `cat yum-rpms.lst`
do
     cd $SOURCE_BASEDIR
     file_path_name=`find ./ -name ${pkgname}* | awk -F"${pkgname}" '{print $1}'|sort| uniq`
     echo $file_path_name
     for path_name in `echo $file_path_name`
     do
     source_file_path_name=$SOURCE_BASEDIR`echo $path_name | awk '{print substr($1,2)}'`
     target_file_path_name=$TARGET_BASEDIR`echo $path_name | awk '{print substr($1,2)}'`
     if [ ! -d $target_file_path_name ];then
	  mkdir -p $target_file_path_name
     fi
     cp -rp ${source_file_path_name}/${pkgname}* ${target_file_path_name}
     done
done
rsync $SOURCE_BASEDIR/ -avzP --exclude={rhel*,} --omit-dir-times $TARGET_BASEDIR/
}

Usage()
{
  echo "$0 -s "Soure base dir: /opt/mirror-repos  -t Tartet dir: /tmp/mirror-repos""
}
while getopts :s:t: OPTS;
do
    case $OPTS in
        s) SOURCE_BASEDIR=$OPTARG
                ;;
        t) TARGET_BASEDIR=$OPTARG
                ;;
        [?])
          echo "Invalid Options";
       esac
done

if [ $# -eq 4 ];then
        Minimal_YumRepos $SOURCE_BASEDIR $TARGET_BASEDIR
else
        Usage
fi
