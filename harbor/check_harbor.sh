#!/bin/bash

#get protocol
data_dir={{ data_dir }}/harbor
harbor_status_file=$data_dir"/status"
#harbor安装完之后会在创建$data_dir"/status"文件，若没有此文件则认为尚未安装完成，不执行harbor状态检测
if [ ! -f "$harbor_status_file" ];then
    exit 0
fi

harbor_status=`cat $harbor_status_file`

#LOG=/var/log/keepalived_check.log
#nodeip=$1
nodeip=`cat $data_dir/harbor.cfg |  grep -v "#" | grep "hostname =" | awk -F '=' '{print $2}' | sed s/[[:space:]]//g `
nodeaddress="http://${nodeip}"

http_code=`curl -s -o /dev/null -m 2 -w "%{http_code}" ${nodeaddress}`
if [ $http_code == 200 ] ; then
  protocol="http"
elif [ $http_code == 301 ]
then
  protocol="https"
else
#  echo "`date +"%Y-%m-%d %H:%M:%S"` $1, CHECK_CODE=$http_code" >> $LOG
  if [ "$harbor_status" == "installed" ] ; then
      exit 0
  else
      exit 1
  fi
fi

http_code=`curl -k -s -o /dev/null -m 2 -w "%{http_code}\n" ${protocol}://${nodeip}/api/systeminfo`
set +e
if [ $http_code != 200 ] ; then
  if [ "$harbor_status" == "installed" ] ; then
      exit 0
  else
      exit 1
  fi
fi

#systeminfo=`curl -k -o - -s ${protocol}://${nodeip}/api/systeminfo`
#echo $systeminfo | grep "registry_url"
#if [ $? != 0 ] ; then
#  exit 1
#fi
#TODO need to check Clair, but currently Clair status api is unreachable from LB.
# echo $systeminfo | grep "with_clair" | grep "true"
# if [ $? == 0 ] ; then
# clair is enabled
# do some clair check
# else
# clair is disabled
# fi

#check top api

http_code=`curl -k -s -o /dev/null -m 2 -w "%{http_code}\n" ${protocol}://${nodeip}/api/repositories/top`
if [ $http_code == 200 ] ; then
  echo "started" > $harbor_status_file
  exit 0
else
  if [ "$harbor_status" == "installed" ] ; then
      exit 0
  else
      exit 1
  fi
fi
