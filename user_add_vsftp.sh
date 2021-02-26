#! /bin/bash
#新增vsftp虚拟用户脚本 
#2020-8 hc
user_conf_path=/etc/vsftpd/vsftpd_user_conf
user_data_path=/home/ftpuser 
echo "欢迎使用vsFTP创建程序，请输入用户名："
read username
if [ -d $user_data_path/$username ];then
echo "该用户已存在！"
else 
echo "请输入密码：" 
read password
        echo "请再一次输入密码："
read password2
        if [ $password != $password2 ];then
       echo "您两次输入的密码不一致！"
else
 
mkdir $user_data_path/$username
chown -R ftpuser:ftpuser $user_data_path/$username
chmod -R 700 $user_data_path/$username
 
touch $user_conf_path/$username
echo "local_root=$user_data_path/$username">>$user_conf_path/$username
echo "write_enable=YES">>$user_conf_path/$username
echo "anon_world_readable_only=YES">>$user_conf_path/$username
echo "anon_upload_enable=YES">>$user_conf_path/$username
echo "anon_mkdir_write_enable=YES">>$user_conf_path/$username
echo "anon_other_write_enable=YES">>$user_conf_path/$username
 
echo "$username">>/etc/vsftpd/ftpuser.txt
echo "$password">>/etc/vsftpd/ftpuser.txt
db_load -T -t hash -f /etc/vsftpd/ftpuser.txt /etc/vsftpd/vsftpd_login.db
echo "FTP帐号成功创建！"
fi
fi
