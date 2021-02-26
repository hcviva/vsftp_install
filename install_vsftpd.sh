#!/bin/bash
#By auto install vsftp
#2021-2-23 hc
#更新说明，降配置文件和拷贝文件单独目录，新增使用说明-h或者--help参数。
#设置变量
user_data_dir=/home/ftpuser
user_conf_dir=/etc/vsftpd/vsftpd_user_conf
#使用说明
if [[ $1 = "--help" ]] || [[ $1 = "-h" ]]
then
    echo "1.请先配置conf目录下配置用户和密码"
    echo "2.再配置安装脚本文件下$0变量"
    echo "3执行安装脚本$0"
    echo '4.安装完成后可以使用用户添加脚本user_add_vsftp.sh新增用户'
    exit 0
fi
#must use root user run scripts 必须使用root用户运行，$UID为系统变量
if	
   [ $UID -ne 0 ];then
   echo "---必须使用root用户运行脚本 ! ! !---"
   sleep 2
   exit 0
fi

#检查是否配置源
yum list vsftpd
if [ $? -ne  0 ];then
  echo "请先配置软件源，再执行脚本"
  sleep 2
  exit 0
fi
#判断是否已安装软件
rpm -qa |grep vsftpd
if 
  [ $? -eq 0 ];then
  echo "该机器已安装vsftpd"
  sleep 2
  exit 0
fi

#安装软件和依赖软件
yum   install    vsftpd*   -y && yum  install  pam*  libdb-utils  libdb*  --skip-broken  -y
if [ $? -ne 0 ];then
    exit 1
fi
#拷贝配置文件
#备份配置文件
if [ ! -f /etc/vsftpd/vsftpd.confbak ] ;then
cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.confbak
fi
cp ./conf/vsftpd.conf /etc/vsftpd/
cp ./conf/ftpusers.txt /etc/vsftpd/
db_load  -T  -t  hash  -f  /etc/vsftpd/ftpusers.txt  /etc/vsftpd/vsftpd_login.db
chmod  700  /etc/vsftpd/vsftpd_login.db
cp ./file/vsftpd /etc/pam.d/
useradd    -s   /sbin/nologin    ftpuser
if
   [ ! -d  $user_conf_dir ];then
   mkdir  -p    $user_conf_dir
fi

mkdir -p $user_data_dir/{sunrun,hc} ;chown -R ftpuser:ftpuser $user_data_dir
 cp ./conf/hc_ftp_conf  $user_conf_dir
 cp ./conf/sunrun_ftp_conf  $user_conf_dir
systemctl  restart  vsftpd.service
systemctl  enable  vsftpd.service
systemctl stop firewalld


