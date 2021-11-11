JUMP_HOST=$1
if [ $# -eq 1 ];then
LOCAL_SECRET_JSON=~/pull-secret.json
cp pull-secret.json.template ${LOCAL_SECRET_JSON}
sed -i "s/JUMP_HOST/${JUMP_HOST}/g" ${LOCAL_SECRET_JSON}
cat ${LOCAL_SECRET_JSON}
else
	echo -e "$0: jumphost_name \n"
fi
